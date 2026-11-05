{ ... }:

{
  flake.nixosModules.nixSettings =
    {
      vars,
      pkgs,
      ...
    }:
    {
      nixpkgs.config.allowUnfree = true;

      systemd.tmpfiles.rules = [
        "L+ /bin/sh - - - - ${pkgs.bash}/bin/sh"
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"

        "L+ /bin/pwd - - - - ${pkgs.coreutils}/bin/pwd"
        "L+ /bin/ls - - - - ${pkgs.coreutils}/bin/ls"
        "L+ /bin/cat - - - - ${pkgs.coreutils}/bin/cat"
        "L+ /bin/cp - - - - ${pkgs.coreutils}/bin/cp"
        "L+ /bin/mv - - - - ${pkgs.coreutils}/bin/mv"
        "L+ /bin/rm - - - - ${pkgs.coreutils}/bin/rm"
        "L+ /bin/mkdir - - - - ${pkgs.coreutils}/bin/mkdir"
        "L+ /bin/chmod - - - - ${pkgs.coreutils}/bin/chmod"
        "L+ /bin/chown - - - - ${pkgs.coreutils}/bin/chown"
        "L+ /bin/ln - - - - ${pkgs.coreutils}/bin/ln"
        "L+ /bin/readlink - - - - ${pkgs.coreutils}/bin/readlink"
        "L+ /bin/realpath - - - - ${pkgs.coreutils}/bin/realpath"
        "L+ /bin/dirname - - - - ${pkgs.coreutils}/bin/dirname"
        "L+ /bin/basename - - - - ${pkgs.coreutils}/bin/basename"
        "L+ /bin/tee - - - - ${pkgs.coreutils}/bin/tee"
        "L+ /bin/sleep - - - - ${pkgs.coreutils}/bin/sleep"
        "L+ /bin/date - - - - ${pkgs.coreutils}/bin/date"
        "L+ /bin/echo - - - - ${pkgs.coreutils}/bin/echo"
        "L+ /bin/printf - - - - ${pkgs.coreutils}/bin/printf"
        "L+ /bin/test - - - - ${pkgs.coreutils}/bin/test"
        "L+ /bin/true - - - - ${pkgs.coreutils}/bin/true"
        "L+ /bin/false - - - - ${pkgs.coreutils}/bin/false"

        "L+ /usr/bin/env - - - - ${pkgs.coreutils}/bin/env"
        "L+ /usr/bin/which - - - - ${pkgs.which}/bin/which"
      ];

      nix.settings = {

        substituters = [
          "https://ezkea.cachix.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "${vars.username}"
        ];
      };
    };
}
