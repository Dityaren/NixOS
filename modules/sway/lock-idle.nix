{ ... }:
{
  flake.nixosModules.sway-lock-idle =
    { config, pkgs, ... }:
    let
      c = config.lib.stylix.colors;
      font = config.stylix.fonts;
      lock = "${pkgs.swaylock}/bin/swaylock -f -C /etc/swaylock/config";
      swaymsg = "${pkgs.sway}/bin/swaymsg";
    in
    {
      environment.systemPackages = [
        pkgs.swaylock
        pkgs.swayidle
      ];

      # PAM service to verify password.
      security.pam.services.swaylock = { };

      environment.etc."swaylock/config".text = ''
        font=${font.monospace.name}
        color=${c.base00}
        text-color=${c.base05}
        inside-color=${c.base00}
        inside-clear-color=${c.base0A}
        inside-ver-color=${c.base0D}
        inside-wrong-color=${c.base08}
        ring-color=${c.base03}
        ring-clear-color=${c.base0A}
        ring-ver-color=${c.base0D}
        ring-wrong-color=${c.base08}
        key-hl-color=${c.base0D}
        bs-hl-color=${c.base08}
        line-color=${c.base00}
        separator-color=${c.base00}
        indicator-radius=60
        indicator-thickness=6
        ignore-empty-password
        show-failed-attempts
      '';

      environment.etc."sway/config.d/40-lock-idle.conf".text = ''
        bindsym $mod+Alt+l exec loginctl lock-session

        # Do not lock or blank while something is fullscreen (video, presentations).
        for_window [shell=".*"] inhibit_idle fullscreen

        exec swayidle -w \
          timeout 300 '${lock}' \
          timeout 600 '${swaymsg} "output * power off"' resume '${swaymsg} "output * power on"' \
          timeout 1200 'systemctl suspend' \
          lock '${lock}' \
          before-sleep '${lock}'
      '';
    };
}
