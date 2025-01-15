{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ./home-shared.nix
  ];
  home.packages = with pkgs; [
    ghostty
  ];
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    installVimSyntax = true;
    settings = {
      font-family = "Monaspace Neon Var";
      font-family-bold = "Monaspace Neon Var Bold";
      font-family-italic = "Monaspace Radon Var Medium";
      font-family-bold-italic = "Monaspace Neon Var Bold Italic";
      font-feature = [
        "liga"
        "calt"
        "ss01"
        "ss02"
        "ss05"
        "ss08"
        "ss09"
      ];
    };
  };
}
