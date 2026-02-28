inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.wrapperModules.neovim ];

  options = {
    nvim-lib = {
      pluginsFromPrefix = lib.mkOption {
        readOnly = true;
        type = lib.types.raw;
        default =
          prefix: inputs:
          lib.pipe inputs [
            builtins.attrNames
            (builtins.filter (s: lib.hasPrefix prefix s))
            (map (
              input:
              let
                name = lib.removePrefix prefix input;
              in
              {
                inherit name;
                value = config.nvim-lib.mkPlugin name inputs.${input};
              }
            ))
            builtins.listToAttrs
          ];
      };

      neovimPlugins = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf wlib.types.stringable;
        default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
      };
    };

    settings = {
      colorscheme = lib.mkOption {
        type = lib.types.str;
        default = "onedark_dark";
      };

      cats = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf lib.types.bool;
        default = builtins.mapAttrs (_: v: v.enable) config.specs;
      };
    };
  };

  config = {
    settings = {
      config_directory = ./.;

      colorscheme = "tokyonight-night";

      anothertestvalue.settings = "can also accept freeform values";
    };

    specs = {
      colorscheme = {
        lazy = true;
        data = builtins.getAttr config.settings.colorscheme (
          with pkgs.vimPlugins;
          {
            "onedark_dark" = onedarkpro-nvim;
            "onedark_vivid" = onedarkpro-nvim;
            "onedark" = onedarkpro-nvim;
            "onelight" = onedarkpro-nvim;
            "tokyonight" = tokyonight-nvim;
            "tokyonight-night" = tokyonight-nvim;
            "tokyonight-moon" = tokyonight-nvim;
            "tokyonight-storm" = tokyonight-nvim;
            "tokyonight-day" = tokyonight-nvim;
          }
        );
      };

      lze = [
        config.nvim-lib.neovimPlugins.lze
        {
          data = config.nvim-lib.neovimPlugins.lzextras;
          name = "lzextras";
        }
      ];

      nix = {
        data = null;
        extraPackages = with pkgs; [
          nixd
          nixfmt
        ];
      };

      lua = {
        after = [ "general" ];
        lazy = true;
        data = with pkgs.vimPlugins; [ lazydev-nvim ];
        extraPackages = with pkgs; [
          lua-language-server
          stylua
        ];
      };

      rust = {
        after = [ "general" ];
        lazy = true;
        data = with pkgs.vimPlugins; [ rustaceanvim ];
        extraPackages = with pkgs; [
          # rust-bin.stable.latest.default
          # rust-analyzer
          vscode-extensions.vadimcn.vscode-lldb.adapter
        ];
      };

      general = {
        after = [ "lze" ];
        extraPackages = with pkgs; [
          lazygit
          tree-sitter
          ghostscript
          tectonic
        ];
        lazy = true;
        data = with pkgs.vimPlugins; [
          config.nvim-lib.neovimPlugins.nvim-recorder
          {
            data = vim-sleuth;
            lazy = false;
          }
          noice-nvim
          nvim-notify
          better-escape-nvim
          mini-nvim
          snacks-nvim
          nvim-lspconfig
          nvim-surround
          vim-startuptime
          blink-cmp
          blink-compat
          cmp-cmdline
          colorful-menu-nvim
          lualine-nvim
          gitsigns-nvim
          which-key-nvim
          fidget-nvim
          nvim-lint
          conform-nvim
          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars
          dropbar-nvim
          nvim-colorizer-lua
          luasnip
          friendly-snippets
        ];
      };
    };

    info.testvalue = {
      some = "stuff";
      goes = "here";
    };

    specMods =
      {
        parentSpec ? null,
        parentOpts ? null,
        parentName ? null,
        config,
        ...
      }:
      {
        options.extraPackages = lib.mkOption {
          type = lib.types.listOf wlib.types.stringable;
          default = [ ];
          description = "a extraPackages spec field to put packages to suffix to to PATH";
        };
      };

    extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [ ])) [ ];
  };
}
