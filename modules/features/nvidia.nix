{ self, inputs, ... }: {
  flake.nixosModules.nvidia =
    {
      config,
      pkgs,
      ...
    }:
    {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
        };

        nvidia = {
          package = config.boot.kernelPackages.nvidiaPackages.stable;

          # RTX 3050 Mobile
          open = true;

          modesetting.enable = true;

          powerManagement = {
            enable = true;
            finegrained = true;
          };

          nvidiaSettings = true;

          prime = {
            offload = {
              enable = true;
              enableOffloadCmd = true;
            };

            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
          };
        };
      };

      boot.kernelParams = [
        "nvidia-drm.modeset=1"
      ];

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };
    };
}
