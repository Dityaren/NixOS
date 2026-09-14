{
  self,
  ...
}:
{
  flake.nixosModules.hostConfiguration =
    {
      pkgs,
      vars,
      lib,
      ...
    }:
    {
      imports = [
        self.nixosModules.snowHardware
        self.nixosModules.home-manager
        self.nixosModules.niri
        self.nixosModules.nvidia
        self.nixosModules.ly
        self.nixosModules.xdg
        self.nixosModules.nixvim
        self.nixosModules.spicetify
        self.nixosModules.onlyoffice
        self.nixosModules.steam
        self.nixosModules.screenshot
        self.nixosModules.fish
        self.nixosModules.alacritty
        self.nixosModules.zen-browser
        self.nixosModules.noctalia
        self.nixosModules.power-management
        self.nixosModules.tmux
        self.nixosModules.i3wm

      ];

      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [
            "root"
            "${vars.username}"
          ];
        };

      };

      nixpkgs.config.allowUnfree = true;

      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };

        kernelPackages = pkgs.linuxPackages_latest;
        supportedFilesystems = [
          "ntfs"
          "exfat"
        ];
      };

      networking = {
        hostName = vars.hostname;
        networkmanager.enable = true;
        nameservers = [
          "9.9.9.9"
          "149.112.112.112"
          "2620:fe::fe"
          "2620:fe::9"
        ];
      };

      time.timeZone = "Asia/Jakarta";

      i18n.defaultLocale = "en_US.UTF-8";

      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      users = {

        users.${vars.username} = {
          isNormalUser = true;
          description = "User ${vars.username}";

          shell = pkgs.fish;

          extraGroups = [
            "networkmanager"
            "wheel"
            "docker"
          ];
        };
      };

      virtualisation = {
        docker = {
          enable = true;

          rootless = {
            enable = true;
            setSocketVariable = true;
          };
        };

        podman.enable = true;
      };

      programs.fish.enable = true;

      services.udev.extraRules = ''
        SUBSYSTEM=="platform", KERNEL=="VPC2004:00", \
          RUN+="${pkgs.coreutils}/bin/chgrp lenovoctl /sys%p/conservation_mode", \
          RUN+="${pkgs.coreutils}/bin/chmod 664 /sys%p/conservation_mode"
      '';

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      environment = {
        systemPackages = with pkgs; [
          nodejs
          pnpm
          kitty
          obsidian
          jq
          temurin-bin
          easyeffects
          sioyek
          devenv
          obs-studio
          vim
          wget
          git
          alacritty
          tmux
          docker-compose
          dbeaver-bin
        ];

        variables = {
          EDITOR = "vim";
          BROWSER = "zen-beta";
        };
      };

      fonts.packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
        nerd-fonts.fira-mono
        nerd-fonts.symbols-only
        corefonts
        vista-fonts
      ];

      # onlyoffice has trouble with symlinks: https://github.com/ONLYOFFICE/DocumentServer/issues/1859
      system.userActivationScripts = {
        copy-fonts-local-share = {
          text = ''
            rm -rf ~/.local/share/fonts
            mkdir -p ~/.local/share/fonts
            cp ${pkgs.corefonts}/share/fonts/truetype/* ~/.local/share/fonts/
            chmod 544 ~/.local/share/fonts
            chmod 444 ~/.local/share/fonts/*
          '';
        };
      };

      swapDevices = [
        {
          device = "/swapfile";
          size = 16 * 1024;
        }
      ];
      zramSwap.enable = true;
      system.stateVersion = vars.stateVersion;
    };
}
