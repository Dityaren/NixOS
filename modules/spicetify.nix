{ inputs, ... }:

{
  flake.nixosModules.spicetify =
    { pkgs, ... }:
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [
        inputs.spicetify-nix.nixosModules.default
      ];

      programs.spicetify = {
        enable = true;

        # `theme` and `colorScheme` are deliberately not set here: Stylix's spicetify
        # target (stylix.targets.spicetify, on by default with stylix.autoEnable)
        # generates a theme from the base16 scheme and sets both options itself.
        # Setting them here as well would clash with it.
        # To override Stylix, use lib.mkForce on the option you want to replace.

        enabledExtensions = with spicePkgs.extensions; [
          adblockify
          shuffle
          keyboardShortcut
          fullAppDisplay
          sortPlay
          extendedCopy
          bookmark
          bestMoment
        ];

        enabledCustomApps = with spicePkgs.apps; [
          lyricsPlus
          newReleases
          historyInSidebar
        ];
      };
    };
}
