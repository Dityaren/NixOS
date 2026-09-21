{ self, inputs, ... }: {
  flake.nixosModules.steam =
    { pkgs, ... }:
    {
      programs = {
        steam = {
          enable = true;
          extraCompatPackages = [
            pkgs.dwproton-bin
          ];
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };

        gamemode.enable = true;
      };

      environment.systemPackages = with pkgs; [
        lutris
        steam-run
        protonup-qt
        gamescope
        mangohud
        goverlay
        vulkan-tools
        vulkan-loader
        vulkan-validation-layers
        mesa
        wineWow64Packages.stable
        winetricks
      ];
    };
}
