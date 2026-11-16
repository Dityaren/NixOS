{ ... }:
{
  flake.nixosModules.sway-launcher =
    { config, pkgs, ... }:
    let
      c = config.lib.stylix.colors;
      font = config.stylix.fonts;
    in
    {
      environment.systemPackages = [ pkgs.fuzzel ];

      environment.etc."fuzzel/fuzzel.ini".text = ''
        [main]
        font=${font.monospace.name}:size=${toString font.sizes.popups}
        terminal=${pkgs.foot}/bin/foot -e
        icons-enabled=no
        prompt="> "
        width=40
        lines=10

        [colors]
        background=${c.base00}f2
        text=${c.base05}ff
        match=${c.base0D}ff
        selection=${c.base02}ff
        selection-text=${c.base05}ff
        selection-match=${c.base0D}ff
        border=${c.base0D}ff

        [border]
        width=2
        radius=0
      '';

      environment.etc."sway/config.d/30-launcher.conf".text = ''
        bindsym $mod+d exec ${pkgs.fuzzel}/bin/fuzzel --config /etc/fuzzel/fuzzel.ini
      '';
    };
}
