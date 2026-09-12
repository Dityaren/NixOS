{ self, inputs, ... }: {
  flake.nixosModules.spicetify =
    { pkgs, lib, ... }:
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [
        inputs.spicetify-nix.nixosModules.default
      ];

      programs.spicetify = {
        enable = true;

        theme = spicePkgs.themes.text;

        colorScheme = "Kanagawa";

        enabledExtensions = with spicePkgs.extensions; [
          adblockify
          shuffle
          keyboardShortcut
          fullAppDisplay
          sortPlay
          extendedCopy
          bookmark
          bestMoment
          catJamSynced
        ];

        enabledCustomApps = with spicePkgs.apps; [
          lyricsPlus
          newReleases
          historyInSidebar
          ncsVisualizer
          betterLibrary
        ];

      };
    };
}
