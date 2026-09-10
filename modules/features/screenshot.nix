{ self, inputs, ... }: {
  flake.nixosModules.screenshot = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      grim
      slurp
      satty
      wl-clipboard

      (writeShellScriptBin "screenshot-area" ''
        mkdir -p "$HOME/Pictures/Screenshots"

        grim -g "$(slurp)" - \
          | satty \
            --filename - \
            --output-filename "$HOME/Pictures/Screenshots/$(date +"%Y-%m-%d_%H-%M-%S").png" \
            --copy-command wl-copy
      '')

      (writeShellScriptBin "screenshot-screen" ''
        mkdir -p "$HOME/Pictures/Screenshots"

        grim \
          "$HOME/Pictures/Screenshots/$(date +"%Y-%m-%d_%H-%M-%S").png"
      '')

      (writeShellScriptBin "screenshot-copy" ''
        grim -g "$(slurp)" - | wl-copy
      '')
    ];
  };
}
