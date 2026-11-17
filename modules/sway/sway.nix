{ self, ... }:
{
  flake.nixosModules.sway =
    { pkgs, ... }:
    let
      focusMode = pkgs.writeShellScriptBin "focus-mode" ''
        makoctl=${pkgs.mako}/bin/makoctl
        if $makoctl mode | grep -qx do-not-disturb; then
          $makoctl mode -r do-not-disturb
          ${pkgs.sway}/bin/swaymsg "bar main mode dock" >/dev/null
          ${pkgs.libnotify}/bin/notify-send "Focus mode" "Off"
        else
          ${pkgs.libnotify}/bin/notify-send "Focus mode" "On - notifications paused"
          sleep 2
          $makoctl mode -a do-not-disturb
          ${pkgs.sway}/bin/swaymsg "bar main mode invisible" >/dev/null
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

      clipPick = pkgs.writeShellScriptBin "clip-pick" ''
        ${pkgs.cliphist}/bin/cliphist list \
          | ${pkgs.fuzzel}/bin/fuzzel --dmenu --config /etc/fuzzel/fuzzel.ini \
          | ${pkgs.cliphist}/bin/cliphist decode \
          | ${pkgs.wl-clipboard}/bin/wl-copy
      '';

      swayConfig = pkgs.writeText "sway-config" ''
        set $mod Mod4

        # Each component module drops its own snippet here (terminal sets $term).
        include /etc/sway/config.d/*

        set $ws1 "1:term"
        set $ws2 "2:web"
        set $ws3 "3:docs"
        set $ws4 "4:music"
        set $ws5 "5:chat"

        font pango:monospace 10
        floating_modifier $mod

        default_border pixel 2
        default_floating_border pixel 2
        hide_edge_borders smart
        focus_follows_mouse no
        workspace_auto_back_and_forth yes

        assign [app_id="(?i)discord"] $ws5
        assign [class="(?i)discord"] $ws5

        # ---- session ----
        bindsym $mod+Shift+space floating toggle
        bindsym $mod+q kill
        bindsym $mod+Shift+r reload
        bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'

        bindsym $mod+c exec clip-pick
        exec wl-paste --watch cliphist store

        # ---- focus / study tools ----
        bindsym $mod+F12 exec focus-mode
        bindsym $mod+p exec $term -a pomodoro pomodoro
        for_window [app_id="pomodoro"] floating enable, resize set 420 180, move position center

        # ---- focus and move ----
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
        bindsym $mod+b splith
        bindsym $mod+v splitv
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
        bindsym --locked XF86AudioRaiseVolume exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 3%+
        bindsym --locked XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-
        bindsym --locked XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        bindsym --locked XF86MonBrightnessUp exec brightnessctl s +5%
        bindsym --locked XF86MonBrightnessDown exec brightnessctl s 5%-
      '';
    in
    {
      imports = with self.nixosModules; [
        sway-wallpaper
        sway-terminal
        sway-notifications
        sway-bar
        sway-tray
        sway-screenshot
        sway-launcher
        sway-lock-idle
      ];

      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraOptions = [
          "--config"
          "${swayConfig}"
        ];
        extraPackages = with pkgs; [
          wl-clipboard
          cliphist
          brightnessctl
          wireplumber
          focusMode
          pomodoro
          clipPick
        ];
      };

      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    };
}
