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

          # ─────────────────────────────────────────────
          # General
          # ─────────────────────────────────────────────

          # Ctrl-A as the tmux prefix.
          prefix = "C-a";

          # Use vi-style copy mode.
          keyMode = "vi";

          # Start windows and panes at 1 instead of 0.
          baseIndex = 1;

          # Make tmux respond immediately to key combinations.
          escapeTime = 0;

          # Keep 10,000 lines of scrollback.
          historyLimit = 10000;

          # Enable mouse support.
          mouse = true;

          # Allow applications such as Neovim to receive focus events.
          focusEvents = true;

          # Resize panes/windows when the terminal size changes.
          aggressiveResize = true;

          # 24-hour clock.
          clock24 = true;

          # Fish shell.
          shell = "${pkgs.fish}/bin/fish";

          # Correct terminal type for modern terminal features.
          terminal = "tmux-256color";

          # Use a protected tmux socket.
          secureSocket = true;

          # ─────────────────────────────────────────────
          # Plugins
          # ─────────────────────────────────────────────

          plugins = with pkgs.tmuxPlugins; [
            # Catppuccin should be loaded before plugins that
            # may interact with the status line.
            catppuccin

            sensible
            yank
            vim-tmux-navigator
            resurrect
            continuum
          ];

          # ─────────────────────────────────────────────
          # Configuration
          # ─────────────────────────────────────────────

          extraConfig = ''
            # ─────────────────────────────────────────
            # Terminal / true color
            # ─────────────────────────────────────────

            set -g default-terminal "tmux-256color"

            set -ag terminal-overrides ",xterm-256color:RGB"
            set -ag terminal-overrides ",xterm*:Tc"

            # ─────────────────────────────────────────
            # Prefix
            # ─────────────────────────────────────────

            # C-a is configured by Home Manager's `prefix`.
            # C-b is intentionally unused.

            # ─────────────────────────────────────────
            # Windows / panes
            # ─────────────────────────────────────────

            set -g base-index 1
            setw -g pane-base-index 1
            set -g renumber-windows on

            # Keep the current working directory when creating
            # windows and panes.
            bind c new-window -c "#{pane_current_path}"

            bind '"' split-window -v -c "#{pane_current_path}"
            bind % split-window -h -c "#{pane_current_path}"

            # Easier-to-remember split bindings.
            bind | split-window -h -c "#{pane_current_path}"
            bind - split-window -v -c "#{pane_current_path}"

            # ─────────────────────────────────────────
            # Pane navigation
            # ─────────────────────────────────────────

            # vim-tmux-navigator handles C-h/j/k/l.

            # ─────────────────────────────────────────
            # Pane resizing
            # ─────────────────────────────────────────

            bind -r H resize-pane -L 5
            bind -r J resize-pane -D 5
            bind -r K resize-pane -U 5
            bind -r L resize-pane -R 5

            # ─────────────────────────────────────────
            # Window navigation
            # ─────────────────────────────────────────

            bind -n M-H previous-window
            bind -n M-L next-window

            bind -n M-Left previous-window
            bind -n M-Right next-window

            # ─────────────────────────────────────────
            # Vi copy mode
            # ─────────────────────────────────────────

            bind-key -T copy-mode-vi v send-keys -X begin-selection
            bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
            bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

            # ─────────────────────────────────────────
            # Reload
            # ─────────────────────────────────────────

            bind r source-file ~/.config/tmux/tmux.conf \; \
              display-message "tmux config reloaded"

            # ─────────────────────────────────────────
            # Catppuccin
            # ─────────────────────────────────────────

            # Catppuccin Mocha.
            # Available flavors:
            #   latte
            #   frappe
            #   macchiato
            #   mocha
            set -g @catppuccin_flavor "mocha"

            # Rounded window indicators.
            set -g @catppuccin_window_status_style "rounded"

            # Window text.
            set -g @catppuccin_window_default_text " #I:#W"
            set -g @catppuccin_window_current_text " #I:#W"

            # Window number position.
            set -g @catppuccin_window_number_position "left"

            # Separators.
            set -g @catppuccin_window_left_separator ""
            set -g @catppuccin_window_middle_separator " "
            set -g @catppuccin_window_right_separator " "

            # Status bar separators.
            set -g @catppuccin_status_left_separator ""
            set -g @catppuccin_status_right_separator ""
            set -g @catppuccin_status_connect_separator "yes"

            # ─────────────────────────────────────────
            # Catppuccin status modules
            # ─────────────────────────────────────────

            # Session information on the left.
            set -g status-left "#{E:@catppuccin_status_session}"

            # Application, directory, and time on the right.
            set -g status-right "#{E:@catppuccin_status_application}"
            set -ag status-right " #{E:@catppuccin_status_directory}"
            set -ag status-right " #{E:@catppuccin_status_date_time}"

            # ─────────────────────────────────────────
            # Status bar sizing
            # ─────────────────────────────────────────

            set -g status-left-length 100
            set -g status-right-length 100
            set -g status-interval 5

            # ─────────────────────────────────────────
            # Pane appearance
            # ─────────────────────────────────────────

            set -g pane-border-lines single

            # Catppuccin colors are used for the pane borders.
            set -g pane-border-style "fg=#{@thm_surface_1}"
            set -g pane-active-border-style "fg=#{@thm_lavender}"

            # ─────────────────────────────────────────
            # Window naming
            # ─────────────────────────────────────────

            setw -g automatic-rename on
            setw -g automatic-rename-format '#{b:pane_current_path}'

            # ─────────────────────────────────────────
            # Resurrect
            # ─────────────────────────────────────────

            # Save pane contents and restore Neovim sessions.
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-strategy-nvim 'session'

            # ─────────────────────────────────────────
            # Continuum
            # ─────────────────────────────────────────

            # Automatically save and restore tmux sessions.
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '15'

            # ─────────────────────────────────────────
            # Miscellaneous
            # ─────────────────────────────────────────

            set -g focus-events on
            set -g history-limit 10000
          '';
        };
      };
    };
}
