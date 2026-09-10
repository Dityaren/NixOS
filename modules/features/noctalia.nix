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

      noctaliaConfig = "${vars.flakeRoot}/modules/features/noctalia/settings.json";
    in
    {
      environment.systemPackages = [
        noctalia

        (pkgs.writeShellApplication {
          name = "noctalia-export";

          runtimeInputs = [
            pkgs.coreutils
            pkgs.gnugrep
            noctalia
          ];

          text = ''
            set -euo pipefail

            SOURCE="$HOME/.config/noctalia/settings.json"
            DEST="${noctaliaConfig}"

            echo "Exporting Noctalia Legacy configuration..."
            echo

            if [ ! -e "$SOURCE" ]; then
              echo "Error: Noctalia configuration not found:"
              echo "  $SOURCE"
              echo
              echo "Make sure Noctalia Shell is running and has created its configuration."
              exit 1
            fi

            if [ -L "$SOURCE" ]; then
              echo "Current configuration is Nix-managed:"
              echo "  $SOURCE -> $(readlink "$SOURCE")"
              echo
            fi

            mkdir -p "$(dirname "$DEST")"

            cp --dereference "$SOURCE" "$DEST"

            echo "Configuration exported successfully."
            echo
            echo "  Source:"
            echo "    $SOURCE"
            echo
            echo "  Destination:"
            echo "    $DEST"
            echo
            echo "The exported configuration is now part of your NixOS configuration."
            echo
            echo "Rebuild with:"
            echo "  sudo nixos-rebuild switch --flake ${vars.flakeRoot}#${vars.hostname}"
          '';
        })
      ];

      home-manager.users.${vars.username} = {
        imports = [
          inputs.noctalia.homeModules.default
        ];

        programs.noctalia-shell = {
          enable = true;

          settings = ./noctalia/settings.json;
        };
      };
    };
}
