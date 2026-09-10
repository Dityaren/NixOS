{ self, inputs, ... }:
{
  flake.nixosModules.nixvim =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.nixvim.nixosModules.nixvim
      ];

      programs.nixvim = {
        enable = true;

        # ─────────────────────────────────────────────────────────────────────
        # Appearance
        # ─────────────────────────────────────────────────────────────────────

        colorschemes.kanagawa = {
          enable = true;
          settings = {
            theme = "wave";
            transparent = true;
            terminalColors = true;
            dimInactive = false;
            commentStyle.italic = true;
            keywordStyle.italic = true;
            statementStyle.bold = true;
            undercurl = true;
          };
        };

        opts = {
          # Numbers / cursor
          number = true;
          relativenumber = true;
          cursorline = true;
          cursorlineopt = "both";
          signcolumn = "yes:1";

          # Scrolling
          scrolloff = 8;
          sidescrolloff = 8;
          smoothscroll = true;

          # Editing
          wrap = false;
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
          softtabstop = 2;

          # UI
          termguicolors = true;
          cmdheight = 0;
          laststatus = 3;
          showmode = false;
          showcmd = false;
          pumheight = 10;
          ruler = false;

          # Splits
          splitbelow = true;
          splitright = true;
          splitkeep = "screen";

          # Interaction
          mouse = "a";
          clipboard = "unnamedplus";

          # Search
          ignorecase = true;
          smartcase = true;
          hlsearch = true;
          incsearch = true;

          # Completion / responsiveness
          updatetime = 250;
          timeoutlen = 300;

          # Folding
          foldlevel = 99;
          foldlevelstart = 99;

          # Don't show ~ on empty lines at the end of a buffer.
          fillchars = {
            eob = " ";
          };
        };

        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };

        extraPackages = with pkgs; [
          # General tools
          ripgrep
          fd

          # Nix development
          nil
          nixfmt
          deadnix
          statix

          # Lua development
          lua-language-server
          stylua

          # Web development
          nodejs
          typescript-language-server
          tailwindcss-language-server
          vscode-langservers-extracted
          prettier
          yaml-language-server
          vscode-json-languageserver

          # Rust
          cargo
          rustc
          clippy
          rustfmt
          taplo

          # Rust workflow
          cargo-watch
          cargo-edit
          cargo-nextest
          bacon

          # C / C++
          clang-tools
          gcc
          cmake
          gnumake

          # Debugging
          lldb
        ];

        # ─────────────────────────────────────────────────────────────────────
        # Diagnostics
        # ─────────────────────────────────────────────────────────────────────

        diagnostic.settings = {
          # lsp-lines renders diagnostics below the affected line instead of
          # creating noisy inline virtual text.
          virtual_text = false;
          underline = true;
          signs = true;
          severity_sort = true;
          update_in_insert = false;
          float = {
            border = "rounded";
            source = "if_many";
          };
        };

        # ─────────────────────────────────────────────────────────────────────
        # Plugins
        # ─────────────────────────────────────────────────────────────────────

        plugins = {
          # ── Editing ────────────────────────────────────────────────────────

          mini-comment = {
            enable = true;

            settings = {
              mappings = {
                comment = "<leader>/";
                comment_line = "<leader>/";
                comment_visual = "<leader>/";
                textobject = "<leader>/";
              };

              options = {
                ignore_blank_line = false;
                pad_comment_parts = true;
                start_of_line = false;
              };
            };
          };

          nvim-autopairs = {
            enable = true;

            settings = {
              checkTs = true;
            };
          };

          luasnip.enable = true;
          friendly-snippets.enable = true;

          ts-autotag = {
            enable = true;
          };

          better-escape.enable = true;

          flash = {
            enable = true;
            settings = {
              labels = "asdfghjklqwertyuiopzxcvbnm";
              modes = {
                search.enabled = true;
                char = {
                  enabled = true;
                  jump_labels = true;
                  multi_line = false;
                };
                treesitter.labels = "abcdefghijklmnopqrstuvwxyz";
              };
            };
          };

          smear-cursor = {
            enable = true;
            settings = {
              stiffness = 0.8;
              trailing_stiffness = 0.5;
              distance_stop_animating = 0.5;
              hide_target_hack = false;
            };
          };

          # ── Git / navigation ──────────────────────────────────────────────

          gitsigns = {
            enable = true;

            settings = {
              current_line_blame = false;

              signs = {
                add = {
                  text = "▎";
                };
                change = {
                  text = "▎";
                };
                delete = {
                  text = "";
                };
                topdelete = {
                  text = "";
                };
                changedelete = {
                  text = "▎";
                };
              };
            };
          };

          which-key = {
            enable = true;

            settings = {
              preset = "modern";
              delay = 300;
            };
          };

          trouble.enable = true;
          web-devicons.enable = true;

          harpoon = {
            enable = true;
            enableTelescope = true;

            settings = {
              settings = {
                save_on_toggle = true;
                sync_on_ui_close = true;
              };
            };
          };

          # ── UI ────────────────────────────────────────────────────────────

          # Replaces the traditional command line, search prompt and noisy
          # LSP messages with floating UI.
          noice = {
            enable = true;

            settings = {
              presets = {
                bottom_search = true;
                command_palette = true;
                long_message_to_split = true;
                lsp_doc_border = true;
              };

              lsp = {
                progress = {
                  enabled = true;
                };

                hover = {
                  enabled = true;
                };

                signature = {
                  enabled = true;
                };
              };

              messages = {
                enabled = true;
              };

              notify = {
                enabled = true;
              };
            };
          };

          # Highlights TODO/FIXME/HACK/WARN/NOTE comments and integrates with
          # the normal search/list workflow.
          todo-comments = {
            enable = true;
          };

          # Highlights references to the symbol under the cursor.
          illuminate = {
            enable = true;

            settings = {
              delay = 200;
              min_count_to_highlight = 2;

              providers = [
                "lsp"
                "treesitter"
              ];

              under_cursor = true;
            };
          };

          # Better visual rendering for CSS/HTML color values.
          colorizer = {
            enable = true;

            settings = {
              filetypes = [
                "css"
                "scss"
                "sass"
                "less"
                "html"
                "javascript"
                "javascriptreact"
                "typescript"
                "typescriptreact"
              ];

              user_default_options = {
                mode = "virtualtext";
                names = false;
                virtualtext = "■ ";
              };
            };
          };

          # Cleaner multi-line LSP diagnostics.
          lsp-lines.enable = true;

          # ── File explorer ─────────────────────────────────────────────────

          neo-tree = {
            enable = true;

            settings = {
              close_if_last_window = true;

              filesystem = {
                filtered_items = {
                  visible = true;
                  hide_dotfiles = false;
                  hide_gitignored = false;

                  hide_by_name = [
                    "node_modules"
                    ".git"
                    "dist"
                    "build"
                  ];
                };

                follow_current_file = {
                  enabled = true;
                };

                hijack_netrw_behavior = "open_default";
              };

              window = {
                position = "left";
                width = 35;
              };
            };
          };

          # ── LSP ──────────────────────────────────────────────────────────

          lsp = {
            enable = true;

            servers = {
              nil_ls = {
                enable = true;

                settings = {
                  formatting = {
                    command = [ "nixfmt" ];
                  };

                  nix = {
                    flake = {
                      autoArchive = true;
                    };
                  };
                };
              };

              lua_ls.enable = true;

              ts_ls.enable = true;

              tailwindcss.enable = true;

              eslint.enable = true;
              jsonls.enable = true;
              yamlls.enable = true;

              clangd = {
                enable = true;

                settings = {
                  clangd = {
                    fallbackFlags = [
                      "-std=c++20"
                    ];
                  };
                };
              };
            };
          };

          lsp.servers.taplo.enable = true;

          lsp.servers.rust_analyzer = {
            enable = true;

            installRustc = false;
            installCargo = false;

            settings = {
              cargo = {
                allFeatures = true;

                buildScripts = {
                  enable = true;
                };
              };

              procMacro = {
                enable = true;
              };

              checkOnSave = {
                command = "clippy";
              };

              inlayHints = {
                bindingModeHints.enable = true;
                closureCaptureHints.enable = true;
                closureReturnTypeHints.enable = "always";
                lifetimeElisionHints.enable = "always";
                typeHints.enable = true;
              };
            };
          };

          lsp.servers.emmet_ls = {
            enable = true;

            filetypes = [
              "html"
              "css"
              "javascriptreact"
              "typescriptreact"
            ];
          };

          # ── Completion ────────────────────────────────────────────────────

          blink-cmp = {
            enable = true;

            settings = {
              completion = {
                documentation.auto_show = true;

                accept = {
                  auto_brackets.enabled = true;
                };

                menu = {
                  border = "rounded";
                  draw = {
                    treesitter = [
                      "lsp"
                      "path"
                      "snippets"
                      "buffer"
                    ];
                  };
                };
              };

              keymap = {
                preset = "default";

                "<CR>" = [
                  "accept"
                  "fallback"
                ];

                "<C-m>" = [
                  "accept"
                  "fallback"
                ];
              };

              sources.default = [
                "lsp"
                "path"
                "snippets"
                "buffer"
              ];
            };
          };

          # ── Statusline ────────────────────────────────────────────────────

          # ── Discord Rich Presence ───────────────────────────────────────────
          # Uses Cord's built-in Neovim Discord application by default.
          # To use your own Discord application and custom main image, replace
          # discordApplicationId and discordIconUrl below.

          cord = {
            enable = true;
            autoLoad = true;

            settings = {
              editor = {
                # Create a Discord application and put its Application ID here.
                # client = "YOUR_DISCORD_APPLICATION_ID";

                # Text shown when hovering over the main image.
                tooltip = "??? why hover chrono??";

                # Your custom main/editor image.
                icon = "https://c.tenor.com/MYFOhiSPB6cAAAAC/tenor.gif";
              };

              display = {
                theme = "atom";
                flavor = "accent";

                # Only show the editor/main image.
                view = "editor";

                swap_icons = true;
              };

              text = {
                workspace = {
                  __raw = ''
                    function(opts)
                      if opts.workspace and opts.workspace ~= "" then
                        return "In " .. opts.workspace
                      end

                      return "In Neovim"
                    end
                  '';
                };

                editing = {
                  __raw = ''
                    function(opts)
                      local names = {
                        javascript = "JavaScript",
                        javascriptreact = "JavaScript React",
                        typescript = "TypeScript",
                        typescriptreact = "TypeScript React",
                        nix = "Nix",
                        lua = "Lua",
                        rust = "Rust",
                        c = "C",
                        cpp = "C++",
                        python = "Python",
                        html = "HTML",
                        css = "CSS",
                        scss = "SCSS",
                        sass = "Sass",
                        less = "Less",
                        json = "JSON",
                        jsonc = "JSONC",
                        yaml = "YAML",
                        toml = "TOML",
                        markdown = "Markdown",
                        bash = "Bash",
                        sh = "Shell",
                        zsh = "Shell",
                        vim = "Vim Script",
                        cmake = "CMake",
                        sql = "SQL",
                        java = "Java",
                        go = "Go",
                        php = "PHP",
                      }

                      local filetype = names[opts.filetype] or opts.filetype

                      if not filetype or filetype == "" then
                        return "Editing"
                      end

                      return "Editing " .. filetype
                    end
                  '';
                };

                viewing = {
                  __raw = ''
                    function(opts)
                      local names = {
                        javascript = "JavaScript",
                        javascriptreact = "JavaScript React",
                        typescript = "TypeScript",
                        typescriptreact = "TypeScript React",
                        nix = "Nix",
                        lua = "Lua",
                        rust = "Rust",
                        c = "C",
                        cpp = "C++",
                        python = "Python",
                        html = "HTML",
                        css = "CSS",
                        json = "JSON",
                        jsonc = "JSONC",
                        yaml = "YAML",
                        toml = "TOML",
                        markdown = "Markdown",
                      }

                      local filetype = names[opts.filetype] or opts.filetype

                      if not filetype or filetype == "" then
                        return "Viewing"
                      end

                      return "Viewing " .. filetype
                    end
                  '';
                };

                file_browser = "Browsing files";
                plugin_manager = "Managing plugins";
                lsp = "Configuring LSP";
                docs = "Reading documentation";
                vcs = "Working with version control";
                notes = "Taking notes";
                debug = "Debugging";
                test = "Running tests";
                diagnostics = "Checking diagnostics";
                terminal = "Using terminal";
                dashboard = "Home";
              };

              timestamp = {
                enabled = true;
              };

              idle = {
                enabled = true;
                timeout = 300000;
                show_status = true;
                ignore_focus = true;
                unidle_on_focus = true;
                smart_idle = true;
                details = "Idling";
              };

              advanced = {
                discord = {
                  reconnect = {
                    enabled = true;
                    interval = 5000;
                    initial = true;
                  };
                };
              };
            };
          };

          lualine = {
            enable = true;
            settings = {
              options = {
                theme = "kanagawa";
                globalstatus = true;
                icons_enabled = true;
                component_separators = {
                  left = "│";
                  right = "│";
                };
                section_separators = {
                  left = "";
                  right = "";
                };
                disabled_filetypes.statusline = [
                  "neo-tree"
                  "dashboard"
                  "alpha"
                ];
              };

              sections = {
                lualine_a = [
                  {
                    __unkeyed = "mode";
                    fmt = "function(str) return str:sub(1, 1) end";
                  }
                ];
                lualine_b = [
                  {
                    __unkeyed = "branch";
                    icon = "󰘬";
                  }
                ];
                lualine_c = [
                  {
                    __unkeyed = "filename";
                    path = 1;
                    symbols = {
                      modified = " ●";
                      readonly = " 󰌾";
                      unnamed = "[No Name]";
                    };
                  }
                ];
                lualine_x = [
                  {
                    __unkeyed = "diagnostics";
                    symbols = {
                      error = "󰅚 ";
                      warn = "󰀪 ";
                      info = "󰋽 ";
                      hint = "󰌵 ";
                    };
                  }
                ];
                lualine_y = [
                  {
                    __unkeyed = "filetype";
                    icon_only = true;
                  }
                ];
                lualine_z = [
                  {
                    __unkeyed = "location";
                    padding = 1;
                  }
                ];
              };

              inactive_sections = {
                lualine_a = [ ];
                lualine_b = [ ];
                lualine_c = [
                  {
                    __unkeyed = "filename";
                    path = 1;
                  }
                ];
                lualine_x = [ "location" ];
                lualine_y = [ ];
                lualine_z = [ ];
              };
            };
          };

          # ── Telescope ─────────────────────────────────────────────────────

          telescope = {
            enable = true;

            keymaps = {
              "<leader>ff" = {
                action = "find_files";
                options.desc = "Find files";
              };

              "<leader>fg" = {
                action = "live_grep";
                options.desc = "Live grep";
              };

              "<leader>fb" = {
                action = "buffers";
                options.desc = "Find buffers";
              };

              "<leader>fh" = {
                action = "help_tags";
                options.desc = "Help tags";
              };

              "<leader>fr" = {
                action = "oldfiles";
                options.desc = "Recent files";
              };
            };

            extensions = {
              fzf-native = {
                enable = true;
              };
            };

            settings = {
              defaults = {
                prompt_prefix = "   ";
                selection_caret = " 󰁔 ";

                path_display = [
                  "truncate"
                ];

                sorting_strategy = "ascending";

                border = true;
                borderchars = [
                  "─"
                  "│"
                  "─"
                  "│"
                  "╭"
                  "╮"
                  "╯"
                  "╰"
                ];

                layout_config = {
                  horizontal = {
                    prompt_position = "top";
                    preview_width = 0.55;
                  };

                  vertical = {
                    mirror = true;
                  };

                  width = 0.9;
                  height = 0.8;
                };

                file_ignore_patterns = [
                  "node_modules"
                  ".git/"
                  "dist/"
                  "build/"
                  ".next/"
                  "target/"
                ];
              };
            };
          };

          # ── Harpoon ───────────────────────────────────────────────────────

          # Kept because the existing workflow uses Harpoon directly.
          # Telescope integration is enabled above.

          # ── Indentation ───────────────────────────────────────────────────

          indent-blankline = {
            enable = true;

            settings = {
              indent = {
                char = "┊";
              };

              scope = {
                enabled = true;
                char = "┃";
              };

              exclude = {
                filetypes = [
                  "help"
                  "dashboard"
                  "NvimTree"
                  "neo-tree"
                  "TelescopePrompt"
                  "TelescopeResults"
                ];
              };
            };
          };

          # ── Syntax / Treesitter ──────────────────────────────────────────

          treesitter = {
            enable = true;

            settings = {
              highlight.enable = true;
              indent.enable = true;

              ensure_installed = [
                "nix"
                "lua"
                "vim"
                "vimdoc"
                "regex"
                "bash"

                "json"
                "jsonc"
                "javascript"
                "typescript"
                "tsx"
                "html"
                "css"
                "yaml"

                "markdown"
                "markdown_inline"

                "rust"
                "toml"
                "ron"

                # C / C++
                "c"
                "cpp"
                "cmake"
              ];
            };
          };

          # ── Formatting ────────────────────────────────────────────────────

          conform-nvim = {
            enable = true;

            settings = {
              formatters_by_ft = {
                nix = [
                  "nixfmt"
                ];

                lua = [
                  "stylua"
                ];

                javascript = [
                  "prettier"
                ];

                javascriptreact = [
                  "prettier"
                ];

                typescript = [
                  "prettier"
                ];

                typescriptreact = [
                  "prettier"
                ];

                json = [
                  "prettier"
                ];

                jsonc = [
                  "prettier"
                ];

                yaml = [
                  "prettier"
                ];

                markdown = [
                  "prettier"
                ];

                markdown_inline = [
                  "prettier"
                ];

                html = [
                  "prettier"
                ];

                css = [
                  "prettier"
                ];

                rust = [
                  "rustfmt"
                ];

                toml = [
                  "taplo"
                ];

                # C / C++
                c = [
                  "clang-format"
                ];

                cpp = [
                  "clang-format"
                ];

                objc = [
                  "clang-format"
                ];

                objcpp = [
                  "clang-format"
                ];
              };

              format_on_save = {
                lsp_fallback = true;
                timeout_ms = 1000;
              };
            };
          };
        };

        # ─────────────────────────────────────────────────────────────────────
        # Keymaps
        # ─────────────────────────────────────────────────────────────────────

        keymaps = [
          # LSP
          {
            key = "gd";
            mode = "n";
            action = "<cmd>lua vim.lsp.buf.definition()<CR>";
            options.desc = "Go to definition";
          }

          {
            key = "gD";
            mode = "n";
            action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
            options.desc = "Go to declaration";
          }

          {
            key = "gr";
            mode = "n";
            action = "<cmd>lua vim.lsp.buf.references()<CR>";
            options.desc = "Find references";
          }

          {
            key = "gi";
            mode = "n";
            action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
            options.desc = "Go to implementation";
          }

          {
            key = "K";
            mode = "n";
            action = "<cmd>lua vim.lsp.buf.hover()<CR>";
            options.desc = "Hover documentation";
          }

          {
            key = "<leader>rn";
            mode = "n";
            action = "<cmd>lua vim.lsp.buf.rename()<CR>";
            options.desc = "Rename symbol";
          }

          {
            key = "<leader>ca";
            mode = [
              "n"
              "v"
            ];
            action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
            options.desc = "Code action";
          }

          {
            key = "<leader>cf";
            mode = "n";
            action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<CR>";
            options.desc = "Format buffer";
          }

          # Diagnostics
          {
            key = "[d";
            mode = "n";
            action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
            options.desc = "Previous diagnostic";
          }

          {
            key = "]d";
            mode = "n";
            action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
            options.desc = "Next diagnostic";
          }

          {
            key = "<leader>xx";
            mode = "n";
            action = "<cmd>Trouble diagnostics toggle<CR>";
            options.desc = "Toggle diagnostics";
          }

          # File explorer
          {
            key = "<leader>e";
            mode = "n";
            action = "<cmd>Neotree toggle<CR>";
            options.desc = "Toggle file explorer";
          }

          {
            key = "<leader>o";
            mode = "n";
            action = "<cmd>Neotree reveal<CR>";
            options.desc = "Reveal current file";
          }

          # Telescope
          {
            key = "<leader><space>";
            mode = "n";
            action = "<cmd>Telescope find_files<CR>";
            options.desc = "Find files";
          }

          {
            key = "<leader>sg";
            mode = "n";
            action = "<cmd>Telescope live_grep<CR>";
            options.desc = "Search project";
          }

          # Harpoon
          {
            key = "<leader>a";
            mode = "n";
            action = "<cmd>lua require('harpoon'):list():add()<cr>";
            options.desc = "Harpoon add file";
          }

          {
            key = "<leader>h";
            mode = "n";
            action = "<cmd>lua require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())<cr>";
            options.desc = "Harpoon menu";
          }

          {
            key = "<leader>1";
            mode = "n";
            action = "<cmd>lua require('harpoon'):list():select(1)<cr>";
            options.desc = "Harpoon file 1";
          }

          {
            key = "<leader>2";
            mode = "n";
            action = "<cmd>lua require('harpoon'):list():select(2)<cr>";
            options.desc = "Harpoon file 2";
          }

          {
            key = "<leader>3";
            mode = "n";
            action = "<cmd>lua require('harpoon'):list():select(3)<cr>";
            options.desc = "Harpoon file 3";
          }

          {
            key = "<leader>4";
            mode = "n";
            action = "<cmd>lua require('harpoon'):list():select(4)<cr>";
            options.desc = "Harpoon file 4";
          }

          # Noice
          {
            key = "<leader>sn";
            mode = "n";
            action = "<cmd>Noice<CR>";
            options.desc = "Noice message history";
          }

          {
            key = "<leader>nl";
            mode = "n";
            action = "<cmd>Noice last<CR>";
            options.desc = "Show last message";
          }

          # TODOs
          {
            key = "<leader>st";
            mode = "n";
            action = "<cmd>TodoTelescope<CR>";
            options.desc = "Search TODOs";
          }

          # Fold
          {
            key = "za";
            mode = "n";
            action = "za";
            options.desc = "Toggle fold";
          }

          # Clear search highlighting
          {
            key = "<Esc>";
            mode = "n";
            action = "<cmd>nohlsearch<CR>";
            options.desc = "Clear search highlight";
          }
        ];
      };
    };
}
