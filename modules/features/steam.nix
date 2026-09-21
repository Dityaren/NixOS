{ self, inputs, ... }: {
  flake.nixosModules.steam = { pkgs, ... }: {
    programs = {
      steam = {
        enable = true;
        extraCompatPackages = [
          pkgs.dwproton-bin-dwproton
        ];
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };

      gamemode.enable = true;
    };

    environment.systemPackages = with pkgs; [
      steam-run
      protonup-qt
      gamescope
      mangohud
      goverlay
    ];
  };
}
