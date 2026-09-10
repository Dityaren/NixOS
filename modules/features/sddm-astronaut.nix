{ ... }: {
  flake.nixosModules.sddm-astronaut =
    { pkgs, ... }:
    let
      sddm-astronaut =
        (pkgs.sddm-astronaut.override {
          embeddedTheme = "astronaut";

          themeConfig = {
            HeaderTextColor = "#ffffff";
            DateTextColor = "#ffffff";
            TimeTextColor = "#ffffff";

            LoginFieldTextColor = "#ffffff";
            PasswordFieldTextColor = "#ffffff";
            UserIconColor = "#ffffff";
            PasswordIconColor = "#ffffff";

            LoginButtonTextColor = "#ffffff";
            SystemButtonsIconsColor = "#ffffff";
            SessionButtonTextColor = "#ffffff";
            VirtualKeyboardButtonTextColor = "#ffffff";

            PlaceholderTextColor = "#c9c9c9";

            Background = "Backgrounds/custom-background.png";
          };
        }).overrideAttrs
          (oldAttrs: {
            installPhase = oldAttrs.installPhase + ''
              chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
              cp ${./custom-background.png} \
                $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/custom-background.png
            '';
          });
    in
    {
      environment.systemPackages = [
        sddm-astronaut
      ];

      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;

        extraPackages = with pkgs; [
          kdePackages.qtmultimedia
        ];

        theme = "sddm-astronaut-theme";
      };
    };
}
