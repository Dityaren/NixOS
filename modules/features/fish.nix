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
            rebuild = "sudo nixos-rebuild switch --flake ${vars.flakeRoot}#${vars.hostname}";

            update = "nix flake update --flake ${vars.flakeRoot}";
          };

          interactiveShellInit = ''
            set -g fish_greeting

            fish_vi_key_bindings

            set -gx EDITOR nvim
            set -gx VISUAL nvim

            set -gx PAGER less
            set -gx LESS "-R"

            set -gx DEVENV_TUI false

            starship init fish | source

            function fzf_file_widget
              set -l selected (
                fd \
                  --type f \
                  --hidden \
                  --follow \
                  --exclude .git |
                fzf \
                  --preview 'bat --color=always --style=numbers --line-range=:300 {}'
              )

              if test -n "$selected"
                commandline -it -- "$selected"
              end

              commandline -f repaint
            end

            function fzf_directory_widget
              set -l selected (
                fd \
                  --type d \
                  --hidden \
                  --follow \
                  --exclude .git |
                fzf \
                  --preview 'eza --tree --icons --level=2 {}'
              )

              if test -n "$selected"
                cd -- "$selected"
              end

              commandline -f repaint
            end

            function fzf_history_widget
              set -l selected (
                history |
                fzf --tac
              )

              if test -n "$selected"
                commandline -- "$selected"
              end

              commandline -f repaint
            end

            bind -M insert \ct fzf_file_widget
            bind -M insert \ec fzf_directory_widget
            bind -M insert \cr fzf_history_widget
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

          enableFishIntegration = false;

          defaultCommand = "fd --type f --hidden --follow --exclude .git";

          defaultOptions = [
            "--height=60%"
            "--layout=reverse"
            "--border=rounded"
            "--info=inline"
            "--padding=1"

            "--prompt=❯ "
            "--pointer=▶"
            "--marker=✓"

            "--color=bg:#16161D,bg+:#1F1F28"
            "--color=fg:#DCD7BA,fg+:#DCD7BA"
            "--color=hl:#7E9CD8,hl+:#7E9CD8"
            "--color=border:#2A2A37"
            "--color=prompt:#7E9CD8"
            "--color=pointer:#DCA561"
            "--color=marker:#6A9589"
            "--color=spinner:#7FB4CA"
            "--color=header:#727169"
            "--color=info:#727169"
            "--color=query:#DCD7BA"
          ];
        };

        programs.starship = {
          enable = true;

          settings = {

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

            os = {
              disabled = false;
              style = "bold blue";
              format = "[$symbol]($style)";

              symbols = {
                NixOS = " ";
              };
            };

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

            directory = {
              style = "bold blue";
              truncation_length = 3;
              truncate_to_repo = true;
              format = "[$path]($style) ";
              read_only = " 󰌾";
            };

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

            nix_shell = {
              symbol = " ";
              style = "bold cyan";
              format = "via [$symbol$name]($style) ";

              impure_msg = "impure";
              pure_msg = "pure";
              unknown_msg = "shell";
            };

            nodejs = {
              symbol = " ";
              style = "bold green";
              format = "via [$symbol$version]($style) ";
            };

            rust = {
              symbol = " ";
              style = "bold red";
              format = "via [$symbol$version]($style) ";
            };

            python = {
              symbol = " ";
              style = "bold yellow";
              format = "via [$symbol$version]($style) ";
            };

            docker_context = {
              symbol = " ";
              style = "bold blue";
              format = "via [$symbol$context]($style) ";
            };

            cmd_duration = {
              min_time = 2000;
              style = "bold yellow";
              format = "took [$duration]($style) ";
            };

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
