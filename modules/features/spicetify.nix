{ self, inputs, ... }: {
  flake.nixosModules.spicetify =
    { pkgs, lib, ... }:
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [ inputs.spicetify-nix.nixosModules.default ];

      programs.spicetify = {
        enable = true;

        # Native, up-to-date themes included directly in your flake packages
        theme = spicePkgs.themes.sleek;
        #colorScheme = "mocha"; # Options: latte, frappe, macchiato, mocha

        # Alternative Option (uncomment to switch to Comfy):
        # theme = spicePkgs.themes.comfy;
        # colorScheme = "Comfy";

        enabledExtensions = with spicePkgs.extensions; [
          adblock
          shuffle
          keyboardShortcut
          beautifulLyrics
        ];
      };
    };
}
