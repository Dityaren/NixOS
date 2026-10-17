{ inputs, ... }:

{
  flake.nixosModules.stylix =
    { pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      stylix = {
        enable = true;
        autoEnable = true;
        polarity = "dark";

        # Static scheme from the tinted-theming collection shipped in nixpkgs
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
        # DMS manages the wallpaper, so none is set here.
        # If evaluation asks for one, add: image = ./path/to/wallpaper.png;

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
          };
          sansSerif = {
            package = pkgs.noto-fonts;
            name = "Noto Sans";
          };
          serif = {
            package = pkgs.noto-fonts;
            name = "Noto Serif";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
          sizes = {
            terminal = 18;
            applications = 11;
            desktop = 11;
            popups = 11;
          };
        };

        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
          size = 24;
        };

        opacity.terminal = 0.88;
      };

      # Stop DMS from generating its own app themes (GTK/Qt/foot/nvim/...),
      # otherwise it fights with Stylix. If DMS ignores this, add the same
      # variable to its systemd unit: `systemctl --user edit dms`.
      environment.sessionVariables.DMS_DISABLE_MATUGEN = "1";
    };
}
