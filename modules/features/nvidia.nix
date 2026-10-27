{ ... }:
{
  flake.nixosModules.nvidia =
    { config, ... }:
    {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
        };

        nvidia = {
          package = config.boot.kernelPackages.nvidiaPackages.stable;

          open = true;

          modesetting.enable = true;

          powerManagement = {
            enable = true;
            finegrained = false;
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

      environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/by-path/pci-0000:00:02.0-card";
    };
}
