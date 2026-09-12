{ ... }: {
  flake.nixosModules.xdg = { pkgs, ... }: {
    xdg = {
      mime.enable = true;

      portal = {
        enable = true;
        xdgOpenUsePortal = true;

        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
        ];

        config = {
          common.default = [ "gnome" ];
        };
      };
    };

    programs = {
      dconf.enable = true;

      nautilus-open-any-terminal = {
        enable = true;
        terminal = "kitty";
      };
    };

    services = {
      gvfs.enable = true;
      udisks2.enable = true;

      gnome = {
        gnome-keyring.enable = true;
        sushi.enable = true;
      };

      tumbler.enable = true;
    };

    environment.systemPackages = with pkgs; [
      nautilus
      file-roller
      unzip
      zip
      p7zip
      xdg-utils
      ffmpegthumbnailer
      ntfs3g
      exfatprogs
      shared-mime-info
      desktop-file-utils
      loupe
      evince
    ];
  };
}
