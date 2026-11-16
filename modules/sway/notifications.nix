{ ... }:
{
  flake.nixosModules.sway-notifications =
    { config, pkgs, ... }:
    let
      c = config.lib.stylix.colors.withHashtag;
      font = config.stylix.fonts;
    in
    {
      environment.systemPackages = [
        pkgs.mako
        pkgs.libnotify
      ];

      environment.etc."mako/config".text = ''
        font=${font.monospace.name} ${toString font.sizes.popups}
        background-color=${c.base00}
        text-color=${c.base05}
        border-color=${c.base0D}
        border-size=2
        border-radius=0
        padding=8
        width=320
        default-timeout=5000

        [urgency=high]
        border-color=${c.base08}
        default-timeout=0

        [mode=do-not-disturb]
        invisible=1
      '';

      environment.etc."sway/config.d/20-notifications.conf".text = ''
        exec ${pkgs.mako}/bin/mako --config /etc/mako/config
      '';
    };
}
