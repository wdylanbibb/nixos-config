{ config, lib, pkgs, ... }:
{
  programs.nixvim.plugins = {
    conform-nvim.enable = true;
    
    treesitter = {
      enable = true;

      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    lsp = {
      enable = true;
      inlayHints = true;
    };

    rustaceanvim = {
      enable = true;
    };
  };
}