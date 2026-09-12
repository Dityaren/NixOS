{ self, inputs, ... }:

{
  flake.nixosModules.tmux =
    {
      vars,
      pkgs,
      ...
    }:
    {
      home-manager.users.${vars.username} = {
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

          plugins = with pkgs.tmuxPlugins; [
            sensible
            yank
            vim-tmux-navigator
            resurrect
            continuum
          ];

          extraConfig = ''
            set -g default-terminal "tmux-256color"

            set -ag terminal-overrides ",xterm-256color:RGB"
            set -ag terminal-overrides ",xterm*:Tc"
            set -g @kanagawa_bg "#16161D"
            set -g @kanagawa_bg_alt "#1F1F28"
            set -g @kanagawa_border "#2A2A37"

            set -g @kanagawa_fg "#DCD7BA"
            set -g @kanagawa_muted "#727169"

            set -g @kanagawa_blue "#7E9CD8"
            set -g @kanagawa_cyan "#7FB4CA"
            set -g @kanagawa_yellow "#DCA561"
            set -g @kanagawa_green "#6A9589"

            set -g base-index 1
            setw -g pane-base-index 1
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

            bind-key -T copy-mode-vi v \
              send-keys -X begin-selection

            bind-key -T copy-mode-vi C-v \
              send-keys -X rectangle-toggle

            bind-key -T copy-mode-vi y \
              send-keys -X copy-selection-and-cancel

            bind r source-file ~/.config/tmux/tmux.conf \; \
              display-message "tmux config reloaded"

            set -g status on
            set -g status-position top
            set -g status-interval 5
            set -g status-justify left
            set -g status-left-length 40
            set -g status-right-length 100

            set -g status-style \
              "bg=#{@kanagawa_bg},fg=#{@kanagawa_fg}"

            set -g status-left-style \
              "bg=#{@kanagawa_bg},fg=#{@kanagawa_fg}"

            set -g status-right-style \
              "bg=#{@kanagawa_bg},fg=#{@kanagawa_fg}"

            set -g status-left \
              "#[fg=#{@kanagawa_blue},bold] 󱄅 #[fg=#{@kanagawa_border}]│ "

            setw -g window-status-format \
              "#[fg=#{@kanagawa_muted}]#I:#W "

            setw -g window-status-current-format \
              "#[fg=#{@kanagawa_blue},bold]#I:#W #[nobold]"

            setw -g window-status-separator ""

            set -g status-right \
              "#[fg=#{@kanagawa_muted}]#{b:pane_current_path} #[fg=#{@kanagawa_border}]│ #[fg=#{@kanagawa_yellow}]%H:%M "

            set -g pane-border-lines single

            set -g pane-border-style \
              "fg=#{@kanagawa_border}"

            set -g pane-active-border-style \
              "fg=#{@kanagawa_blue}"

            setw -g automatic-rename on

            setw -g automatic-rename-format \
              '

            set -g message-style \
              "bg=#{@kanagawa_bg_alt},fg=#{@kanagawa_fg}"

            set -g message-command-style \
              "bg=#{@kanagawa_bg_alt},fg=#{@kanagawa_fg}"

            set -g @resurrect-capture-pane-contents 'on'

            set -g @resurrect-strategy-nvim 'session'

            set -g @continuum-restore 'on'

            set -g @continuum-save-interval '15'

            set -g focus-events on

            set -g history-limit 10000
          '';
        };
      };
    };
}
