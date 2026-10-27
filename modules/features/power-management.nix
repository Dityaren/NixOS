{ lib, ... }:
{
  flake.nixosModules.power-management = {
    services.power-profiles-daemon.enable = true;

    services.upower.enable = lib.mkDefault true;

    networking.networkmanager.wifi.powersave = false;
  };
}
