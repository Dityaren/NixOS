{ self, inputs, ... }: {
  flake.nixosModules.steam = { pkgs, ... }: {
    programs = {
      steam = {
        enable = true;

        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };

      gamemode.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # Steam
      steam-run
      protonup-qt

      # Non-Steam launchers
      heroic

      # Gaming utilities
      gamescope
      mangohud
      goverlay
    ];
  };
}
