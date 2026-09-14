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
            set -g @black "#000000"
            set -g @dark "#0A0A0A"
            set -g @gray "#1A1A1A"
            set -g @gray-light "#2A2A2A"

            set -g @muted "#666666"
            set -g @fg "#B3B3B3"
            set -g @white "#D4D4D4"

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
            set -g status-left-length 30
            set -g status-right-length 80

            set -g status-style \
              "bg=#{@black},fg=#{@fg}"

            set -g status-left-style \
              "bg=#{@black},fg=#{@fg}"

            set -g status-right-style \
              "bg=#{@black},fg=#{@fg}"

            set -g status-left \
              "#[fg=#{@white},bold] tmux #[fg=#{@muted}]"

            setw -g window-status-format \
              "#[fg=#{@muted}] #I:#W "

            setw -g window-status-current-format \
              "#[fg=#{@white},bold] #I:#W "

            setw -g window-status-separator ""

            set -g status-right \
              "#[fg=#{@muted}]#{b:pane_current_path}  #[fg=#{@gray-light}]│  #[fg=#{@fg}]%H:%M "

            set -g pane-border-lines single

            set -g pane-border-style \
              "fg=#{@gray-light}"

            set -g pane-active-border-style \
              "fg=#{@muted}"

            setw -g automatic-rename on

            setw -g automatic-rename-format \
              '#W'

            set -g message-style \
              "bg=#{@gray},fg=#{@white}"

            set -g message-command-style \
              "bg=#{@gray},fg=#{@white}"

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
