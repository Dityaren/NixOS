{ self, inputs, ... }:

{
  flake.nixosModules.zen-browser =
    { vars, pkgs, ... }:
    {
      home-manager.users.${vars.username} = {
        imports = [
          inputs.zen-browser.homeModules.beta
        ];

        programs.zen-browser = {
          enable = true;
          setAsDefaultBrowser = true;

          policies = {
            DisableTelemetry = true;
            DisableFirefoxStudies = true;
            DisablePocket = true;
            DontCheckDefaultBrowser = true;
            OfferToSaveLogins = false;
          };

          profiles.default = {
            search = {
              force = true;
              default = "google";
            };

            extensions = {
              force = true;

              packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
                ublock-origin
                bitwarden
                vimium-c
              ];
            };
          };
        };
      };
    };
}
