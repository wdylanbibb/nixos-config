{
  lib,
  inputs,
  ...
}:
rec {
  imports = [ flake.flakeModules.default ];

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
