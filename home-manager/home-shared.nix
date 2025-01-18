{ config, pkgs, inputs, ... }:
{
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
    xclip

    zoxide

    which
    tree

    btop
    cowsay
    fortune

    usbutils

    vesktop
    spotify

    rust-analyzer

    monaspace

    zsh-forgit
    zsh-command-time

    zellij
    liquidprompt
  ];

  programs.git = {
    enable = true;
    userName = "Dylan Bibb";
    userEmail = "wdylanbibb@gmail.com";
  };

  programs.firefox = {
    enable = true;
  };

  programs.zoxide.enable = true;
  
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      if [[ -z "$ZELLIJ" ]]; then
        if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
          zellij attach -c
        else
          zellij
        fi

        if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
          exit
        fi
      fi
      [[ $- = *i* ]] && source $(nix path-info nixpkgs#liquidprompt)/bin/liquidprompt
    '';
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
    # Seems like a bad idea...
    # shellAliases = {
    #   home-manager = "home-manager --flake $(readlink /etc/nixos)#$(whoami)@$(hostname)";
    #   nixos-rebuild = "nixos-rebuild --flake $(readlink /etc/nixos)#$(whoami)@$(hostname)";
    # };
  };

  programs.vim = {
    enable = true;
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
