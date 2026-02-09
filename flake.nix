{
  description = "Dylan's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    impermanence.url = "github:nix-community/impermanence";

    nix-virt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/0.6.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cats.url = "github:wdylanbibb/nixcats-config";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./parts ];
      deploy = {
        hosts = ./hosts;
        var = {
          users = ./users;
          secrets = ./secrets;
        };
      };
    };

  # outputs =
  #   inputs@{ flake-parts, ... }:
  #   flake-parts.lib.mkFlake { inherit inputs; } {
  #     imports = [
  #       (flake-parts.lib.modules.importApply ./parts/module.nix inputs)
  #     ];
  #
  #     deploy = {
  #       hosts = ./hosts;
  #       users = ./users;
  #     };
  #
  #     perSystem =
  #       { pkgs, ... }:
  #       {
  #         formatter = pkgs.alejandra;
  #       };
  #   };
}
