{ self, inputs, ... }:
{
  flake.nixosModules.noctalia =
    {
      vars,
      pkgs,
      ...
    }:
    let
      noctalia = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      environment.systemPackages = [
        noctalia

        (pkgs.writeShellApplication {
          name = "noctalia-export";

          runtimeInputs = [
            pkgs.coreutils
          ];

          text = ''
            set -euo pipefail

            SOURCE="$HOME/.config/noctalia/config.toml"
            DEST="${vars.paths.noctalia.config}"

            if [ ! -f "$SOURCE" ]; then
              echo "Error: Noctalia configuration not found:"
              echo "  $SOURCE"
              echo
              echo "Make sure Noctalia Shell is running and has created its configuration."
              exit 1
            fi

            mkdir -p "$(dirname "$DEST")"

            echo "Exporting Noctalia configuration..."
            echo
            echo "  Source: $SOURCE"
            echo "  Target: $DEST"
            echo

            cp "$SOURCE" "$DEST"

            echo "✓ Noctalia configuration exported successfully."
            echo
            echo "Configuration:"
            echo "  $DEST"
            echo
            echo "Rebuild with:"
            echo "  sudo nixos-rebuild switch --flake ${vars.flakeRoot}#${vars.hostname}"
          '';
        })
      ];

      home-manager.users.${vars.username} = {
        xdg.configFile."noctalia/config.toml".source = ./noctalia/config.toml;
      };
    };
}
