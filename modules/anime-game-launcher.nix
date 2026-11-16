{ self, inputs, ... }:

{
  flake.nixosModules.anime-game-launcher =
    { vars, pkgs, ... }:
    {
      imports = [
        inputs.aagl.nixosModules.default
      ];

      programs.anime-game-launcher.enable = true;
    };
}
