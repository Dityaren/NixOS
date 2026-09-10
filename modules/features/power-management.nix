{ ... }:

{
  flake.nixosModules.power-management = {
    # Laptop power profiles
    services.power-profiles-daemon.enable = true;

    # NixOS power management
    powerManagement.enable = true;

    # NetworkManager Wi-Fi power saving
    networking.networkmanager.wifi.powersave = true;
  };
}
