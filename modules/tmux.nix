{ ... }:

{
  flake.nixosModules.tmux =
    {
      config,
      vars,
      pkgs,
      ...
    }:
    let
      c = config.lib.stylix.colors.withHashtag;

      gitBranch = pkgs.writeShellScript "tmux-git-branch" ''
        ${pkgs.git}/bin/git -C "$1" branch --show-current 2>/dev/null
      '';
    in
    {
      home-manager.users.${vars.username} = {
        stylix.targets.tmux.enable = false;

        programs.tmux = {
          enable = true;
          package = pkgs.tmux;

          prefix = "C-a";
          keyMode = "vi";
          baseIndex = 1;
          escapeTime = 0;
          historyLimit = 10000;
          mouse = true;
          focusEvents = true;
          aggressiveResize = true;
          clock24 = true;
          shell = "${pkgs.fish}/bin/fish";
          terminal = "tmux-256color";
          secureSocket = true;

          plugins = with pkgs.tmuxPlugins; [ vim-tmux-navigator ];

          extraConfig = ''
            set -as terminal-features ",*:RGB"
            set -g set-clipboard on
            set -g renumber-windows on

            bind c new-window -c "#{pane_current_path}"
            bind '"' split-window -v -c "#{pane_current_path}"
            bind % split-window -h -c "#{pane_current_path}"
            bind | split-window -h -c "#{pane_current_path}"
            bind - split-window -v -c "#{pane_current_path}"

            bind -r H resize-pane -L 5
            bind -r J resize-pane -D 5
            bind -r K resize-pane -U 5
            bind -r L resize-pane -R 5

            bind -n M-H previous-window
            bind -n M-L next-window
            bind -n M-Left previous-window
            bind -n M-Right next-window

            bind-key -T copy-mode-vi v send-keys -X begin-selection
            bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
            bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

            bind r source-file ~/.config/tmux/tmux.conf \; display-message "reloaded"

            # ---- status: flat, transparent, no icons or blocks ----
            # bg=default lets the terminal's own background (and its opacity) show through.
            set -g status on
            set -g status-position bottom
            set -g status-interval 10
            set -g status-justify left
            set -g status-left-length 40
            set -g status-right-length 60
            set -g status-style "bg=default,fg=${c.base03}"

            # left: session name, accent dot while the prefix is active
            set -g status-left "#[fg=${c.base04}]#S #[fg=${c.base0D}]#{?client_prefix,• ,}"

            # windows: dim, active one bright
            setw -g window-status-separator ""
            setw -g window-status-format "#[fg=${c.base03}] #I:#W "
            setw -g window-status-current-format "#[fg=${c.base05},bold] #I:#W#{?window_zoomed_flag,+,} "

            # right: git branch (only in a repo), time
            set -g status-right "#[fg=${c.base03}]#(${gitBranch} '#{pane_current_path}')  #[fg=${c.base04}]%H:%M"

            set -g pane-border-lines single
            set -g pane-border-style "fg=${c.base02}"
            set -g pane-active-border-style "fg=${c.base0D}"

            set -g message-style "bg=default,fg=${c.base05}"
            set -g message-command-style "bg=default,fg=${c.base05}"
            set -g mode-style "bg=${c.base02},fg=${c.base05}"

            setw -g automatic-rename on
            setw -g automatic-rename-format "#{b:pane_current_path}"
          '';
        };
      };
    };
}
