{ ... }:

{
  flake.nixosModules.alacritty =
    { vars, ... }:
    {
      home-manager.users.${vars.username} = {
        programs.alacritty = {
          enable = true;

          settings = {
            env.TERM = "xterm-256color";

            window = {
              padding = {
                x = 12;
                y = 12;
              };
              blur = true;
            };

            cursor.style = {
              shape = "Beam";
              blinking = "Never";
            };

            mouse.hide_when_typing = true;

            scrolling.history = 10000;

            keyboard.bindings = [
              {
                key = "C";
                mods = "Control|Shift";
                action = "Copy";
              }
              {
                key = "V";
                mods = "Control|Shift";
                action = "Paste";
              }
              {
                key = "R";
                mods = "Control|Shift";
                action = "SearchBackward";
              }
              {
                key = "Plus";
                mods = "Control";
                action = "IncreaseFontSize";
              }
              {
                key = "Equals";
                mods = "Control";
                action = "IncreaseFontSize";
              }
              {
                key = "Minus";
                mods = "Control";
                action = "DecreaseFontSize";
              }
              {
                key = "Key0";
                mods = "Control";
                action = "ResetFontSize";
              }
            ];
          };
        };
      };
    };
}
