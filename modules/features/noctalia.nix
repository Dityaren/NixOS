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

      noctaliaConfig = ./noctalia/settings.json;
    in
    {
      environment.systemPackages = [
        noctalia

        (pkgs.writeShellApplication {
          name = "noctalia-export";

          runtimeInputs = [
            noctalia
            pkgs.coreutils
            pkgs.jq
          ];

          text = ''
            set -euo pipefail

            DEST="${vars.flakeRoot}/modules/features/noctalia/settings.json"
            DEST_DIR="$(dirname "$DEST")"

            RAW_TMP="$(mktemp "$DEST_DIR/.noctalia-settings.XXXXXX")"
            JSON_TMP="$(mktemp "$DEST_DIR/.noctalia-settings.XXXXXX")"

            cleanup() {
              rm -f "$RAW_TMP" "$JSON_TMP"
            }

            trap cleanup EXIT

            echo "Exporting current Noctalia settings..."
            echo

            if ! noctalia-shell ipc call state all >/dev/null 2>&1; then
              echo "Error: Noctalia Shell is not running or IPC is unavailable."
              echo
              echo "Start Noctalia Shell before running noctalia-export."
              exit 1
            fi

            echo "Reading settings from Noctalia..."

            if ! noctalia-shell ipc call state all > "$RAW_TMP"; then
              echo
              echo "Error: Failed to retrieve Noctalia state."
              echo "Existing configuration was NOT changed."
              exit 1
            fi

            if ! jq -e '.settings | type == "object"' "$RAW_TMP" >/dev/null; then
              echo
              echo "Error: Noctalia returned an invalid settings object."
              echo "Expected .settings to be a JSON object."
              echo
              echo "Existing configuration was NOT changed."
              exit 1
            fi

            if ! jq '.settings' "$RAW_TMP" > "$JSON_TMP"; then
              echo
              echo "Error: Failed to generate settings.json."
              echo "Existing configuration was NOT changed."
              exit 1
            fi

            if ! jq empty "$JSON_TMP" >/dev/null; then
              echo
              echo "Error: Generated settings.json is invalid JSON."
              echo "Existing configuration was NOT changed."
              exit 1
            fi

            mv -f "$JSON_TMP" "$DEST"

            echo
            echo "Noctalia configuration exported successfully."
            echo
            echo "  $DEST"
            echo
            echo "Review the changes with:"
            echo
            echo "  git diff -- modules/features/noctalia/settings.json"
            echo
            echo "Run nixos-rebuild when you want this configuration"
            echo "to become the new declarative state."
          '';
        })
      ];

      home-manager.users.${vars.username} = {
        imports = [
          inputs.noctalia.homeModules.default
        ];

        programs.noctalia-shell = {
          enable = true;
          settings = noctaliaConfig;
        };

        home.activation.restartNoctalia = inputs.home-manager.lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          if command -v noctalia-shell >/dev/null 2>&1; then
            if noctalia-shell ipc call state all >/dev/null 2>&1; then
              echo "Restarting Noctalia Shell..."

              pkill -x noctalia-shell || true

              sleep 0.3

              if command -v niri >/dev/null 2>&1; then
                niri msg action spawn -- noctalia-shell >/dev/null 2>&1 || true
              fi
            fi
          fi
        '';
      };
    };
}
