{ pkgs, var, ... }:
{
  home.packages = with pkgs; [
    spotify
    firefox
    var.libInputs.nix-cats.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
