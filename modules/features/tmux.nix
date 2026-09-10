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

          # ─────────────────────────────────────────────
          # Plugins
          # ─────────────────────────────────────────────

          plugins = with pkgs.tmuxPlugins; [
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
            # ╭─────────────────────────────────────────╮
            # │ Terminal                                │
            # ╰─────────────────────────────────────────╯

            set -g default-terminal "tmux-256color"

            set -ag terminal-overrides ",xterm-256color:RGB"
            set -ag terminal-overrides ",xterm*:Tc"


            # ╭─────────────────────────────────────────╮
            # │ Kanagawa Palette                        │
            # ╰─────────────────────────────────────────╯

            # Background
            set -g @kanagawa_bg "#16161D"
            set -g @kanagawa_bg_alt "#1F1F28"
            set -g @kanagawa_border "#2A2A37"

            # Foreground
            set -g @kanagawa_fg "#DCD7BA"
            set -g @kanagawa_muted "#727169"

            # Accents
            set -g @kanagawa_blue "#7E9CD8"
            set -g @kanagawa_cyan "#7FB4CA"
            set -g @kanagawa_yellow "#DCA561"
            set -g @kanagawa_green "#6A9589"


            # ╭─────────────────────────────────────────╮
            # │ Prefix                                  │
            # ╰─────────────────────────────────────────╯

            # C-a is configured through Home Manager.
            # C-b remains unused.


            # ╭─────────────────────────────────────────╮
            # │ Windows / Panes                          │
            # ╰─────────────────────────────────────────╯

            set -g base-index 1
            setw -g pane-base-index 1
            set -g renumber-windows on

            # Preserve current working directory.

            bind c new-window -c "#{pane_current_path}"

            bind '"' split-window -v -c "#{pane_current_path}"
            bind % split-window -h -c "#{pane_current_path}"

            # Easier split bindings.
            bind | split-window -h -c "#{pane_current_path}"
            bind - split-window -v -c "#{pane_current_path}"


            # ╭─────────────────────────────────────────╮
            # │ Pane Navigation                          │
            # ╰─────────────────────────────────────────╯

            # vim-tmux-navigator handles:
            #
            # C-h
            # C-j
            # C-k
            # C-l


            # ╭─────────────────────────────────────────╮
            # │ Pane Resizing                            │
            # ╰─────────────────────────────────────────╯

            bind -r H resize-pane -L 5
            bind -r J resize-pane -D 5
            bind -r K resize-pane -U 5
            bind -r L resize-pane -R 5


            # ╭─────────────────────────────────────────╮
            # │ Window Navigation                        │
            # ╰─────────────────────────────────────────╯

            bind -n M-H previous-window
            bind -n M-L next-window

            bind -n M-Left previous-window
            bind -n M-Right next-window


            # ╭─────────────────────────────────────────╮
            # │ Vi Copy Mode                             │
            # ╰─────────────────────────────────────────╯

            bind-key -T copy-mode-vi v \
              send-keys -X begin-selection

            bind-key -T copy-mode-vi C-v \
              send-keys -X rectangle-toggle

            bind-key -T copy-mode-vi y \
              send-keys -X copy-selection-and-cancel


            # ╭─────────────────────────────────────────╮
            # │ Reload                                   │
            # ╰─────────────────────────────────────────╯

            bind r source-file ~/.config/tmux/tmux.conf \; \
              display-message "tmux config reloaded"


            # ╭─────────────────────────────────────────╮
            # │ Status Bar                               │
            # ╰─────────────────────────────────────────╯

            set -g status on

            # Top panel.
            set -g status-position top

            set -g status-interval 5

            # IMPORTANT:
            # Window list is LEFT aligned.
            set -g status-justify left

            # Give the right side enough space for the path/time.
            set -g status-left-length 40
            set -g status-right-length 100


            # ─────────────────────────────────────────
            # Base bar
            # ─────────────────────────────────────────

            set -g status-style \
              "bg=#{@kanagawa_bg},fg=#{@kanagawa_fg}"

            set -g status-left-style \
              "bg=#{@kanagawa_bg},fg=#{@kanagawa_fg}"

            set -g status-right-style \
              "bg=#{@kanagawa_bg},fg=#{@kanagawa_fg}"


            # ─────────────────────────────────────────
            # NixOS logo
            # ─────────────────────────────────────────

            # NixOS logo at the absolute left.
            #
            # Requires a Nerd Font / font containing the
            # NixOS glyph.

            set -g status-left \
              "#[fg=#{@kanagawa_blue},bold] 󱄅 #[fg=#{@kanagawa_border}]│ "


            # ─────────────────────────────────────────
            # Window list
            # ─────────────────────────────────────────

            # Inactive windows.
            setw -g window-status-format \
              "#[fg=#{@kanagawa_muted}]#I:#W "

            # Active window.
            setw -g window-status-current-format \
              "#[fg=#{@kanagawa_blue},bold]#I:#W #[nobold]"

            # No separators.
            setw -g window-status-separator ""


            # ─────────────────────────────────────────
            # Right side
            # ─────────────────────────────────────────

            set -g status-right \
              "#[fg=#{@kanagawa_muted}]#{b:pane_current_path} #[fg=#{@kanagawa_border}]│ #[fg=#{@kanagawa_yellow}]%H:%M "


            # ╭─────────────────────────────────────────╮
            # │ Pane Borders                             │
            # ╰─────────────────────────────────────────╯

            set -g pane-border-lines single

            set -g pane-border-style \
              "fg=#{@kanagawa_border}"

            set -g pane-active-border-style \
              "fg=#{@kanagawa_blue}"


            # ╭─────────────────────────────────────────╮
            # │ Window Naming                            │
            # ╰─────────────────────────────────────────╯

            setw -g automatic-rename on

            setw -g automatic-rename-format \
              '#{b:pane_current_path}'


            # ╭─────────────────────────────────────────╮
            # │ Messages                                 │
            # ╰─────────────────────────────────────────╯

            set -g message-style \
              "bg=#{@kanagawa_bg_alt},fg=#{@kanagawa_fg}"

            set -g message-command-style \
              "bg=#{@kanagawa_bg_alt},fg=#{@kanagawa_fg}"


            # ╭─────────────────────────────────────────╮
            # │ Resurrect                                │
            # ╰─────────────────────────────────────────╯

            set -g @resurrect-capture-pane-contents 'on'

            set -g @resurrect-strategy-nvim 'session'


            # ╭─────────────────────────────────────────╮
            # │ Continuum                                │
            # ╰─────────────────────────────────────────╯

            set -g @continuum-restore 'on'

            set -g @continuum-save-interval '15'


            # ╭─────────────────────────────────────────╮
            # │ Miscellaneous                            │
            # ╰─────────────────────────────────────────╯

            set -g focus-events on

            set -g history-limit 10000
          '';
        };
      };
    };
}
