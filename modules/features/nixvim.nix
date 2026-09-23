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

        colorschemes.kanagawa = {
          enable = true;
          settings = {
            theme = "dragon";
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
          number = true;
          relativenumber = true;
          cursorline = true;
          cursorlineopt = "both";
          signcolumn = "yes:1";
          scrolloff = 8;
          sidescrolloff = 8;
          smoothscroll = true;
          wrap = false;
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
          softtabstop = 2;
          termguicolors = true;
          cmdheight = 0;
          laststatus = 3;
          showmode = false;
          showcmd = false;
          pumheight = 10;
          ruler = false;
          splitbelow = true;
          splitright = true;
          splitkeep = "screen";
          mouse = "a";
          clipboard = "unnamedplus";
          ignorecase = true;
          smartcase = true;
          hlsearch = true;
          incsearch = true;
          updatetime = 250;
          timeoutlen = 300;
          foldlevel = 99;
          foldlevelstart = 99;
          fillchars = {
            eob = " ";
          };
        };

        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };

        extraPackages = with pkgs; [
          ripgrep
          fd
          nil
          nixfmt
          deadnix
          statix
          lua-language-server
          stylua
          nodejs
          typescript
          vtsls
          tailwindcss-language-server
          vscode-langservers-extracted
          prettier
          yaml-language-server
          vscode-json-languageserver
          cargo
          rustc
          clippy
          rustfmt
          taplo
          cargo-watch
          cargo-edit
          cargo-nextest
          bacon
          clang-tools
          gcc
          cmake
          gnumake
          lldb
          ueberzugpp
          imagemagick
        ];

        highlight = {
          Normal = {
            bg = "none";
          };
          NormalNC = {
            bg = "none";
          };
          NormalFloat = {
            bg = "none";
          };
          FloatBorder = {
            fg = "#666666";
            bg = "none";
          };
          CursorLine = {
            bg = "#1f1f1f";
          };
          LineNr = {
            fg = "#555555";
          };
          CursorLineNr = {
            fg = "#aaaaaa";
            bold = true;
          };
          SignColumn = {
            bg = "none";
          };
          StatusLine = {
            fg = "#aaaaaa";
            bg = "none";
          };
          StatusLineNC = {
            fg = "#555555";
            bg = "none";
          };
          WinSeparator = {
            fg = "#333333";
          };
          Pmenu = {
            fg = "#aaaaaa";
            bg = "#151515";
          };
          PmenuSel = {
            fg = "#ffffff";
            bg = "#333333";
            bold = true;
          };
          Visual = {
            bg = "#333333";
          };
        };

        diagnostic.settings = {
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

        extraConfigLua = ''
          _G.typescript_goto_file = function()
            local ft = vim.bo.filetype

            local typescript_filetypes = {
              javascript = true,
              javascriptreact = true,
              typescript = true,
              typescriptreact = true,
            }

            if not typescript_filetypes[ft] then
              vim.cmd("normal! gf")
              return
            end

            local clients = vim.lsp.get_clients({
              bufnr = 0,
              name = "vtsls",
            })

            if #clients == 0 then
              vim.cmd("normal! gf")
              return
            end

            vim.lsp.buf.definition({
              reuse_win = true,
            })
          end

          vim.api.nvim_create_autocmd("FileType", {
            pattern = "netrw",
            callback = function()
              vim.keymap.set("n", "<Esc>", "<cmd>bd<CR>", {
                buffer = true,
                silent = true,
              })
            end,
          })
        '';

        plugins = {
          mini = {
            enable = true;
            modules = {
              comment = {
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
              icons = { };
            };
          };

          alpha = {
            enable = true;
            autoLoad = true;
            theme = null;
            settings = {
              layout = [
                {
                  type = "padding";
                  val = 2;
                }
                {
                  type = "text";
                  val = [
                    ''/\_/\ ''
                    "( o.o )"
                    "> ^ <"
                  ];
                  opts = {
                    hl = "Title";
                    position = "center";
                  };
                }
                {
                  type = "padding";
                  val = 2;
                }
                {
                  type = "text";
                  val = "  Neovim";
                  opts = {
                    hl = "Comment";
                    position = "center";
                  };
                }
              ];
            };
          };

          image = {
            enable = true;
            settings = {
              backend = "ueberzug";
              processor = "magick_cli";
              integrations.markdown = {
                enabled = true;
                clear_in_insert_mode = false;
                download_remote_images = true;
                only_render_image_at_cursor = false;
                only_render_image_at_cursor_mode = "inline";
                floating_windows = false;
                filetypes = [
                  "markdown"
                  "vimwiki"
                ];
              };
            };
          };

          render-markdown = {
            enable = true;
            settings = {
              enabled = true;
              render_modes = [
                "n"
                "c"
                "t"
              ];
              debounce = 100;
              signs.enabled = false;
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

          noice = {
            enable = true;
            settings = {
              cmdline = {
                enabled = true;
                view = "cmdline";
                format = {
                  cmdline = {
                    pattern = "^:";
                    icon = ">";
                    lang = "vim";
                  };
                  search_down = {
                    kind = "search";
                    pattern = "^/";
                    icon = "/";
                    lang = "regex";
                  };
                  search_up = {
                    kind = "search";
                    pattern = "^%?";
                    icon = "?";
                    lang = "regex";
                  };
                  filter = {
                    pattern = "^:%s*!";
                    icon = "$";
                    lang = "bash";
                  };
                  lua = {
                    pattern = [
                      "^:%s*lua%s+"
                      "^:%s*lua%s*=%s*"
                      "^:%s*=%s*"
                    ];
                    icon = ">";
                    lang = "lua";
                  };
                  help = {
                    pattern = "^:%s*he?l?p?%s+";
                    icon = "?";
                  };
                  input = {
                    view = "cmdline";
                    icon = ">";
                  };
                };
              };

              messages = {
                enabled = false;
                view = "notify";
                view_error = "notify";
                view_warn = "notify";
                view_history = "messages";
                view_search = "virtualtext";
              };

              popupmenu = {
                enabled = true;
                backend = "nui";
              };

              lsp = {
                progress.enabled = false;
                hover.enabled = true;
                signature.enabled = true;
              };

              notify = {
                enabled = false;
              };

              documentation = {
                view = "hover";
                opts = {
                  lang = "markdown";
                  replace = true;
                  render = "plain";
                  format = [
                    "{message}"
                  ];
                  win_options = {
                    concealcursor = "n";
                    conceallevel = 3;
                  };
                };
              };

              presets = {
                bottom_search = true;
                command_palette = false;
                long_message_to_split = true;
                lsp_doc_border = false;
              };
            };
          };

          todo-comments.enable = true;

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

          lsp = {
            enable = true;
            servers = {
              nil_ls = {
                enable = true;
                settings = {
                  formatting.command = [
                    "nixfmt"
                  ];
                  nix.flake.autoArchive = true;
                };
              };

              lua_ls.enable = true;

              vtsls = {
                enable = true;
                rootMarkers = [
                  "tsconfig.json"
                  "jsconfig.json"
                  "package.json"
                  ".git"
                ];
                settings = {
                  "typescript.suggest.autoImports" = true;
                  "typescript.suggest.paths" = true;
                  "typescript.preferences.importModuleSpecifier" = "shortest";
                  "typescript.preferences.includePackageJsonAutoImports" = "on";
                  "javascript.suggest.autoImports" = true;
                  "javascript.suggest.paths" = true;
                  "javascript.preferences.importModuleSpecifier" = "shortest";
                  "javascript.preferences.includePackageJsonAutoImports" = "on";
                  "typescript.updateImportsOnFileMove.enabled" = "always";
                  "javascript.updateImportsOnFileMove.enabled" = "always";
                };
              };

              tailwindcss.enable = true;
              eslint.enable = true;
              jsonls.enable = true;
              yamlls.enable = true;

              clangd = {
                enable = true;
                settings.clangd.fallbackFlags = [
                  "-std=c++20"
                ];
              };

              taplo.enable = true;

              rust_analyzer = {
                enable = true;
                installRustc = false;
                installCargo = false;
                settings = {
                  cargo = {
                    allFeatures = true;
                    buildScripts.enable = true;
                  };
                  procMacro.enable = true;
                  checkOnSave.command = "clippy";
                  inlayHints = {
                    bindingModeHints.enable = true;
                    closureCaptureHints.enable = true;
                    closureReturnTypeHints.enable = "always";
                    lifetimeElisionHints.enable = "always";
                    typeHints.enable = true;
                  };
                };
              };

              emmet_ls = {
                enable = true;
                filetypes = [
                  "html"
                  "css"
                  "javascriptreact"
                  "typescriptreact"
                ];
              };
            };
          };

          blink-cmp = {
            enable = true;
            settings = {
              completion = {
                documentation.auto_show = true;
                accept.auto_brackets.enabled = true;
                menu = {
                  border = "rounded";
                  draw.treesitter = [
                    "lsp"
                    "path"
                    "snippets"
                    "buffer"
                  ];
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
                "<Tab>" = [
                  "select_next"
                  "fallback"
                ];
                "<S-Tab>" = [
                  "select_prev"
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

          cord = {
            enable = true;
            autoLoad = true;
            settings = {
              editor = {
                tooltip = "??? why hover chrono??";
                icon = "https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExd2lkc3VmZTducW5kaDk1dmk5eGI3NHRnbzByaTZ0YzN2MnI1YzBieCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/iExhaYid5FfeyK0XuI/giphy.gif";
              };

              display = {
                theme = "atom";
                flavor = "accent";
                view = "editor";
                swap_icons = true;
              };

              text = {
                workspace.__raw = ''
                  function(opts)
                    if opts.workspace and opts.workspace ~= "" then
                      return "In " .. opts.workspace
                    end
                    return "In Neovim"
                  end
                '';

                editing.__raw = ''
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

                viewing.__raw = ''
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

              timestamp.enabled = true;

              idle = {
                enabled = true;
                timeout = 300000;
                show_status = true;
                ignore_focus = true;
                unidle_on_focus = true;
                smart_idle = true;
                details = "Idling";
              };

              advanced.discord.reconnect = {
                enabled = true;
                interval = 5000;
                initial = true;
              };
            };
          };

          lualine = {
            enable = true;
            settings = {
              options = {
                theme = {
                  normal = {
                    a = {
                      fg = "#111111";
                      bg = "#aaaaaa";
                      gui = "bold";
                    };
                    b = {
                      fg = "#aaaaaa";
                      bg = "#222222";
                    };
                    c = {
                      fg = "#888888";
                      bg = "#111111";
                    };
                  };

                  insert = {
                    a = {
                      fg = "#111111";
                      bg = "#aaaaaa";
                      gui = "bold";
                    };
                    b = {
                      fg = "#aaaaaa";
                      bg = "#222222";
                    };
                    c = {
                      fg = "#888888";
                      bg = "#111111";
                    };
                  };

                  visual = {
                    a = {
                      fg = "#111111";
                      bg = "#aaaaaa";
                      gui = "bold";
                    };
                    b = {
                      fg = "#aaaaaa";
                      bg = "#222222";
                    };
                    c = {
                      fg = "#888888";
                      bg = "#111111";
                    };
                  };

                  replace = {
                    a = {
                      fg = "#111111";
                      bg = "#aaaaaa";
                      gui = "bold";
                    };
                    b = {
                      fg = "#aaaaaa";
                      bg = "#222222";
                    };
                    c = {
                      fg = "#888888";
                      bg = "#111111";
                    };
                  };

                  command = {
                    a = {
                      fg = "#111111";
                      bg = "#aaaaaa";
                      gui = "bold";
                    };
                    b = {
                      fg = "#aaaaaa";
                      bg = "#222222";
                    };
                    c = {
                      fg = "#888888";
                      bg = "#111111";
                    };
                  };

                  inactive = {
                    a = {
                      fg = "#666666";
                      bg = "#111111";
                    };
                    b = {
                      fg = "#555555";
                      bg = "#111111";
                    };
                    c = {
                      fg = "#444444";
                      bg = "#111111";
                    };
                  };
                };

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

                lualine_x = [
                  "location"
                ];

                lualine_y = [ ];
                lualine_z = [ ];
              };
            };
          };

          telescope = {
            enable = true;

            keymaps = {
              "<leader>ff" = {
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
              fzf-native.enable = true;
            };

            settings = {
              defaults = {
                prompt_prefix = "   ";
                selection_caret = " > ";
                path_display = [
                  "truncate"
                ];
                sorting_strategy = "ascending";
                border = false;
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

                layout_strategy = "bottom_pane";

                layout_config = {
                  height = 0.35;
                  width = 1.0;
                  prompt_position = "top";
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

          indent-blankline = {
            enable = true;
            settings = {
              indent.char = "┊";
              scope = {
                enabled = true;
                char = "┃";
              };
              exclude.filetypes = [
                "help"
                "dashboard"
                "NvimTree"
                "TelescopePrompt"
                "TelescopeResults"
                "netrw"
              ];
            };
          };

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
                "c"
                "cpp"
                "cmake"
              ];
            };
          };

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

        keymaps = [
          {
            key = "gd";
            mode = "n";
            action = "<cmd>lua vim.lsp.buf.definition()<CR>";
            options.desc = "Go to definition";
          }

          {
            key = "gf";
            mode = "n";
            action = "<cmd>lua _G.typescript_goto_file()<CR>";
            options.desc = "Go to file or import";
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

          {
            key = "<leader>e";
            mode = "n";
            action = "<cmd>Explore<CR>";
            options.desc = "Open file explorer";
          }

          {
            key = "<leader>E";
            mode = "n";
            action = "<cmd>Lexplore<CR>";
            options.desc = "Open file explorer sidebar";
          }

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

          {
            key = "<leader>st";
            mode = "n";
            action = "<cmd>TodoTelescope<CR>";
            options.desc = "Search TODOs";
          }

          {
            key = "<leader>m";
            mode = "n";
            action = "<cmd>RenderMarkdown toggle<CR>";
            options.desc = "Toggle Markdown rendering";
          }

          {
            key = "za";
            mode = "n";
            action = "za";
            options.desc = "Toggle fold";
          }

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
