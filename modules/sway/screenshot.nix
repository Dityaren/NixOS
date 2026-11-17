{ ... }:
{
  flake.nixosModules.sway-screenshot =
    { config, pkgs, ... }:
    let
      c = config.lib.stylix.colors;
      swaymsg = "${pkgs.sway}/bin/swaymsg";
      jq = "${pkgs.jq}/bin/jq";

      screenshot = pkgs.writeShellScriptBin "screenshot" ''
        mode="''${1:-region}"
        edit="''${2:-}"

        dir="$HOME/Pictures/Screenshots"
        mkdir -p "$dir"
        file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

        geom=""
        out=""
        case "$mode" in
          region)
            geom=$(${pkgs.slurp}/bin/slurp -b ${c.base00}66 -c ${c.base0D}ff -s ${c.base0D}33 -w 2) || exit 0
            ;;
          window)
            geom=$(${swaymsg} -t get_tree | ${jq} -r '.. | objects | select(.focused == true) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | head -n1)
            [ -n "$geom" ] || exit 1
            ;;
          screen)
            out=$(${swaymsg} -t get_outputs | ${jq} -r '.[] | select(.focused == true) | .name' | head -n1)
            ;;
        esac

        capture() {
          if [ -n "$geom" ]; then
            ${pkgs.grim}/bin/grim -g "$geom" -
          elif [ -n "$out" ]; then
            ${pkgs.grim}/bin/grim -o "$out" -
          else
            ${pkgs.grim}/bin/grim -
          fi
        }

        if [ "$edit" = "edit" ]; then
          capture | ${pkgs.satty}/bin/satty --filename - --output-filename "$file" \
            --copy-command ${pkgs.wl-clipboard}/bin/wl-copy --early-exit
        else
          capture | tee "$file" | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png
          ${pkgs.libnotify}/bin/notify-send -i "$file" "Screenshot saved" "$file"
        fi
      '';
    in
    {
      environment.systemPackages = [ screenshot ];

      environment.etc."sway/config.d/50-screenshot.conf".text = ''
        # Print = region, Ctrl+Print = full screen, Mod+Print = active window.
        # Add Shift to any of them to open the editor.
        bindsym Print exec ${screenshot}/bin/screenshot region
        bindsym Ctrl+Print exec ${screenshot}/bin/screenshot screen
        bindsym $mod+Print exec ${screenshot}/bin/screenshot window

        bindsym Shift+Print exec ${screenshot}/bin/screenshot region edit
        bindsym Ctrl+Shift+Print exec ${screenshot}/bin/screenshot screen edit
        bindsym $mod+Shift+Print exec ${screenshot}/bin/screenshot window edit
      '';
    };
}
