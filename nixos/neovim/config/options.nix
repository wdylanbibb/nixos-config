{ config, lib, ... }:
{
    programs.nixvim.opts = {
      relativenumber = true;
      number = true;
      mouse = "a";

      termguicolors = true;
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      autoindent = true;
    };
}