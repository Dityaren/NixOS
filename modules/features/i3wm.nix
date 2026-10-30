{ ... }:
{
  flake.nixosModules.i3wm =
    { pkgs, ... }:
    let
      focusMode = pkgs.writeShellScriptBin "focus-mode" ''
        if [ "$(${pkgs.dunst}/bin/dunstctl is-paused)" = "true" ]; then
          ${pkgs.dunst}/bin/dunstctl set-paused false
          i3-msg "bar mode dock" >/dev/null
          ${pkgs.libnotify}/bin/notify-send "Focus mode" "Off"
        else
          ${pkgs.libnotify}/bin/notify-send "Focus mode" "On - notifications paused"
          sleep 2
          ${pkgs.dunst}/bin/dunstctl set-paused true
          i3-msg "bar mode invisible" >/dev/null
        fi
      '';

      pomodoro = pkgs.writeShellScriptBin "pomodoro" ''
        work=''${1:-25}
        rest=''${2:-5}
        while true; do
          ${pkgs.libnotify}/bin/notify-send "Focus" "$work minutes. Go."
          sleep $((work * 60))
          ${pkgs.libnotify}/bin/notify-send -u critical "Break" "$rest minutes. Stand up, drink water."
          sleep $((rest * 60))
        done
      '';

      i3Config = pkgs.writeText "i3-config" ''
        set $mod Mod4

        set $ws1 "1:code"
        set $ws2 "2:term"
        set $ws3 "3:docs"
        set $ws4 "4:web"
        set $ws5 "5:chat"

        font pango:monospace 10
        floating_modifier $mod

        # Minimal chrome: no gaps, thin borders, no borders on a lone window.
        default_border pixel 2
        default_floating_border pixel 2
        hide_edge_borders smart
        focus_follows_mouse no
        workspace_auto_back_and_forth yes

        # Chat lives on its own workspace so it is out of sight while working.
        assign [class="(?i)discord"] $ws5

        # ---- launching / session ----
        bindsym $mod+Return exec alacritty
        bindsym $mod+space exec rofi -show drun
        bindsym $mod+Shift+space floating toggle
        bindsym $mod+q kill
        bindsym $mod+Shift+r restart
        bindsym $mod+Shift+e exec i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'
        bindsym $mod+Alt+l exec loginctl lock-session

        # Clipboard history (clipmenu daemon runs as a service, see below).
        bindsym $mod+c exec env CM_LAUNCHER=rofi clipmenu

        # ---- focus / study tools ----
        bindsym $mod+F12 exec focus-mode
        bindsym $mod+p exec alacritty --class pomodoro -e pomodoro
        for_window [class="pomodoro"] floating enable, resize set 420 180, move position center

        # ---- focus and move (vi keys + arrows) ----
        bindsym $mod+h focus left
        bindsym $mod+j focus down
        bindsym $mod+k focus up
        bindsym $mod+l focus right
        bindsym $mod+Left focus left
        bindsym $mod+Down focus down
        bindsym $mod+Up focus up
        bindsym $mod+Right focus right

        bindsym $mod+Shift+h move left
        bindsym $mod+Shift+j move down
        bindsym $mod+Shift+k move up
        bindsym $mod+Shift+l move right

        # ---- layout ----
        bindsym $mod+b split h
        bindsym $mod+v split v
        bindsym $mod+f fullscreen toggle
        bindsym $mod+s layout stacking
        bindsym $mod+w layout tabbed
        bindsym $mod+e layout toggle split

        # ---- workspaces ----
        bindsym $mod+1 workspace number $ws1
        bindsym $mod+2 workspace number $ws2
        bindsym $mod+3 workspace number $ws3
        bindsym $mod+4 workspace number $ws4
        bindsym $mod+5 workspace number $ws5

        bindsym $mod+Shift+1 move container to workspace number $ws1
        bindsym $mod+Shift+2 move container to workspace number $ws2
        bindsym $mod+Shift+3 move container to workspace number $ws3
        bindsym $mod+Shift+4 move container to workspace number $ws4
        bindsym $mod+Shift+5 move container to workspace number $ws5

        bindsym $mod+bracketleft workspace prev
        bindsym $mod+bracketright workspace next

        # ---- resize ----
        mode "resize" {
          bindsym h resize shrink width 40 px or 4 ppt
          bindsym j resize grow height 40 px or 4 ppt
          bindsym k resize shrink height 40 px or 4 ppt
          bindsym l resize grow width 40 px or 4 ppt
          bindsym Return mode "default"
          bindsym Escape mode "default"
        }
        bindsym $mod+r mode "resize"

        # ---- media / brightness ----
        bindsym XF86AudioRaiseVolume exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 3%+
        bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-
        bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        bindsym XF86MonBrightnessUp exec brightnessctl s +5%
        bindsym XF86MonBrightnessDown exec brightnessctl s 5%-

        # ---- bar: i3's own bar + i3status, very light ----
        bar {
          status_command i3status
          position top
          mode dock
          tray_output primary
        }

        # ---- autostart ----
        exec --no-startup-id dunst
      '';
    in
    {
      services.xserver = {
        enable = true;

        windowManager.i3 = {
          enable = true;
          configFile = i3Config;
          extraPackages = with pkgs; [
            i3status
            rofi
            dunst
            libnotify
            xclip
            alacritty
            brightnessctl
            focusMode
            pomodoro
          ];
        };
      };

      services.clipmenu.enable = true;

      programs.xss-lock = {
        enable = true;
        lockerCommand = "${pkgs.i3lock}/bin/i3lock -c 1e1e2e";
      };
    };
}
