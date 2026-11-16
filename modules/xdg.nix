{ ... }:
{
  flake.nixosModules.xdg =
    { pkgs, ... }:
    {
      xdg = {
        mime = {
          enable = true;

          defaultApplications = {
            "inode/directory" = "org.gnome.Nautilus.desktop";
            "application/zip" = "org.gnome.FileRoller.desktop";
            "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
            "image/png" = "org.gnome.Loupe.desktop";
            "image/jpeg" = "org.gnome.Loupe.desktop";
            "image/webp" = "org.gnome.Loupe.desktop";
            "application/pdf" = "org.gnome.Evince.desktop";
          };
        };

        portal = {
          enable = true;
          xdgOpenUsePortal = true;

          wlr = {
            enable = true;
            settings.screencast = {
              chooser_type = "simple";
              chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -ro";
            };
          };
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

          config.common = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
          };
        };
      };

      programs = {
        dconf.enable = true;

        nautilus-open-any-terminal = {
          enable = true;
          terminal = "alacritty";
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
        alacritty
        nautilus
        file-roller
        unzip
        zip
        p7zip
        xdg-utils
        ffmpegthumbnailer
        ntfs3g
        exfatprogs
        loupe
        evince
      ];
    };
}
