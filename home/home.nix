{ pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ./gtk.nix
    ./wezterm.nix
    ./git.nix
    ./vesktop.nix
    ./qtile
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "dylan";
  home.homeDirectory = "/home/dylan";

  programs.firefox.enable = true;

  home.packages = with pkgs; [
    neofetch

    vesktop
    spotify
    nautilus
    file-roller
    evince
  ];

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "26.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
