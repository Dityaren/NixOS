{ ... }:
{
  flake.nixosModules.power-management = {
    services.power-profiles-daemon.enable = true;
    powerManagement.enable = true;
    networking.networkmanager.wifi.powersave = true;
  };
}
