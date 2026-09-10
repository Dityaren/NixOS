{ inputs, ... }:

let
  hmModule = inputs.home-manager.nixosModules.home-manager;
in
{
  flake.nixosModules.home-manager = { vars, ... }: {
    imports = [ hmModule ];

    home-manager.users.${vars.username}.home.stateVersion = vars.stateVersion;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
    };

  };
}
