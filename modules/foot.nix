{ ... }:

{
  flake.nixosModules.foot =
    { vars, ... }:
    {
      home-manager.users.${vars.username} = {
        programs.foot = {
          enable = true;

          settings = {
            main = {
              term = "xterm-256color";
              dpi-aware = "no";
              pad = "12x12";
            };

            "colors-dark" = {
              alpha-mode = "all";
              blur = "yes";
            };

            cursor = {
              style = "beam";
              blink = "no";
            };

            mouse.hide-when-typing = "yes";

            scrollback.lines = 10000;

            key-bindings = {
              clipboard-copy = "Control+Shift+c";
              clipboard-paste = "Control+Shift+v";
              search-start = "Control+Shift+r";
              font-increase = "Control+plus Control+equal";
              font-decrease = "Control+minus";
              font-reset = "Control+0";
            };
          };
        };
      };
    };
}
