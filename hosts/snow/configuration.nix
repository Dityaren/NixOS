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
        self.nixosModules.hardware

        self.nixosModules.home-manager
        self.nixosModules.audio
        self.nixosModules.nvidia
        self.nixosModules.ly
        self.nixosModules.xdg
        self.nixosModules.nixcats
        self.nixosModules.spicetify
        self.nixosModules.gaming
        self.nixosModules.screenshot
        self.nixosModules.fish
        self.nixosModules.zen-browser
        self.nixosModules.power-management
        self.nixosModules.tmux
        self.nixosModules.anime-game-launcher
        self.nixosModules.sway
        self.nixosModules.stylix
        self.nixosModules.ffmpeg
        self.nixosModules.dmm
      ];

      nvim = {
        enable = true;
        packageNames = [ "nvim" ];
      };

      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        nodejs_24
        corepack_24
        stdenv.cc.cc
        openssl
        pkg-config
      ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
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
        networkmanager = {
          enable = true;
          plugins = with pkgs; [
            networkmanager-openvpn
          ];
        };
        nameservers = [
          "9.9.9.9"
          "149.112.112.112"
          "2620:fe::fe"
          "2620:fe::9"
        ];
      };

      programs.nm-applet.enable = true;

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
            "libvirtd"
          ];
        };
      };

      virtualisation = {
        libvirtd.enable = true;
        docker = {
          enable = true;

          rootless = {
            enable = true;
            setSocketVariable = true;
          };
        };

        podman.enable = true;
      };

      programs.obs-studio = {
        enable = true;
        package = pkgs.obs-studio.override {
          cudaSupport = true;
        };
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-pipewire-audio-capture
        ];
      };

      environment = {
        systemPackages = with pkgs; [
          # Development
          devenv
          gh
          git
          helix
          nodejs_24
          corepack_24
          pkg-config
          stdenv.cc.cc
          openssl

          # Desktop
          alacritty
          brightnessctl
          libreoffice
          sioyek

          # Multimedia
          alsa-utils
          legcord
          vlc

          # Virtualization
          qemu
          virt-manager
          docker-compose

          # Utilities
          jq
          nnn
          qbittorrent-enhanced
          sqlit-tui
          tmux
          wget
        ];

        variables = {
          BROWSER = "zen-beta";
          EDITOR = "vim";
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
          size = 2 * 1024;
        }
      ];
      zramSwap.enable = true;

      system.stateVersion = vars.stateVersion;
    };
}
