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
              opacity = 0.9;
              blur = true;
            };

            font = {
              normal = {
                family = "JetBrainsMono Nerd Font";
                style = "Regular";
              };
              bold = {
                family = "JetBrainsMono Nerd Font";
                style = "Bold";
              };
              italic = {
                family = "JetBrainsMono Nerd Font";
                style = "Italic";
              };
              bold_italic = {
                family = "JetBrainsMono Nerd Font";
                style = "Bold Italic";
              };
              size = 16;
            };
          };
        };

        xdg.configFile."alacritty/alacritty.toml".force = true;
      };
    };
}
