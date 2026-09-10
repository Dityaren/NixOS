{ pkgs, ... }:
{
  flake.nixosModules.fish =
    {
      vars,
      pkgs,
      ...
    }:
    {
      programs.fish.enable = true;

      environment.systemPackages = with pkgs; [
        eza
        bat
        ripgrep
        fd
        fzf
      ];

      home-manager.users.${vars.username} = {
        programs.fish = {
          enable = true;

          shellAliases = {
            initdirenv = ''
              if test -e .envrc
                echo ".envrc already exists"
                return 1
              end

              printf '%s\n' \
                'eval "$(devenv direnvrc)"' \
                'use devenv' \
                > .envrc

              direnv allow

              echo "Created and allowed .envrc"
            '';

            ls = "eza --icons";
            ll = "eza -lah --icons";
            la = "eza -a --icons";
            lt = "eza --tree --icons";

            cat = "bat";
            grep = "rg";
            find = "fd";
            f = "fzf";

            vi = "nvim";
            vim = "nvim";

            gs = "git status";
            ga = "git add";
            gc = "git commit";
            gp = "git push";
            gl = "git log --oneline --graph --decorate";

            c = "clear";
            ".." = "cd ..";
            "..." = "cd ../..";
          };

          shellAbbrs = {
            rebuild = "sudo nixos-rebuild switch --flake /home/lake/dotfiles/nixos#${vars.hostname}";
            update = "nix flake update";
          };

          interactiveShellInit = ''
            set -g fish_greeting

            # Vi-style Fish keybindings.
            fish_vi_key_bindings

            # Default editors and pager.
            set -gx EDITOR nvim
            set -gx VISUAL nvim
            set -gx PAGER less
            set -gx LESS "-R"

            # Prevent devenv from displaying its separate TUI.
            set -gx DEVENV_TUI false

            # Manually initialize Starship.
            # `enableFishIntegration` is unavailable in this
            # Home Manager version.
            starship init fish | source
          '';

          plugins = with pkgs.fishPlugins; [
            {
              name = "autopair";
              src = autopair.src;
            }

            {
              name = "colored-man-pages";
              src = colored-man-pages.src;
            }

            {
              name = "done";
              src = done.src;
            }

            {
              name = "sponge";
              src = sponge.src;
            }
          ];
        };

        programs.fzf = {
          enable = true;
          enableFishIntegration = true;

          # ─────────────────────────────────────────
          # File discovery
          # ─────────────────────────────────────────

          defaultCommand = "fd --type f --hidden --follow --exclude .git";

          fileWidget = {
            command = "fd --type f --hidden --follow --exclude .git";

            options = [
              "--preview"
              "bat --color=always --style=numbers --line-range=:300 {}"
            ];
          };

          # ─────────────────────────────────────────
          # Directory discovery
          # ─────────────────────────────────────────

          changeDirWidget = {
            command = "fd --type d --hidden --follow --exclude .git";
          };

          # ─────────────────────────────────────────
          # Fuzzy finder appearance
          # Catppuccin-inspired palette
          # ─────────────────────────────────────────

          defaultOptions = [
            "--height=60%"
            "--layout=reverse"
            "--border=rounded"

            "--prompt=❯ "
            "--pointer=▶"
            "--marker=✓"

            "--info=inline"

            "--padding=1"

            # Catppuccin Mocha-inspired colors.
            #
            # bg       = base
            # bg+      = surface0
            # fg       = text
            # fg+      = text
            # hl       = mauve
            # hl+      = mauve
            # border   = surface1
            # prompt   = mauve
            # pointer  = lavender
            # marker   = green
            # spinner  = mauve
            # header   = subtext0
            "--color=bg:#1e1e2e,bg+:#313244,fg:#cdd6f4,fg+:#cdd6f4"
            "--color=hl:#cba6f7,hl+:#cba6f7"
            "--color=border:#45475a"
            "--color=prompt:#cba6f7"
            "--color=pointer:#b4befe"
            "--color=marker:#a6e3a1"
            "--color=spinner:#cba6f7"
            "--color=header:#a6adc8"
            "--color=info:#89b4fa"
            "--color=query:#f5e0e8"
          ];

          historyWidget = {
            options = [
              "--height=60%"
              "--layout=reverse"
              "--border=rounded"

              "--prompt=❯ "
              "--pointer=▶"
              "--marker=✓"
              "--info=inline"

              "--color=bg:#1e1e2e,bg+:#313244,fg:#cdd6f4,fg+:#cdd6f4"
              "--color=hl:#cba6f7,hl+:#cba6f7"
              "--color=border:#45475a"
              "--color=prompt:#cba6f7"
              "--color=pointer:#b4befe"
              "--color=marker:#a6e3a1"
              "--color=spinner:#cba6f7"
              "--color=header:#a6adc8"
              "--color=info:#89b4fa"
              "--color=query:#f5e0e8"
            ];
          };
        };

        programs.starship = {
          enable = true;

          settings = {
            # ─────────────────────────────────────────
            # General
            # ─────────────────────────────────────────

            add_newline = true;

            format = builtins.concatStringsSep "" [
              "$os"
              "$username"
              "$hostname"
              "$directory"
              "$git_branch"
              "$git_status"
              "$nix_shell"
              "$nodejs"
              "$rust"
              "$python"
              "$docker_context"
              "$cmd_duration"
              "$line_break"
              "$character"
            ];

            # ─────────────────────────────────────────
            # NixOS
            # ─────────────────────────────────────────

            os = {
              disabled = false;
              style = "bold blue";
              format = "[$symbol]($style)";

              symbols = {
                NixOS = " ";
              };
            };

            # ─────────────────────────────────────────
            # User / hostname
            # ─────────────────────────────────────────

            username = {
              show_always = false;
              style_user = "bold lavender";
              style_root = "bold red";
              format = "[$user]($style) ";
            };

            hostname = {
              ssh_only = true;
              style = "bold mauve";
              format = "on [$hostname]($style) ";
            };

            # ─────────────────────────────────────────
            # Directory
            # ─────────────────────────────────────────

            directory = {
              style = "bold blue";
              truncation_length = 3;
              truncate_to_repo = true;
              format = "[$path]($style) ";
              read_only = " 󰌾";
            };

            # ─────────────────────────────────────────
            # Git
            # ─────────────────────────────────────────

            git_branch = {
              symbol = "󰘬 ";
              style = "bold mauve";
              format = "on [$symbol$branch]($style) ";
            };

            git_status = {
              style = "bold red";
              format = "([$all_status$ahead_behind]($style) )";

              conflicted = "=";
              ahead = "⇡$count";
              behind = "⇣$count";
              diverged = "⇕⇡$ahead_count⇣$behind_count";

              untracked = "?$count";
              stashed = "\\$$count";
              modified = "!$count";
              staged = "+$count";
              renamed = "»$count";
              deleted = "✘$count";
            };

            # ─────────────────────────────────────────
            # Nix / devenv
            # ─────────────────────────────────────────

            nix_shell = {
              symbol = " ";
              style = "bold cyan";
              format = "via [$symbol$name]($style) ";

              impure_msg = "impure";
              pure_msg = "pure";
              unknown_msg = "shell";
            };

            # ─────────────────────────────────────────
            # Node.js
            # ─────────────────────────────────────────

            nodejs = {
              symbol = " ";
              style = "bold green";
              format = "via [$symbol$version]($style) ";
            };

            # ─────────────────────────────────────────
            # Rust
            # ─────────────────────────────────────────

            rust = {
              symbol = " ";
              style = "bold red";
              format = "via [$symbol$version]($style) ";
            };

            # ─────────────────────────────────────────
            # Python
            # ─────────────────────────────────────────

            python = {
              symbol = " ";
              style = "bold yellow";
              format = "via [$symbol$version]($style) ";
            };

            # ─────────────────────────────────────────
            # Docker
            # ─────────────────────────────────────────

            docker_context = {
              symbol = " ";
              style = "bold blue";
              format = "via [$symbol$context]($style) ";
            };

            # ─────────────────────────────────────────
            # Command duration
            # ─────────────────────────────────────────

            cmd_duration = {
              min_time = 2000;
              style = "bold yellow";
              format = "took [$duration]($style) ";
            };

            # ─────────────────────────────────────────
            # Prompt character
            # ─────────────────────────────────────────

            character = {
              success_symbol = "[❯](bold green)";
              error_symbol = "[❯](bold red)";

              vimcmd_symbol = "[❮](bold mauve)";
              vimcmd_replace_one_symbol = "[❮](bold red)";
              vimcmd_replace_symbol = "[❮](bold red)";
              vimcmd_visual_symbol = "[❮](bold yellow)";
            };
          };
        };
      };
    };
}
