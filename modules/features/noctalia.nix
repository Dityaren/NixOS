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

            DEST="${vars.flakeRoot}modules/features/noctalia/settings.json"
            DEST_DIR="$(dirname "$DEST")"

            RAW_TMP="$(mktemp "$DEST_DIR/.noctalia-settings.XXXXXX")"
            JSON_TMP="$(mktemp "$DEST_DIR/.noctalia-settings.XXXXXX")"

            cleanup() {
              rm -f "$RAW_TMP" "$JSON_TMP"
            }

            trap cleanup EXIT

            echo "Exporting current Noctalia settings..."
            echo

            # ------------------------------------------------------------
            # Check that Noctalia is running
            # ------------------------------------------------------------

            if ! noctalia-shell ipc call state all >/dev/null 2>&1; then
              echo "Error: Noctalia Shell is not running or IPC is unavailable."
              echo
              echo "Start Noctalia Shell before running noctalia-export."
              exit 1
            fi

            # ------------------------------------------------------------
            # Get the current runtime state
            # ------------------------------------------------------------

            echo "Reading settings from Noctalia..."

            if ! noctalia-shell ipc call state all > "$RAW_TMP"; then
              echo
              echo "Error: Failed to retrieve Noctalia state."
              echo "Existing configuration was NOT changed."
              exit 1
            fi

            # ------------------------------------------------------------
            # Make sure .settings exists and is an object
            # ------------------------------------------------------------

            if ! jq -e '.settings | type == "object"' "$RAW_TMP" >/dev/null; then
              echo
              echo "Error: Noctalia returned an invalid settings object."
              echo "Expected .settings to be a JSON object."
              echo
              echo "Existing configuration was NOT changed."
              exit 1
            fi

            # ------------------------------------------------------------
            # Extract and pretty-print the settings
            # ------------------------------------------------------------

            if ! jq '.settings' "$RAW_TMP" > "$JSON_TMP"; then
              echo
              echo "Error: Failed to generate settings.json."
              echo "Existing configuration was NOT changed."
              exit 1
            fi

            # ------------------------------------------------------------
            # Final JSON validation
            # ------------------------------------------------------------

            if ! jq empty "$JSON_TMP" >/dev/null; then
              echo
              echo "Error: Generated settings.json is invalid JSON."
              echo "Existing configuration was NOT changed."
              exit 1
            fi

            # ------------------------------------------------------------
            # Replace the declarative source
            # ------------------------------------------------------------

            mv -f "$JSON_TMP" "$DEST"

            echo
            echo "Noctalia configuration exported successfully."
            echo
            echo "  $DEST"
            echo
            echo "The configuration was:"
            echo "  ✓ Retrieved from the running Noctalia instance"
            echo "  ✓ Validated as JSON"
            echo "  ✓ Validated as a JSON object"
            echo "  ✓ Pretty-printed with jq"
            echo "  ✓ Atomically written to the NixOS dotfiles"
            echo
            echo "The Home Manager configuration has NOT been rebuilt."
            echo "Run nixos-rebuild when you want this configuration"
            echo "to become the new declarative state."
            echo
            echo "Review the changes with:"
            echo
            echo "  git diff -- modules/features/noctalia/settings.json"
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
      };
    };
}
