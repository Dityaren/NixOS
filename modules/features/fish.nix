{ ... }:

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
        bat
        ripgrep
        fd
        fzf
      ];

      home-manager.users.${vars.username} = {
        programs.fish = {
          enable = true;

          functions = {
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

            fzf_file_widget = ''
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
            '';

            fzf_directory_widget = ''
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
            '';

            fzf_history_widget = ''
              set -l selected (
                history |
                fzf --tac
              )

              if test -n "$selected"
                commandline -- "$selected"
              end

              commandline -f repaint
            '';
          };

          shellAliases = {
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

            l = "eza -l --git";
            tree = "eza --tree";

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

            bind -M insert \ct fzf_file_widget
            bind -M insert \ec fzf_directory_widget
            bind -M insert \cr fzf_history_widget
          '';

          plugins = [
            {
              name = "autopair";
              src = pkgs.fishPlugins.autopair.src;
            }

            {
              name = "colored-man-pages";
              src = pkgs.fishPlugins.colored-man-pages.src;
            }

            {
              name = "done";
              src = pkgs.fishPlugins.done.src;
            }

            {
              name = "sponge";
              src = pkgs.fishPlugins.sponge.src;
            }
          ];
        };

        # Installs eza and defines the aliases ls, ll, la, lt and lla for fish.
        # Icons need a Nerd Font in the terminal (set through Stylix).
        programs.eza = {
          enable = true;
          enableFishIntegration = true;
          icons = "auto";
          git = true;
          extraOptions = [
            "--group-directories-first"
            "--time-style=long-iso"
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
              style_user = "bold bright-blue";
              style_root = "bold red";
              format = "[$user]($style) ";
            };

            hostname = {
              ssh_only = true;
              style = "bold purple";
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
              style = "bold purple";
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
              vimcmd_symbol = "[❮](bold purple)";
              vimcmd_replace_one_symbol = "[❮](bold red)";
              vimcmd_replace_symbol = "[❮](bold red)";
              vimcmd_visual_symbol = "[❮](bold yellow)";
            };
          };
        };
      };
    };
}
