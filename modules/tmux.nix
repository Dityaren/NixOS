{ self, inputs, ... }:

{
  flake.nixosModules.tmux =
    {
      vars,
      pkgs,
      ...
    }:
    let
      # Prints the styled branch segment (lualine "b" section), nothing outside a git repo
      gitBranch = pkgs.writeShellScript "tmux-git-branch" ''
        branch="$(${pkgs.git}/bin/git -C "$1" branch --show-current 2>/dev/null)"
        [ -n "$branch" ] && printf '#[fg=#aaaaaa,bg=#222222] 󰘬 %s #[fg=#111111,bg=#111111]' "$branch"
      '';
    in
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

            bind-key -T copy-mode-vi v send-keys -X begin-selection
            bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
            bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

            bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded"

            # ---------------------------------------------------------------
            # Status bar, modeled on the lualine config
            #   a: fg #111111 bg #aaaaaa (bold)   b: fg #aaaaaa bg #222222
            #   c: fg #888888 bg #111111          inactive: #666 / #555 / #444
            # ---------------------------------------------------------------
            set -g status on
            set -g status-position top
            set -g status-interval 5
            set -g status-justify left
            set -g status-left-length 80
            set -g status-right-length 120

            set -g status-style "bg=#111111,fg=#888888"

            # a: mode letter (N normal, P prefix pressed, C copy mode) | b: git branch
            set -g status-left "#[fg=#111111,bg=#aaaaaa,bold] #{?client_prefix,P,#{?pane_in_mode,C,N}} #[fg=#111111,bg=#111111,nobold]#(${gitBranch} '#{pane_current_path}')#[fg=#888888,bg=#111111,nobold] "

            # c: window list, "│" component separators
            setw -g window-status-separator "#[fg=#444444,bg=#111111]│"
            setw -g window-status-format "#[fg=#666666,bg=#111111] #I:#W "
            setw -g window-status-current-format "#[fg=#aaaaaa,bg=#111111,bold] #I:#W#{?window_zoomed_flag, 󰁌,} "

            # x: current dir | y: session | z: clock (a-style block)
            set -g status-right "#[fg=#888888,bg=#111111]#{b:pane_current_path} #[fg=#444444]│ #[fg=#aaaaaa,bg=#222222] #S #[fg=#111111,bg=#aaaaaa,bold] %H:%M "

            set -g pane-border-lines single
            set -g pane-border-style "fg=#333333"
            set -g pane-active-border-style "fg=#888888"

            set -g message-style "bg=#222222,fg=#aaaaaa"
            set -g message-command-style "bg=#222222,fg=#aaaaaa"
            set -g mode-style "bg=#333333,fg=#ffffff"

            setw -g automatic-rename on
            setw -g automatic-rename-format '#W'

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
