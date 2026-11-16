{ ... }:
{
  flake.nixosModules.sway-bar =
    { config, pkgs, ... }:
    let
      c = config.lib.stylix.colors.withHashtag;
      font = config.stylix.fonts;

      status = pkgs.writeShellScript "bar-status" ''
        bat=""
        for b in /sys/class/power_supply/BAT*; do
          [ -r "$b/capacity" ] && bat="$b" && break
        done
        while true; do
          vol=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)
          case "$vol" in
            *MUTED*) out="vol mute" ;;
            *) out="vol $(echo "$vol" | ${pkgs.gawk}/bin/awk '{printf "%d", $2 * 100}')%" ;;
          esac
          if [ -n "$bat" ]; then
            [ "$(cat "$bat/status")" = "Charging" ] && sign="+" || sign=""
            out="$out | bat $(cat "$bat/capacity")%$sign"
          fi
          echo "$out | $(${pkgs.coreutils}/bin/date '+%a %d %b %H:%M')"
          sleep 5
        done
      '';
    in
    {
      environment.etc."sway/config.d/20-bar.conf".text = ''
        bar {
          id main
          position top
          mode dock
          status_command ${status}
          font pango:${font.monospace.name} ${toString font.sizes.desktop}
          tray_output *
          tray_padding 4
          # Left click opens the applet menu (swaybar's default is "Activate").
          tray_bindsym button1 ContextMenu
          colors {
            background ${c.base00}
            statusline ${c.base05}
            separator ${c.base03}
            focused_workspace ${c.base0D} ${c.base0D} ${c.base00}
            active_workspace ${c.base02} ${c.base02} ${c.base05}
            inactive_workspace ${c.base00} ${c.base00} ${c.base04}
            urgent_workspace ${c.base08} ${c.base08} ${c.base00}
          }
        }
      '';
    };
}
