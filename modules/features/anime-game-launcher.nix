{ self, inputs, ... }:

{
  flake.nixosModules.anime-game-launcher =
    { vars, pkgs, ... }:
    {
      imports = [
        inputs.aagl.nixosModules.default
      ];

      nix.settings = inputs.aagl.nixConfig;
      programs.anime-game-launcher.enable = true;
    };
}
