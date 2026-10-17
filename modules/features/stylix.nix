{ inputs, ... }:

{
  flake.nixosModules.stylix =
    {
      pkgs,
      lib,
      vars,
      ...
    }:
    let
      # Where DMS remembers the current wallpaper. The docs do not say, so verify on your
      # machine:  jq -r .wallpaperPath ~/.local/state/DankMaterialShell/session.json
      # If the file or the key differs, change these two lines.
      stateFile = "/home/${vars.username}/.local/state/DankMaterialShell/session.json";
      wallpaperKey = "wallpaperPath";

      # Reading files outside the flake only works with `nixos-rebuild --impure`.
      # `builtins.currentSystem` does not exist in pure evaluation, so use that to detect it.
      isImpure = builtins ? currentSystem;

      # The wallpaper DMS currently shows, copied into the store, or null if it cannot be found.
      dmsWallpaper =
        if isImpure && builtins.pathExists stateFile then
          let
            path = lib.removePrefix "file://" (
              (builtins.fromJSON (builtins.readFile stateFile)).${wallpaperKey} or ""
            );
          in
          if path != "" && builtins.pathExists path && builtins.readFileType path != "directory" then
            builtins.path {
              inherit path;
              name = lib.strings.sanitizeDerivationName (builtins.baseNameOf path);
            }
          else
            null
        else
          null;

      # Build-time matugen: render a base16 scheme from the wallpaper's Material You palette.
      # Roles are mapped by hand; matugen only has a few hue families (primary, secondary,
      # tertiary + error red), so syntax "green" or "yellow" is a tint of the wallpaper.
      mkMatugenScheme =
        image:
        pkgs.runCommand "matugen-base16.yaml" { nativeBuildInputs = [ pkgs.matugen ]; } ''
          export HOME="$TMPDIR"

          cat > template.yaml <<'EOF'
          scheme: "matugen"
          author: "matugen"
          base00: "{{colors.surface.default.hex_stripped}}"
          base01: "{{colors.surface_container.default.hex_stripped}}"
          base02: "{{colors.surface_container_high.default.hex_stripped}}"
          base03: "{{colors.outline.default.hex_stripped}}"
          base04: "{{colors.on_surface_variant.default.hex_stripped}}"
          base05: "{{colors.on_surface.default.hex_stripped}}"
          base06: "{{colors.on_surface.default.hex_stripped}}"
          base07: "{{colors.inverse_surface.default.hex_stripped}}"
          base08: "{{colors.error.default.hex_stripped}}"
          base09: "{{colors.tertiary.default.hex_stripped}}"
          base0A: "{{colors.secondary.default.hex_stripped}}"
          base0B: "{{colors.tertiary_fixed_dim.default.hex_stripped}}"
          base0C: "{{colors.secondary_fixed_dim.default.hex_stripped}}"
          base0D: "{{colors.primary.default.hex_stripped}}"
          base0E: "{{colors.primary_fixed_dim.default.hex_stripped}}"
          base0F: "{{colors.on_primary_container.default.hex_stripped}}"
          EOF

          cat > config.toml <<EOF
          [config]

          [templates.base16]
          input_path = "$PWD/template.yaml"
          output_path = "$out"
          EOF

          matugen image ${image} --mode dark --config config.toml --prefer=saturation
        '';

      # Used when the DMS wallpaper cannot be read (pure build, missing file, ...).
      fallbackScheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    in
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      stylix = {
        enable = true;
        autoEnable = true;
        polarity = "dark";

        image = dmsWallpaper;
        base16Scheme =
          if dmsWallpaper != null then
            "${mkMatugenScheme dmsWallpaper}"
          else
            lib.warnIf isImpure
              "stylix: could not read the DMS wallpaper from ${stateFile}; using the fallback scheme"
              fallbackScheme;

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

      # DMS keeps its own matugen running (shell UI recolors live when the wallpaper changes).
      # Stylix owns the app themes (GTK, Qt, foot, ...), so keep DMS's "Apply GTK/Qt Themes"
      # toggles off and do not include DMS's foot colors.
    };
}
