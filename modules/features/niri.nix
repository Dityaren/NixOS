{ self, inputs, ... }:
{
  flake.nixosModules.niri =
    {
      pkgs,
      lib,
      vars,
      ...
    }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      noctalia = inputs.noctalia.packages.${system}.default;
      noctaliaExe = lib.getExe noctalia;
    in
    {
      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };

      home-manager.users.${vars.username} = {
        home.pointerCursor = {
          enable = true;

          gtk.enable = true;
          x11.enable = true;

          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 24;
        };

        wayland.windowManager.niri = {
          enable = true;

          extraConfig = ''
            window-rule {
                geometry-corner-radius 10
                clip-to-geometry true
                background-effect {
                    blur true
                    xray false
                    noise 0.02
                    saturation 1.1
                }

            }
            window-rule {
                match app-id="^Alacritty$"

                draw-border-with-background false

                background-effect {
                    blur true
                    xray false
                    noise 0.02
                    saturation 1.1
                }
            }
          '';

          settings = {

            prefer-no-csd = true;

            hotkey-overlay = {
              skip-at-startup = { };
            };

            animations = {
              workspace-switch = {
                off = { };
              };
            };

            spawn-at-startup = [
              noctaliaExe
            ];

            xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

            input = {
              touchpad = {
                tap = { };
                natural-scroll = { };
              };

              keyboard.xkb.layout = "us,ua";

              mouse = {
                accel-profile = "flat";
              };
            };

            gestures = {
              hot-corners.off = { };
            };

            layer-rule = {
              place-within-backdrop = true;
            };

            layout = {
              background-color = "transparent";
              gaps = 0;

              focus-ring.off = { };
              shadow.off = { };

              border = {
                width = 0;

                active-color = "#dcdede";
                inactive-color = "#575757";
              };
            };

            binds = {

              "Mod+T".spawn = [
                (lib.getExe pkgs.alacritty)
              ];

              "Mod+Q".close-window = { };
              "Mod+Shift+Q".quit = { };

              "Mod+H".focus-column-left = { };
              "Mod+L".focus-column-right = { };
              "Mod+J".focus-window-down = { };
              "Mod+K".focus-window-up = { };

              "Mod+Shift+H".move-column-left = { };
              "Mod+Shift+L".move-column-right = { };
              "Mod+Shift+J".move-window-down = { };
              "Mod+Shift+K".move-window-up = { };

              "Mod+1".focus-workspace = 1;
              "Mod+2".focus-workspace = 2;
              "Mod+3".focus-workspace = 3;
              "Mod+4".focus-workspace = 4;
              "Mod+5".focus-workspace = 5;
              "Mod+6".focus-workspace = 6;
              "Mod+7".focus-workspace = 7;
              "Mod+8".focus-workspace = 8;
              "Mod+9".focus-workspace = 9;

              "Mod+Shift+1".move-window-to-workspace = 1;
              "Mod+Shift+2".move-window-to-workspace = 2;
              "Mod+Shift+3".move-window-to-workspace = 3;
              "Mod+Shift+4".move-window-to-workspace = 4;
              "Mod+Shift+5".move-window-to-workspace = 5;
              "Mod+Shift+6".move-window-to-workspace = 6;
              "Mod+Shift+7".move-window-to-workspace = 7;
              "Mod+Shift+8".move-window-to-workspace = 8;
              "Mod+Shift+9".move-window-to-workspace = 9;

              "Mod+D".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "launcher"
                "toggle"
              ];

              "Mod+Shift+D".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "launcher"
                "command"
              ];

              "Mod+Shift+E".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "launcher"
                "emoji"
              ];

              "Mod+Alt+B".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "bar"
                "toggle"
              ];

              "XF86AudioRaiseVolume".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "volume"
                "increase"
              ];

              "XF86AudioLowerVolume".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "volume"
                "decrease"
              ];

              "XF86AudioMute".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "volume"
                "muteOutput"
              ];

              "Mod+Ctrl+V".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "volume"
                "togglePanel"
              ];

              "XF86MonBrightnessUp".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "brightness"
                "increase"
              ];

              "XF86MonBrightnessDown".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "brightness"
                "decrease"
              ];

              "Mod+N".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "controlCenter"
                "toggle"
              ];

              "Mod+Shift+N".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "notifications"
                "toggleHistory"
              ];

              "Mod+Ctrl+N".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "notifications"
                "toggleDND"
              ];

              "Mod+Ctrl+Shift+N".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "notifications"
                "dismissAll"
              ];

              "Mod+C".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "calendar"
                "toggle"
              ];

              "Mod+W".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "network"
                "togglePanel"
              ];

              "Mod+Shift+W".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "wifi"
                "toggle"
              ];

              "Mod+B".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "bluetooth"
                "togglePanel"
              ];

              "Mod+Shift+B".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "bluetooth"
                "toggle"
              ];

              "Mod+Shift+P".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "battery"
                "togglePanel"
              ];

              "Mod+Alt+P".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "powerProfile"
                "cycle"
              ];

              "Mod+Alt+Shift+P".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "powerProfile"
                "cycleReverse"
              ];

              "Mod+Alt+L".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "nightLight"
                "toggle"
              ];

              "Mod+Alt+M".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "darkMode"
                "toggle"
              ];

              "Mod+Alt+I".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "idleInhibitor"
                "toggle"
              ];

              "Mod+Alt+S".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "systemMonitor"
                "toggle"
              ];

              "XF86AudioPlay".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "media"
                "playPause"
              ];

              "XF86AudioNext".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "media"
                "next"
              ];

              "XF86AudioPrev".spawn = [
                noctaliaExe
                "ipc"
                "call"
                "media"
                "previous"
              ];

              "Print".spawn-sh = "screenshot-screen";
              "Mod+Shift+S".spawn-sh = "screenshot-area";
              "Mod+Shift+V".spawn-sh = "screenshot-copy";

              "Mod+F".maximize-column = { };

              "Mod+Shift+F".toggle-windowed-fullscreen = { };

              "Mod+Ctrl+Shift+F".fullscreen-window = { };

              "Mod+Shift+Space".toggle-window-floating = { };

              "Mod+R".switch-preset-column-width = { };

              "Mod+Shift+C".spawn-sh = "niri msg action reload-config";
            };
          };
        };
      };
    };
}
