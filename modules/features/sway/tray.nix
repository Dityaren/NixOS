{ ... }:
{
  flake.nixosModules.sway-tray =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      nm = config.networking.networkmanager.enable;
      bt = config.services.blueman.enable;
    in
    {
      environment.systemPackages = [
        pkgs.adwaita-icon-theme
      ]
      ++ lib.optional nm pkgs.networkmanagerapplet;

      environment.etc."sway/config.d/25-tray.conf".text =
        lib.optionalString nm ''
          exec ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator
        ''
        + lib.optionalString bt ''
          exec ${pkgs.blueman}/bin/blueman-applet
        '';
    };
}
