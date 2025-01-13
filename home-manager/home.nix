{ config, pkgs, inputs, ... }:
{
  imports = [
    ./neovim
  ];
  nixpkgs.config.allowUnfree = true;

  home.username = "dylan";
  home.homeDirectory = "/home/dylan";

  home.packages = with pkgs; [
    neofetch
    nnn

    zip
    xz
    unzip
    p7zip

    gcc

    ripgrep
    jq
    eza
    fzf
    thefuck
    bat

    which
    tree

    btop
    cowsay
    fortune

    usbutils

    vesktop
    ghostty
    spotify

    rust-analyzer

    monaspace
  ];

  programs.git = {
    enable = true;
    userName = "Dylan Bibb";
    userEmail = "wdylanbibb@gmail.com";
  };

  programs.firefox = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
      	"thefuck"
      	"aliases"
      	"alias-finder"
      	"eza"
      	"rsync"
      	"ssh"
      	"vi-mode"
      	"zsh-interactive-cd"
      	"rust"
      ];
    };
  };

  programs.vim = {
    enable = true;
  };

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "Monaspace Neon Var";
      font-family-bold = "Monaspace Xenon Var Bold";
      font-family-italic = "Monaspace Radon Var";
      font-family-bold-italic = "Mondaspace Neon Var Bolt Italic";
      font-feature = [
        "calt"
        "liga"
        "ss01"
        "ss02"
        "ss03"
        "ss08"
        "ss09"
      ];
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
