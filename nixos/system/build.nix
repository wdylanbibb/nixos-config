{ config, var, ... }:
{
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
    clean = {
      enable = true;
      extraArgs = "--keep 5 --keep-since 30d";
    };
  };

  nix.settings = {
    extra-experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
  };

  nixpkgs = {
    inherit (var) overlays;
    config = {
      inherit (config.nixpkgs) overlays;
      allowUnfree = true;
    };
  };

  system.stateVersion = "25.11";
}
