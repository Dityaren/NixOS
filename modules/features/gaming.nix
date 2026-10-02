{ self, inputs, ... }: {
  flake.nixosModules.gaming =
    { pkgs, ... }:
    {
      programs = {
        gamemode.enable = true;
      };

      environment.systemPackages = with pkgs; [
        # protonup-qt
        # gamescope
        # mangohud
        # goverlay
        vulkan-tools
        vulkan-loader
        vulkan-validation-layers
        # mesa
        wineWow64Packages.stable
        winetricks
      ];
    };
}
