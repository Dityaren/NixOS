{ self, inputs, ... }:
{
  flake.nixosModules.dmm =
    { pkgs, ... }:
    let
      steamRun = "${(pkgs.steam-run.override { privateTmp = false; })}/bin/steam-run";
      dialog = "${pkgs.dialog}/bin/dialog";

      common = pkgs.writeText "dmm-common.sh" ''
        CONFIG_DIR="''${DMM_CONFIG_DIR:-$HOME/.config/dmm}"
        CONFIG_FILE="$CONFIG_DIR/config"
        GAMES_DIR="$CONFIG_DIR/games"

        mkdir -p "$CONFIG_DIR" "$GAMES_DIR"

        if [ ! -f "$CONFIG_FILE" ]; then
          cat > "$CONFIG_FILE" <<EOF
        DMM_PREFIX="$HOME/Games/dmm"
        WINDOWS_ROOT="$HOME/windows"
        GAME_ROOT="$HOME/windows/game/dmmgame"
        DATA_ROOT="$HOME/windows/Users/dia/AppData/LocalLow"
        DMM_EXE="$HOME/windows/Program Files/DMMGamePlayer/DMMGamePlayer.exe"
        DMM_RUNNER_TYPE="wine"
        DMM_RUNNER_PATH="$HOME/.local/share/anime-game-launcher/runners/spritz-wine-cachyos-wow64-10.0-11"
        DMM_RUNTIME="steam-run"
        DMM_DEBUG="false"
        EOF
        fi

        . "$CONFIG_FILE"

        : "''${DMM_PREFIX:=$HOME/Games/dmm}"
        : "''${WINDOWS_ROOT:=$HOME/windows}"
        : "''${GAME_ROOT:=$WINDOWS_ROOT/game/dmmgame}"
        : "''${DATA_ROOT:=$WINDOWS_ROOT/Users/dia/AppData/LocalLow}"
        : "''${DMM_RUNNER_TYPE:=wine}"
        : "''${DMM_RUNTIME:=steam-run}"
        : "''${DMM_DEBUG:=false}"

        dmm_save_value() {
          local file="$1" key="$2" value="$3" tmp
          mkdir -p "$(dirname "$file")"
          tmp=$(mktemp)
          if [ -f "$file" ]; then
            grep -v "^$key=" "$file" > "$tmp" || true
          fi
          printf '%s=%q\n' "$key" "$value" >> "$tmp"
          mv "$tmp" "$file"
        }

        dmm_runtime() {
          case "''${1:-steam-run}" in
            steam-run) shift; ${steamRun} "$@" ;;
            host) shift; "$@" ;;
            *)
              echo "Unknown runtime: $1" >&2
              return 1
              ;;
          esac
        }

        dmm_runner_executable() {
          local type="$1" path="$2"
          case "$type" in
            wine)
              if [ -d "$path" ]; then printf '%s\n' "$path/bin/wine"
              else printf '%s\n' "$path"; fi
              ;;
            proton)
              if [ -d "$path" ]; then printf '%s\n' "$path/proton"
              else printf '%s\n' "$path"; fi
              ;;
            custom) printf '%s\n' "$path" ;;
            *) return 1 ;;
          esac
        }

        dmm_launch() {
          local type="$1" runner="$2" prefix="$3" exe="$4" runtime="$5"
          shift 5

          if [ ! -f "$exe" ]; then
            echo "Executable not found: $exe" >&2
            return 1
          fi

          local executable
          executable=$(dmm_runner_executable "$type" "$runner") || return 1
          if [ ! -x "$executable" ]; then
            echo "Runner is missing or not executable: $executable" >&2
            return 1
          fi

          case "$type" in
            wine)
              export WINEPREFIX="$prefix"
              export WINE="$executable"
              export WINESERVER="$(dirname "$executable")/wineserver"
              export WINEDEBUG="''${WINEDEBUG:--all}"
              export WINEDLLOVERRIDES="winemenubuilder.exe=d''${WINEDLLOVERRIDES:+;$WINEDLLOVERRIDES}"
              if [ "''${DMM_DEBUG:-false}" = true ]; then
                export WINEDEBUG="+timestamp,+pid,+tid,err,warn"
              fi
              dmm_runtime "$runtime" "$executable" "$exe" "$@"
              ;;
            proton)
              mkdir -p "$prefix"
              export STEAM_COMPAT_DATA_PATH="$prefix"
              export STEAM_COMPAT_CLIENT_INSTALL_PATH="''${STEAM_COMPAT_CLIENT_INSTALL_PATH:-$HOME/.steam/steam}"
              export PROTON_LOG=0
              if [ "''${DMM_DEBUG:-false}" = true ]; then export PROTON_LOG=1; fi
              dmm_runtime "$runtime" "$executable" run "$exe" "$@"
              ;;
            custom)
              dmm_runtime "$runtime" "$executable" "$exe" "$@"
              ;;
          esac
        }

        dmm_slug() {
          printf '%s' "$1" |
            tr '[:upper:]' '[:lower:]' |
            sed 's/[^a-z0-9_-]/-/g; s/--*/-/g; s/^-//; s/-$//'
        }

        dmm_profile() {
          local slug
          slug=$(dmm_slug "$1")
          local file="$GAMES_DIR/$slug"
          if [ ! -f "$file" ]; then
            echo "Game profile not found: $slug" >&2
            return 1
          fi
          . "$file"
        }

        dmm_choose_runner_type() {
          "$DIALOG" --stdout --title "Runner type" \
            --menu "Choose the compatibility runner for this application." 13 70 4 \
            wine "Wine (recommended for DMM)" \
            proton "Proton / GE-Proton" \
            custom "Custom executable"
        }

        dmm_find_runners() {
          local type="$1" dir item
          case "$type" in
            wine)
              for dir in "$HOME/.local/share/anime-game-launcher/runners" "$HOME/.local/share/wine" "$HOME/.wine-runners"; do
                [ -d "$dir" ] || continue
                for item in "$dir"/*; do [ -d "$item" ] && printf '%s\n' "$item"; done
              done
              ;;
            proton)
              for dir in "$HOME/.steam/root/compatibilitytools.d" "$HOME/.steam/steam/compatibilitytools.d" "$HOME/.local/share/Steam/compatibilitytools.d" "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/compatibilitytools.d"; do
                [ -d "$dir" ] || continue
                for item in "$dir"/*; do [ -x "$item/proton" ] && printf '%s\n' "$item"; done
              done
              ;;
          esac
        }

        dmm_select_runner_path() {
          local type="$1" current="''${2:-}" entries=() item label selected
          while IFS= read -r item; do
            [ -n "$item" ] || continue
            label=$(basename "$item")
            entries+=("$item" "$label")
          done < <(dmm_find_runners "$type")

          if [ "''${#entries[@]}" -gt 0 ]; then
            entries+=("__manual__" "Enter a path manually")
            selected=$("$DIALOG" --stdout --title "Select runner" \
              --menu "Detected runners. Choose one or enter a custom path." 20 78 12 \
              "''${entries[@]}") || return 1
            if [ "$selected" != __manual__ ]; then printf '%s\n' "$selected"; return 0; fi
          fi

          "$DIALOG" --stdout --title "Runner location" \
            --inputbox "Enter the runner directory or executable path:" 9 78 "$current"
        }

        dmm_select_file() {
          local title="$1" current="$2"
          "$DIALOG" --stdout --title "$title" --fselect "$current" 18 78
        }

        dmm_select_directory() {
          local title="$1" current="$2"
          "$DIALOG" --stdout --title "$title" --dselect "$current" 18 78
        }
      '';

      dmm = pkgs.writeShellScriptBin "dmm" ''
        . ${common}
        if [ -z "''${DMM_EXE:-}" ]; then
          echo "DMM executable is not configured. Run dmm-config first." >&2
          exit 1
        fi
        dmm_launch "$DMM_RUNNER_TYPE" "$DMM_RUNNER_PATH" "$DMM_PREFIX" "$DMM_EXE" "$DMM_RUNTIME" "$@"
      '';

      dmmGame = pkgs.writeShellScriptBin "dmm-game" ''
        . ${common}
        if [ -z "''${1:-}" ]; then
          echo "Usage: dmm-game <profile> [arguments...]" >&2
          echo "Available profiles:"
          for file in "$GAMES_DIR"/*; do
            [ -f "$file" ] || continue
            ( . "$file"; printf '  %s\n' "''${GAME_NAME:-$(basename "$file")}" )
          done
          exit 1
        fi
        profile="$1"
        shift
        dmm_profile "$profile" || exit 1
        dmm_launch "$GAME_RUNNER_TYPE" "$GAME_RUNNER_PATH" "$GAME_PREFIX" "$GAME_EXE" "''${GAME_RUNTIME:-$DMM_RUNTIME}" "$@"
      '';

      dmmConfig = pkgs.writeShellScriptBin "dmm-config" ''
        . ${common}
        DIALOG="${dialog}"
        export DIALOGRC="''${DIALOGRC:-}"

        info() { "$DIALOG" --msgbox "$1" 9 72; }

        ask() {
          "$DIALOG" --stdout --title "$1" --inputbox "$2" 10 78 "$3"
        }

        choose_runtime() {
          "$DIALOG" --stdout --title "Execution environment" \
            --menu "Choose how the runner is launched." 12 70 2 \
            steam-run "Steam runtime (recommended)" \
            host "Host environment"
        }

        edit_global() {
          local value type path runtime debug
          value=$(dmm_select_directory "DMM Wine prefix / Proton compatdata" "$DMM_PREFIX") || return
          dmm_save_value "$CONFIG_FILE" DMM_PREFIX "$value"
          DMM_PREFIX="$value"

          value=$(dmm_select_directory "Windows installation directory" "$WINDOWS_ROOT") || return
          dmm_save_value "$CONFIG_FILE" WINDOWS_ROOT "$value"
          WINDOWS_ROOT="$value"

          value=$(dmm_select_directory "Game installation directory" "$GAME_ROOT") || return
          dmm_save_value "$CONFIG_FILE" GAME_ROOT "$value"
          GAME_ROOT="$value"

          value=$(dmm_select_directory "Game data directory" "$DATA_ROOT") || return
          dmm_save_value "$CONFIG_FILE" DATA_ROOT "$value"
          DATA_ROOT="$value"

          value=$(dmm_select_file "DMM Game Player executable" "''${DMM_EXE:-$WINDOWS_ROOT/Program Files/DMMGamePlayer/DMMGamePlayer.exe}") || return
          dmm_save_value "$CONFIG_FILE" DMM_EXE "$value"
          DMM_EXE="$value"

          type=$(dmm_choose_runner_type) || return
          path=$(dmm_select_runner_path "$type" "''${DMM_RUNNER_PATH:-}") || return
          dmm_save_value "$CONFIG_FILE" DMM_RUNNER_TYPE "$type"
          dmm_save_value "$CONFIG_FILE" DMM_RUNNER_PATH "$path"
          DMM_RUNNER_TYPE="$type"
          DMM_RUNNER_PATH="$path"

          runtime=$(choose_runtime) || return
          dmm_save_value "$CONFIG_FILE" DMM_RUNTIME "$runtime"
          DMM_RUNTIME="$runtime"

          debug=$("$DIALOG" --stdout --title "Debug logging" \
            --menu "Enable verbose Wine / Proton logs?" 10 60 2 \
            false "Disabled" true "Enabled") || return
          dmm_save_value "$CONFIG_FILE" DMM_DEBUG "$debug"
          info "General settings saved."
        }

        create_game() {
          local name slug exe type runner prefix runtime data
          name=$(ask "New game profile" "Enter a display name for this game:" "") || return
          slug=$(dmm_slug "$name")
          if [ -z "$slug" ]; then info "That game name cannot be used."; return; fi
          if [ -e "$GAMES_DIR/$slug" ]; then info "A profile with this name already exists."; return; fi

          exe=$(dmm_select_file "Game executable" "$GAME_ROOT/$slug/$slug.exe") || return
          type=$(dmm_choose_runner_type) || return
          runner=$(dmm_select_runner_path "$type" "''${DMM_RUNNER_PATH:-}") || return
          prefix=$(dmm_select_directory "Game prefix / Proton compatdata directory" "$DMM_PREFIX/$slug") || return
          runtime=$(choose_runtime) || return
          data=$(dmm_select_directory "Optional game data directory (Cancel to skip)" "$DATA_ROOT") || data=""

          {
            printf 'GAME_NAME=%q\n' "$name"
            printf 'GAME_EXE=%q\n' "$exe"
            printf 'GAME_RUNNER_TYPE=%q\n' "$type"
            printf 'GAME_RUNNER_PATH=%q\n' "$runner"
            printf 'GAME_PREFIX=%q\n' "$prefix"
            printf 'GAME_RUNTIME=%q\n' "$runtime"
            printf 'GAME_DATA=%q\n' "$data"
          } > "$GAMES_DIR/$slug"
          info "Created profile for $name.\n\nLaunch it with:\ndmm-game $slug"
        }

        choose_profile() {
          local files=() file slug name
          for file in "$GAMES_DIR"/*; do
            [ -f "$file" ] || continue
            slug=$(basename "$file")
            name=$( . "$file"; printf '%s' "''${GAME_NAME:-$slug}" )
            files+=("$slug" "$name")
          done
          [ "''${#files[@]}" -gt 0 ] || { info "No game profiles exist yet."; return 1; }
          "$DIALOG" --stdout --title "Game profiles" --menu "Select a game profile:" 20 78 12 "''${files[@]}"
        }

        edit_game() {
          local slug file value key type runner
          slug=$(choose_profile) || return
          file="$GAMES_DIR/$slug"
          . "$file"

          value=$(ask "Game name" "Display name:" "$GAME_NAME") || return
          dmm_save_value "$file" GAME_NAME "$value"
          value=$(dmm_select_file "Game executable" "$GAME_EXE") || return
          dmm_save_value "$file" GAME_EXE "$value"

          type=$(dmm_choose_runner_type) || return
          runner=$(dmm_select_runner_path "$type" "$GAME_RUNNER_PATH") || return
          dmm_save_value "$file" GAME_RUNNER_TYPE "$type"
          dmm_save_value "$file" GAME_RUNNER_PATH "$runner"

          value=$(dmm_select_directory "Game prefix / Proton compatdata directory" "$GAME_PREFIX") || return
          dmm_save_value "$file" GAME_PREFIX "$value"

          value=$(choose_runtime) || return
          dmm_save_value "$file" GAME_RUNTIME "$value"

          value=$(ask "Game data directory" "Optional data directory (leave empty if unused):" "''${GAME_DATA:-}") || return
          dmm_save_value "$file" GAME_DATA "$value"
          info "Updated profile: $GAME_NAME"
        }

        delete_game() {
          local slug file name
          slug=$(choose_profile) || return
          file="$GAMES_DIR/$slug"
          . "$file"
          name="''${GAME_NAME:-$slug}"
          "$DIALOG" --yesno "Delete the profile for '$name'?\n\nThis does not delete game files or Wine prefixes." 10 72 || return
          rm -f "$file"
          info "Deleted profile: $name"
        }

        list_games() {
          local output="" file
          for file in "$GAMES_DIR"/*; do
            [ -f "$file" ] || continue
            (
              . "$file"
              printf '%s\n  Executable: %s\n  Runner: %s\n  Prefix: %s\n  Runtime: %s\n\n' \
                "''${GAME_NAME:-$(basename "$file")}" "$GAME_EXE" \
                "$GAME_RUNNER_TYPE" "$GAME_PREFIX" "''${GAME_RUNTIME:-$DMM_RUNTIME}"
            )
          done
          output=$(for file in "$GAMES_DIR"/*; do
            [ -f "$file" ] || continue
            ( . "$file"; printf '%s\n  Executable: %s\n  Runner: %s\n  Prefix: %s\n  Runtime: %s\n\n' "''${GAME_NAME:-$(basename "$file")}" "$GAME_EXE" "$GAME_RUNNER_TYPE" "$GAME_PREFIX" "''${GAME_RUNTIME:-$DMM_RUNTIME}" )
          done)
          [ -n "$output" ] || output="No game profiles have been created."
          "$DIALOG" --msgbox "$output" 22 84
        }

        diagnostics() {
          local result=""
          [ -f "''${DMM_EXE:-}" ] && result+="[OK] DMM executable found\n" || result+="[MISSING] DMM executable: ''${DMM_EXE:-not configured}\n"
          [ -d "$DMM_PREFIX" ] && result+="[OK] Prefix directory exists\n" || result+="[INFO] Prefix will be created when needed\n"
          local executable
          executable=$(dmm_runner_executable "$DMM_RUNNER_TYPE" "''${DMM_RUNNER_PATH:-}") || executable=""
          [ -x "$executable" ] && result+="[OK] Runner is executable\n" || result+="[MISSING] Runner: $executable\n"
          result+="\nConfiguration: $CONFIG_FILE\nProfiles: $GAMES_DIR\nRuntime: $DMM_RUNTIME"
          "$DIALOG" --msgbox "$result" 18 82
        }

        advanced_settings() {
          local debug
          debug=$("$DIALOG" --stdout --title "Debug logging" \
            --menu "Enable verbose Wine / Proton logging?" 10 60 2 \
            false "Disabled" true "Enabled") || return
          dmm_save_value "$CONFIG_FILE" DMM_DEBUG "$debug"
          DMM_DEBUG="$debug"
          info "Advanced settings saved."
        }

        main_menu() {
          while true; do
            local choice
            choice=$("$DIALOG" --clear --stdout --title "DMM Manager" \
              --menu "Manage DMM Game Player and your game profiles.\nConfiguration is saved automatically." \
              19 78 8 \
              launch "Launch DMM Game Player" \
              profiles "Manage game profiles" \
              settings "General settings" \
              diagnostics "System diagnostics" \
              advanced "Advanced settings" \
              quit "Save and exit") || break

            case "$choice" in
              launch)
                if [ -f "''${DMM_EXE:-}" ]; then
                  "$DIALOG" --yesno "Launch DMM Game Player now?" 7 55 && dmm
                else
                  info "DMM is not configured. Open General settings first."
                fi
                ;;
              profiles)
                local action
                action=$("$DIALOG" --stdout --title "Game profiles" \
                  --menu "Manage your configured games." 14 68 4 \
                  create "Add a game profile" \
                  edit "Edit an existing profile" \
                  list "View configured games" \
                  delete "Remove a profile") || continue
                case "$action" in
                  create) create_game ;;
                  edit) edit_game ;;
                  list) list_games ;;
                  delete) delete_game ;;
                esac
                ;;
              settings) edit_global ;;
              diagnostics) diagnostics ;;
              advanced) advanced_settings ;;
              quit) break ;;
            esac
          done
        }

        main_menu
      '';

      dmmDoctor = pkgs.writeShellScriptBin "dmm-doctor" ''
        . ${common}
        check_file() { [ -f "$1" ] && echo "OK" || echo "MISSING"; }
        check_dir() { [ -d "$1" ] && echo "OK" || echo "NOT CREATED"; }

        printf '%s\n' "DMM Manager diagnostics" "======================="
        printf 'Configuration : %s\n' "$CONFIG_FILE"
        printf 'DMM executable: %s (%s)\n' "''${DMM_EXE:-not configured}" "$(check_file "''${DMM_EXE:-}")"
        printf 'Prefix        : %s (%s)\n' "$DMM_PREFIX" "$(check_dir "$DMM_PREFIX")"
        printf 'Runner type   : %s\n' "$DMM_RUNNER_TYPE"
        printf 'Runner path   : %s\n' "''${DMM_RUNNER_PATH:-not configured}"
        runner=$(dmm_runner_executable "$DMM_RUNNER_TYPE" "''${DMM_RUNNER_PATH:-}") || runner=""
        printf 'Runner status : %s\n' "$( [ -x "$runner" ] && echo OK || echo MISSING )"
        printf 'Runtime       : %s\n' "$DMM_RUNTIME"
        printf '\nGame profiles\n-------------\n'
        found=false
        for file in "$GAMES_DIR"/*; do
          [ -f "$file" ] || continue
          found=true
          (
            . "$file"
            printf '%s\n' "''${GAME_NAME:-$(basename "$file")}"
            printf '  Executable: %s (%s)\n' "$GAME_EXE" "$(check_file "$GAME_EXE")"
            printf '  Runner    : %s (%s)\n' "$GAME_RUNNER_TYPE" "$(check_file "$(dmm_runner_executable "$GAME_RUNNER_TYPE" "$GAME_RUNNER_PATH")")"
            printf '  Prefix    : %s\n' "$GAME_PREFIX"
          )
        done
        [ "$found" = true ] || echo "No profiles configured."
      '';

      dmmStop = pkgs.writeShellScriptBin "dmm-stop" ''
        . ${common}
        stop_runner() {
          local type="$1" runner="$2" prefix="$3" executable server
          executable=$(dmm_runner_executable "$type" "$runner") || return 1
          case "$type" in
            wine)
              server="$(dirname "$executable")/wineserver"
              [ -x "$server" ] || { echo "Wine wineserver not found: $server"; return 1; }
              WINEPREFIX="$prefix" "$server" -k
              ;;
            proton)
              server="$(dirname "$executable")/files/bin/wineserver"
              [ -x "$server" ] || server="$(dirname "$executable")/files/bin/wineserver"
              [ -x "$server" ] || { echo "Proton wineserver not found."; return 1; }
              WINEPREFIX="$prefix/pfx" "$server" -k
              ;;
            *) echo "Stopping custom runners is not supported."; return 1 ;;
          esac
        }
        stop_runner "$DMM_RUNNER_TYPE" "$DMM_RUNNER_PATH" "$DMM_PREFIX"
      '';

      dmmInstall = pkgs.writeShellScriptBin "dmm-install" ''
        . ${common}
        if [ -z "''${1:-}" ]; then
          echo "Usage: dmm-install <installer.exe> [arguments...]" >&2
          exit 1
        fi
        dmm_launch "$DMM_RUNNER_TYPE" "$DMM_RUNNER_PATH" "$DMM_PREFIX" "$1" "$DMM_RUNTIME" "''${@:2}"
      '';

      dmmTricks = pkgs.writeShellScriptBin "dmm-tricks" ''
        . ${common}
        if [ "$DMM_RUNNER_TYPE" != wine ]; then
          echo "dmm-tricks currently requires a Wine runner." >&2
          exit 1
        fi
        runner=$(dmm_runner_executable wine "$DMM_RUNNER_PATH")
        export WINEPREFIX="$DMM_PREFIX"
        export WINE="$runner"
        export WINESERVER="$(dirname "$runner")/wineserver"
        dmm_runtime "$DMM_RUNTIME" ${pkgs.winetricks}/bin/winetricks "$@"
      '';

      desktop = pkgs.makeDesktopItem {
        name = "dmm";
        desktopName = "DMM Game Player";
        exec = "${dmm}/bin/dmm %u";
        categories = [ "Game" ];
        mimeTypes = [ "x-scheme-handler/dmmgameplayer" ];
      };
    in
    {
      environment.systemPackages = [
        dmm
        dmmGame
        dmmConfig
        dmmDoctor
        dmmStop
        dmmInstall
        dmmTricks
        desktop
        pkgs.dialog
        pkgs.steam-run
        pkgs.winetricks
        pkgs.xdg-utils
        pkgs.procps
      ];

      xdg.mime.defaultApplications."x-scheme-handler/dmmgameplayer" = "dmm.desktop";

      fonts.packages = [ pkgs.noto-fonts-cjk-sans ];
    };
}
