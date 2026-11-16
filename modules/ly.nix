{ self, inputs, ... }:
{
  flake.nixosModules.ly =
    {
      pkgs,
      vars,
      ...
    }:
    {
      services.displayManager.ly = {
        enable = true;

        settings = {
          animation = "none";

          bg = "0x00000000";
          fg = "0x00CDD6F4";
          border_fg = "0x00CBA6F7";
          error_fg = "0x01F38BA8";

          blank_box = true;
          hide_borders = false;

          text_in_center = true;

          box_position_h = 0.5;
          box_position_v = 0.5;

          margin_box_h = 2;
          margin_box_v = 1;

          clock = "%a %d %b  %H:%M";

          default_input = "login";
          type_username = false;

          numlock = false;

          shutdown_key = "F1";
          restart_key = "F2";

          asterisk = "*";

          shell = true;
        };
      };
    };
}
