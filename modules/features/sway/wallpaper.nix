{ ... }:
{
  flake.nixosModules.sway-wallpaper =
    { config, pkgs, ... }:
    let
      image = config.stylix.image;
      swaymsg = "${pkgs.sway}/bin/swaymsg";

      wallpaper = pkgs.writeShellScriptBin "wallpaper" ''
        dir="''${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
        state="''${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper/session.json"

        apply() { ${swaymsg} "output * bg \"$1\" fill" >/dev/null; }

        case "''${1:-pick}" in
          restore)
            [ -f "$state" ] || exit 0
            img=$(sed -n 's/.*"wallpaperPath": *"\(.*\)".*/\1/p' "$state")
            [ -f "$img" ] && apply "$img"
            ;;
          pick)
            choice=$(find -L "$dir" -type f \
                \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
                | sort | sed "s|^$dir/||" \
                | ${pkgs.fuzzel}/bin/fuzzel --dmenu --config /etc/fuzzel/fuzzel.ini) || exit 0
            [ -n "$choice" ] || exit 0
            apply "$dir/$choice"
            mkdir -p "$(dirname "$state")"
            printf '{"wallpaperPath": "%s"}\n' "$dir/$choice" > "$state"
            ;;
        esac
      '';
    in
    {
      environment.systemPackages = [ wallpaper ];

      environment.etc."sway/config.d/05-wallpaper.conf".text =
        (
          if image != null then
            "output * bg ${image} fill\n"
          else
            "output * bg #${config.lib.stylix.colors.base00} solid_color\n"
        )
        + ''
          # Restore the last picked wallpaper (overrides the static one above).
          exec ${wallpaper}/bin/wallpaper restore
          bindsym $mod+Shift+w exec ${wallpaper}/bin/wallpaper
        '';
    };
}
