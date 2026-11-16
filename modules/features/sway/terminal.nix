{ ... }:
{
  flake.nixosModules.sway-terminal =
    { config, pkgs, ... }:
    let
      c = config.lib.stylix.colors;
      font = config.stylix.fonts;
    in
    {
      environment.systemPackages = [ pkgs.foot ];

      environment.etc."foot/foot.ini".text = ''
        [main]
        font=${font.monospace.name}:size=${toString font.sizes.terminal}
        pad=8x8

        [colors-dark]
        alpha=${toString config.stylix.opacity.terminal}
        foreground=${c.base05}
        background=${c.base00}
        regular0=${c.base00}
        regular1=${c.base08}
        regular2=${c.base0B}
        regular3=${c.base0A}
        regular4=${c.base0D}
        regular5=${c.base0E}
        regular6=${c.base0C}
        regular7=${c.base05}
        bright0=${c.base03}
        bright1=${c.base08}
        bright2=${c.base0B}
        bright3=${c.base0A}
        bright4=${c.base0D}
        bright5=${c.base0E}
        bright6=${c.base0C}
        bright7=${c.base07}
      '';

      environment.etc."sway/config.d/10-terminal.conf".text = ''
        set $term ${pkgs.foot}/bin/footclient
        exec ${pkgs.foot}/bin/foot --server --config=/etc/foot/foot.ini
        bindsym $mod+t exec $term
      '';
    };
}
