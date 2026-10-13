{ inputs, ... }:

{
  flake.nixosModules.foot =
    { pkgs, vars, ... }:
    let
      fallbackColors = pkgs.writeText "foot-colors.ini" ''
        [colors-dark]
        background=1e1e2e
        foreground=cdd6f4
        regular0=45475a
        regular1=f38ba8
        regular2=a6e3a1
        regular3=f9e2af
        regular4=89b4fa
        regular5=f5c2e7
        regular6=94e2d5
        regular7=bac2de
        bright0=585b70
        bright1=f38ba8
        bright2=a6e3a1
        bright3=f9e2af
        bright4=89b4fa
        bright5=f5c2e7
        bright6=94e2d5
        bright7=a6adc8
      '';
    in
    {
      environment.systemPackages = [
        pkgs.foot
        pkgs.matugen
      ];

      home-manager.users.${vars.username} =
        { config, lib, ... }:
        let
          footColors = "${config.xdg.cacheHome}/matugen/foot-colors.ini";
        in
        {
          home.packages = [
            pkgs.nerd-fonts.jetbrains-mono
          ];

          home.activation.seedFootColors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [ ! -e "${footColors}" ]; then
              ${pkgs.coreutils}/bin/install -Dm644 ${fallbackColors} "${footColors}"
            fi
          '';

          xdg.configFile = {
            "matugen/config.toml".text = ''
              [templates.foot]
              input_path = "${config.xdg.configHome}/matugen/templates/foot-colors.ini"
              output_path = "${footColors}"
            '';

            "matugen/templates/foot-colors.ini".text = ''
              [colors-dark]
              background={{colors.surface.default.hex_stripped}}
              foreground={{colors.on_surface.default.hex_stripped}}
              regular0={{colors.surface_container_highest.default.hex_stripped}}
              regular1={{colors.error.default.hex_stripped}}
              regular2={{colors.tertiary.default.hex_stripped}}
              regular3={{colors.secondary.default.hex_stripped}}
              regular4={{colors.primary.default.hex_stripped}}
              regular5={{colors.tertiary_container.default.hex_stripped}}
              regular6={{colors.secondary_container.default.hex_stripped}}
              regular7={{colors.on_surface.default.hex_stripped}}
              bright0={{colors.outline.default.hex_stripped}}
              bright1={{colors.error.default.hex_stripped}}
              bright2={{colors.tertiary.default.hex_stripped}}
              bright3={{colors.secondary.default.hex_stripped}}
              bright4={{colors.primary.default.hex_stripped}}
              bright5={{colors.tertiary_container.default.hex_stripped}}
              bright6={{colors.secondary_container.default.hex_stripped}}
              bright7={{colors.on_surface.default.hex_stripped}}
            '';
          };

          programs.foot = {
            enable = true;

            settings = {
              main = {
                term = "xterm-256color";
                font = "JetBrainsMono Nerd Font:size=18";
                dpi-aware = "no";
                pad = "12x12";
                include = footColors;
              };

              "colors-dark" = {
                alpha = 0.88;
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
