{
  lib,
  inputs,
  config,
  ...
}:
rec {
  imports = [
    flake.flakeModules.default
    (import ./packages.nix { inherit inputs lib config; })
  ];

  flake = {
    inherit (inputs.flake-parts) lib;
    flakeModules = rec {
      flake = lib.modules.importApply ./module.nix inputs;
      default = flake;
    };
  };

  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.alejandra;
    };
}
