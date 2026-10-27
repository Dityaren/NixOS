{ inputs, ... }:

let
  dmsSettings = {
    special_dim = [ "0.5" ];
    special_gap_inner_horizontal = [ "10" ];
    special_gap_inner_vertical = [ "10" ];
    special_gap_outer_horizontal = [ "20" ];
    special_gap_outer_vertical = [ "20" ];

    env = [
      "QT_QPA_PLATFORM,wayland;xcb"
      "QT_QPA_PLATFORMTHEME,gtk3"
    ];

    layer_rule = [ "no_animation:1,layer_name:^dms" ];

    window_rule = [ "is_floating:1,app_id:^(org\\.quickshell|com\\.danklinux\\.dms)$" ];

    bind = [
      "SUPER,space,spawn,dms ipc call spotlight toggle"
      "SUPER,v,spawn,dms ipc call clipboard toggle"
      "SUPER,m,spawn,dms ipc call processlist focusOrToggle"
      "SUPER,comma,spawn,dms ipc call settings focusOrToggle"
      "SUPER,n,spawn,dms ipc call notifications toggle"
      "SUPER,y,spawn,dms ipc call dankdash wallpaper"
      "SUPER+ALT,l,spawn,dms ipc call lock lock"
      "NONE,XF86AudioRaiseVolume,spawn,dms ipc call audio increment 3"
      "NONE,XF86AudioLowerVolume,spawn,dms ipc call audio decrement 3"
      "NONE,XF86AudioMute,spawn,dms ipc call audio mute"
      "NONE,XF86MonBrightnessUp,spawn,brightnessctl s +5%"
      "NONE,XF86MonBrightnessDown,spawn,brightnessctl s 5%-"

      "SUPER,f,togglefullscreen"
      "SUPER+SHIFT,f,togglefakefullscreen"
      "SUPER,q,killclient"
      "SUPER+SHIFT,space,togglefloating"

      "SUPER,s,toggle_special_tag"
      "SUPER+SHIFT,s,tag_special_tag"
      "SUPER+CTRL,s,tag_special_silent"

      "SUPER,t,spawn,foot"

      "NONE,Print,spawn,screenshot-copy"
      "SHIFT,Print,spawn,screenshot-area"

      "SUPER,1,view,1"
      "SUPER,2,view,2"
      "SUPER,3,view,3"
      "SUPER,4,view,4"
      "SUPER,5,view,5"
      "SUPER,6,view,6"
      "SUPER,7,view,7"
      "SUPER,8,view,8"
      "SUPER,9,view,9"

      "SUPER+SHIFT,1,tag,1"
      "SUPER+SHIFT,2,tag,2"
      "SUPER+SHIFT,3,tag,3"
      "SUPER+SHIFT,4,tag,4"
      "SUPER+SHIFT,5,tag,5"
      "SUPER+SHIFT,6,tag,6"
      "SUPER+SHIFT,7,tag,7"
      "SUPER+SHIFT,8,tag,8"
      "SUPER+SHIFT,9,tag,9"

      "SUPER,h,focusdir,left"
      "SUPER,l,focusdir,right"
      "SUPER,k,focusdir,up"
      "SUPER,j,focusdir,down"

      "SUPER,Left,focusdir,left"
      "SUPER,Right,focusdir,right"
      "SUPER,Up,focusdir,up"
      "SUPER,Down,focusdir,down"

      "SUPER+SHIFT,h,exchange_client,left"
      "SUPER+SHIFT,l,exchange_client,right"
      "SUPER+SHIFT,k,exchange_client,up"
      "SUPER+SHIFT,j,exchange_client,down"

      "SUPER+SHIFT,Left,exchange_client,left"
      "SUPER+SHIFT,Right,exchange_client,right"
      "SUPER+SHIFT,Up,exchange_client,up"
      "SUPER+SHIFT,Down,exchange_client,down"

      "SUPER,bracketleft,view,previous"
      "SUPER,bracketright,view,next"
      "SUPER+CTRL,bracketleft,tag,previous"
      "SUPER+CTRL,bracketright,tag,next"
    ];
  };

  dmsIncludes = ''
    source_optional=./dms/colors.conf
    source_optional=./dms/layout.conf
    source_optional=./dms/outputs.conf
  '';

  importEnv = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE";

  homeModule =
    { lib, ... }:
    {
      imports = [
        inputs.mango.hmModules.mango
      ];

      wayland.windowManager.mango = {
        enable = lib.mkDefault true;

        settings = dmsSettings;

        extraConfig = lib.mkAfter dmsIncludes;

        autostart_sh = lib.mkDefault ''
          # systemd session is started above
          ${importEnv}
        '';
      };
    };
in
{
  flake.nixosModules.mango-dms =
    {
      lib,
      options,
      pkgs,
      ...
    }:
    let
      render =
        settings:
        lib.concatStringsSep "\n" (
          lib.concatLists (lib.mapAttrsToList (key: values: map (value: "${key}=${value}") values) settings)
        );

      shellOpt = if options.programs ? dux-shell then "dux-shell" else "dms-shell";
    in
    {
      imports = [
        inputs.mango.nixosModules.mango
      ];

      config = lib.mkMerge [
        {
          programs.mango = {
            enable = lib.mkDefault true;
            addLoginEntry = lib.mkDefault true;
          };

          programs.${shellOpt} = {
            enable = lib.mkDefault true;
            systemd.enable = lib.mkDefault true;
            package = lib.mkDefault inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
          };

          environment.sessionVariables.NIXOS_OZONE_WL = lib.mkDefault "1";

          environment.etc."mango/config.conf".text = lib.mkDefault ''
            ${render dmsSettings}
            ${dmsIncludes}
            exec_once=${importEnv}
          '';
        }

        (lib.optionalAttrs (options ? home-manager) {
          home-manager.sharedModules = [ homeModule ];
        })
      ];
    };

  flake.homeModules.mango-dms = homeModule;
}
