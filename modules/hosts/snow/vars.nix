{ ... }:
{
  flake.vars = {
    username = "lake";
    hostname = "snow";
    stateVersion = "26.05";
    flakeRoot = "/home/lake/dotfiles/nixos/";

    paths = {
      noctalia = {
        config = "/home/lake/dotfiles/nixos/modules/features/noctalia/config.toml";
      };
    };
  };
}
