{ pkgs, var, ... }:
{
  home.packages = with pkgs; [
    spotify
    firefox
  ];

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
