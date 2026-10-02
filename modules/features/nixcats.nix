{ inputs, ... }:
let
  inherit (inputs.nixCats) utils;

  defaultPackageName = "nvim";
  luaPath = ./nvim;

  extra_pkg_config = { };

  categoryDefinitions =
    { pkgs, ... }:
    {
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          ripgrep
          fd
          nil
          nixfmt
          deadnix
          statix
          lua-language-server
          stylua
          nodejs_24
          typescript
          vtsls
          tailwindcss-language-server
          vscode-langservers-extracted
          prettier
          yaml-language-server
          vscode-json-languageserver
          emmet-ls
          cargo
          rustc
          clippy
          rustfmt
          rust-analyzer
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
      };

      startupPlugins = {
        general = with pkgs.vimPlugins; [
          plenary-nvim
          nui-nvim
          nvim-web-devicons
          kanagawa-nvim
          mini-nvim
          alpha-nvim
          image-nvim
          render-markdown-nvim
          nvim-autopairs
          luasnip
          friendly-snippets
          nvim-ts-autotag
          better-escape-nvim
          flash-nvim
          smear-cursor-nvim
          gitsigns-nvim
          which-key-nvim
          trouble-nvim
          harpoon2
          noice-nvim
          todo-comments-nvim
          vim-illuminate
          nvim-colorizer-lua
          nvim-lspconfig
          blink-cmp
          cord-nvim
          lualine-nvim
          telescope-nvim
          telescope-fzf-native-nvim
          indent-blankline-nvim
          nvim-treesitter.withAllGrammars
          conform-nvim
        ];
      };
    };

  packageDefinitions = {
    nvim =
      { ... }:
      {
        settings = {
          wrapRc = true;
          aliases = [
            "vim"
            "nixvim"
          ];
        };
        categories = {
          general = true;
        };
      };
  };
in
{
  #   nvim = { enable = true; packageNames = [ "nvim" ]; };
  flake.nixosModules.nixcats = utils.mkNixosModules {
    inherit
      defaultPackageName
      luaPath
      categoryDefinitions
      packageDefinitions
      extra_pkg_config
      ;
    inherit (inputs) nixpkgs;
    dependencyOverlays = [ ];
  };
}
