{ pkgs, ... }:

{
  flake.nixosModules.alacritty =
    {
      vars,
      pkgs,
      ...
    }:
    {
      home-manager.users.${vars.username} = {
        programs.alacritty = {
          enable = true;

          settings = {
            window = {
              opacity = 0.8;
              blur = true;
            };

            font = {
              size = 18;
            };
          };
        };

        xdg.configFile."alacritty/alacritty.toml".force = true;
      };
    };
}
