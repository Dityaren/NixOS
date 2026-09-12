{ ... }:

{
  flake.nixosModules.i3wm =
    {
      vars,
      pkgs,
      ...
    }:
    {
      services.xserver = {
        enable = true;

        windowManager.i3 = {
          enable = true;
          package = pkgs.i3;
        };
      };

      environment.systemPackages = with pkgs; [
        rofi
        xclip
        xorg.xrandr
      ];

      home-manager.users.${vars.username} = {
        xsession.windowManager.i3 = {
          enable = true;

          config = {
            modifier = "Mod4";

            terminal = "alacritty";

            menu = "rofi -show drun";

            fonts = {
              names = [ "JetBrainsMono Nerd Font" ];
              size = 11.0;
            };

            gaps = {
              inner = 8;
              outer = 4;
              smartGaps = true;
            };

            window = {
              border = 2;
              titlebar = false;
            };

            focus = {
              followMouse = false;
              mouseWarping = false;
              newWindow = "smart";
            };

            workspaceLayout = "default";

            keybindings = {
              "$mod+Return" = "exec alacritty";
              "$mod+d" = "exec rofi -show drun";

              "$mod+q" = "kill";
              "$mod+f" = "fullscreen toggle";
              "$mod+Shift+space" = "floating toggle";
              "$mod+space" = "focus mode_toggle";

              "$mod+h" = "focus left";
              "$mod+j" = "focus down";
              "$mod+k" = "focus up";
              "$mod+l" = "focus right";

              "$mod+Shift+h" = "move left";
              "$mod+Shift+j" = "move down";
              "$mod+Shift+k" = "move up";
              "$mod+Shift+l" = "move right";

              "$mod+b" = "split horizontal";
              "$mod+v" = "split vertical";

              "$mod+s" = "layout stacking";
              "$mod+w" = "layout tabbed";
              "$mod+e" = "layout toggle split";

              "$mod+r" = "mode resize";

              "$mod+1" = "workspace number 1";
              "$mod+2" = "workspace number 2";
              "$mod+3" = "workspace number 3";
              "$mod+4" = "workspace number 4";
              "$mod+5" = "workspace number 5";
              "$mod+6" = "workspace number 6";
              "$mod+7" = "workspace number 7";
              "$mod+8" = "workspace number 8";
              "$mod+9" = "workspace number 9";
              "$mod+0" = "workspace number 10";

              "$mod+Shift+1" = "move container to workspace number 1";
              "$mod+Shift+2" = "move container to workspace number 2";
              "$mod+Shift+3" = "move container to workspace number 3";
              "$mod+Shift+4" = "move container to workspace number 4";
              "$mod+Shift+5" = "move container to workspace number 5";
              "$mod+Shift+6" = "move container to workspace number 6";
              "$mod+Shift+7" = "move container to workspace number 7";
              "$mod+Shift+8" = "move container to workspace number 8";
              "$mod+Shift+9" = "move container to workspace number 9";
              "$mod+Shift+0" = "move container to workspace number 10";

              "$mod+Shift+r" = "reload";

              "$mod+Shift+q" = "exec i3-msg exit";
            };

            modes = {
              resize = {
                "h" = "resize shrink width 10 px or 10 ppt";
                "j" = "resize grow height 10 px or 10 ppt";
                "k" = "resize shrink height 10 px or 10 ppt";
                "l" = "resize grow width 10 px or 10 ppt";

                "Left" = "resize shrink width 10 px or 10 ppt";
                "Down" = "resize grow height 10 px or 10 ppt";
                "Up" = "resize shrink height 10 px or 10 ppt";
                "Right" = "resize grow width 10 px or 10 ppt";

                "Return" = "mode default";
                "Escape" = "mode default";
              };
            };

            startup = [
              {
                command = "xsetroot -cursor_name left_ptr";
                notification = false;
              }
            ];
          };

          extraConfig = ''
            # Do not automatically focus newly opened applications
            focus_on_window_activation smart

            # Automatically place dialogs in floating mode
            for_window [window_type="dialog"] floating enable
            for_window [window_type="utility"] floating enable

            # Development workspaces
            workspace 1 output primary
            workspace 2 output primary
            workspace 3 output primary
            workspace 4 output primary

            # Prevent accidental mouse focus changes
            focus_follows_mouse no
          '';
        };

        xdg.configFile."i3/config".force = true;
      };
    };
}
