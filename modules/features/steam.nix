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
      steam-run
      protonup-qt
      heroic
      gamescope
      mangohud
      goverlay
    ];
  };
}
