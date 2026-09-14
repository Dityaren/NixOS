{ ... }:

{
  flake.nixosModules.i3wm =
    {
      vars,
      pkgs,
      ...
    }:
    let
      modifier = "Mod4";

      wallpaperPicker = pkgs.writeShellScriptBin "wallpaper-picker" ''
        set -e

        wallpaper_dir="$HOME/Pictures/Wallpapers"
        current_wallpaper="$HOME/.config/i3/current-wallpaper"

        mkdir -p "$wallpaper_dir"
        mkdir -p "$(dirname "$current_wallpaper")"

        if [ ! -d "$wallpaper_dir" ]; then
          notify-send "Wallpaper Picker" "Wallpaper directory not found"
          exit 1
        fi

        selected="$(
          find "$wallpaper_dir" -type f \
            \( \
              -iname "*.jpg" \
              -o -iname "*.jpeg" \
              -o -iname "*.png" \
              -o -iname "*.webp" \
              -o -iname "*.bmp" \
            \) \
          | sort \
          | while read -r file; do
              printf '%s\t%s\n' "$(basename "$file")" "$file"
            done \
          | ${pkgs.rofi}/bin/rofi \
              -dmenu \
              -i \
              -p "Wallpaper" \
              -no-custom \
              -display-columns 1 \
              -theme-str 'window { width: 50%; } listview { lines: 12; }'
        )"

        [ -z "$selected" ] && exit 0

        wallpaper="''${selected#*$'\t'}"

        if [ ! -f "$wallpaper" ]; then
          notify-send "Wallpaper Picker" "Selected wallpaper no longer exists"
          exit 1
        fi

        ln -sfn "$wallpaper" "$current_wallpaper"

        ${pkgs.feh}/bin/feh \
          --no-fehbg \
          --bg-fill \
          "$wallpaper"

        notify-send \
          -t 1500 \
          "Wallpaper" \
          "$(basename "$wallpaper")"
      '';
    in
    {
      services.xserver = {
        enable = true;

        windowManager.i3 = {
          enable = true;
          package = pkgs.i3;
        };
      };

      environment.systemPackages = with pkgs; [
        rofi
        feh
        brightnessctl
        i3status-rust
        xclip
        xsetroot
        libnotify
        wallpaperPicker
      ];

      home-manager.users.${vars.username} = {
        xsession.windowManager.i3 = {
          enable = true;

          config = {
            inherit modifier;

            terminal = "alacritty";
            menu = "rofi -show drun";

            fonts = {
              names = [ "JetBrainsMono Nerd Font" ];
              size = 10.0;
            };

            gaps = {
              inner = 8;
              outer = 4;
              smartGaps = true;
            };

            window = {
              border = 2;
              titlebar = false;
            };

            floating = {
              border = 2;
              titlebar = false;
            };

            focus = {
              followMouse = false;
              mouseWarping = false;
              newWindow = "smart";
            };

            workspaceLayout = "default";

            keybindings = {
              # Applications
              "${modifier}+Return" = "exec alacritty";

              "${modifier}+d" = "exec rofi -show drun";

              "${modifier}+Shift+d" = "exec rofi -show run";

              # Wallpaper
              "${modifier}+Shift+p" = "exec wallpaper-picker";

              # Window management
              "${modifier}+q" = "kill";

              "${modifier}+f" = "fullscreen toggle";

              "${modifier}+Shift+space" = "floating toggle";

              "${modifier}+space" = "focus mode_toggle";

              # Focus
              "${modifier}+h" = "focus left";

              "${modifier}+j" = "focus down";

              "${modifier}+k" = "focus up";

              "${modifier}+l" = "focus right";

              # Focus with arrows
              "${modifier}+Left" = "focus left";

              "${modifier}+Down" = "focus down";

              "${modifier}+Up" = "focus up";

              "${modifier}+Right" = "focus right";

              # Move containers
              "${modifier}+Shift+h" = "move left";

              "${modifier}+Shift+j" = "move down";

              "${modifier}+Shift+k" = "move up";

              "${modifier}+Shift+l" = "move right";

              # Move containers with arrows
              "${modifier}+Shift+Left" = "move left";

              "${modifier}+Shift+Down" = "move down";

              "${modifier}+Shift+Up" = "move up";

              "${modifier}+Shift+Right" = "move right";

              # Split
              "${modifier}+b" = "split horizontal";

              "${modifier}+v" = "split vertical";

              # Layout
              "${modifier}+s" = "layout stacking";

              "${modifier}+w" = "layout tabbed";

              "${modifier}+e" = "layout toggle split";

              # Resize
              "${modifier}+r" = "mode resize";

              # Workspaces
              "${modifier}+1" = "workspace number 1";

              "${modifier}+2" = "workspace number 2";

              "${modifier}+3" = "workspace number 3";

              "${modifier}+4" = "workspace number 4";

              "${modifier}+5" = "workspace number 5";

              "${modifier}+6" = "workspace number 6";

              "${modifier}+7" = "workspace number 7";

              "${modifier}+8" = "workspace number 8";

              "${modifier}+9" = "workspace number 9";

              "${modifier}+0" = "workspace number 10";

              # Move to workspaces
              "${modifier}+Shift+1" = "move container to workspace number 1";

              "${modifier}+Shift+2" = "move container to workspace number 2";

              "${modifier}+Shift+3" = "move container to workspace number 3";

              "${modifier}+Shift+4" = "move container to workspace number 4";

              "${modifier}+Shift+5" = "move container to workspace number 5";

              "${modifier}+Shift+6" = "move container to workspace number 6";

              "${modifier}+Shift+7" = "move container to workspace number 7";

              "${modifier}+Shift+8" = "move container to workspace number 8";

              "${modifier}+Shift+9" = "move container to workspace number 9";

              "${modifier}+Shift+0" = "move container to workspace number 10";

              # i3 control
              "${modifier}+Shift+r" = "restart";

              "${modifier}+Shift+q" = "exec i3-msg exit";

              # Audio
              "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";

              "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";

              "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

              # Brightness
              "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";

              "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
            };

            modes = {
              resize = {
                "h" = "resize shrink width 10 px or 10 ppt";

                "j" = "resize grow height 10 px or 10 ppt";

                "k" = "resize shrink height 10 px or 10 ppt";

                "l" = "resize grow width 10 px or 10 ppt";

                "Left" = "resize shrink width 10 px or 10 ppt";

                "Down" = "resize grow height 10 px or 10 ppt";

                "Up" = "resize shrink height 10 px or 10 ppt";

                "Right" = "resize grow width 10 px or 10 ppt";

                "Return" = "mode default";

                "Escape" = "mode default";
              };
            };

            colors = {
              focused = {
                border = "#89b4fa";
                background = "#89b4fa";
                text = "#11111b";
                indicator = "#89b4fa";
                childBorder = "#89b4fa";
              };

              focusedInactive = {
                border = "#313244";
                background = "#181825";
                text = "#cdd6f4";
                indicator = "#313244";
                childBorder = "#313244";
              };

              unfocused = {
                border = "#242432";
                background = "#11111b";
                text = "#7f849c";
                indicator = "#242432";
                childBorder = "#242432";
              };

              urgent = {
                border = "#f38ba8";
                background = "#f38ba8";
                text = "#11111b";
                indicator = "#f38ba8";
                childBorder = "#f38ba8";
              };
            };

            bars = [
              {
                position = "bottom";

                statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-main.toml";

                workspaceButtons = true;
                workspaceNumbers = true;
                trayOutput = "primary";

                fonts = {
                  names = [ "JetBrainsMono Nerd Font" ];
                  size = 10.0;
                };

                colors = {
                  background = "#11111b";
                  statusline = "#cdd6f4";

                  focusedWorkspace = {
                    border = "#89b4fa";
                    background = "#89b4fa";
                    text = "#11111b";
                  };

                  activeWorkspace = {
                    border = "#313244";
                    background = "#181825";
                    text = "#cdd6f4";
                  };

                  inactiveWorkspace = {
                    border = "#11111b";
                    background = "#11111b";
                    text = "#7f849c";
                  };

                  urgentWorkspace = {
                    border = "#f38ba8";
                    background = "#f38ba8";
                    text = "#11111b";
                  };
                };
              }
            ];

            startup = [
              {
                command = "xsetroot -cursor_name left_ptr";

                notification = false;
              }

              {
                command = "test -e $HOME/.config/i3/current-wallpaper && feh --no-fehbg --bg-fill $HOME/.config/i3/current-wallpaper";

                notification = false;
              }
            ];
          };

          extraConfig = ''
            focus_follows_mouse no
            mouse_warping none
            focus_on_window_activation smart

            for_window [window_type="dialog"] floating enable
            for_window [window_type="utility"] floating enable

            default_border pixel 2
            default_floating_border pixel 2
          '';
        };

        programs.i3status-rust = {
          enable = true;

          bars.main = {
            settings = {
              theme = {
                theme = "plain";
              };

              icons = {
                icons = "awesome6";
              };
            };

            blocks = [
              {
                block = "cpu";
                interval = 2;
                format = " CPU $utilization ";
              }

              {
                block = "memory";
                interval = 2;
                format = " RAM $mem_used/$mem_total ";
              }

              {
                block = "battery";
                interval = 10;
                format = " BAT $percentage ";
              }

              {
                block = "time";
                interval = 1;
                format = " $timestamp.datetime(f:'%H:%M') ";
              }
            ];
          };
        };
      };
    };
}
