{ config, inputs, ... }:
let
  helper = config.lib.nixvim;
in
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./plugins/code.nix
    ./plugins/colorscheme.nix
    ./plugins/editor.nix
    ./plugins/opts.nix

    ./config/autocmds.nix
    ./config/keymaps.nix
    ./config/options.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
  };
}
