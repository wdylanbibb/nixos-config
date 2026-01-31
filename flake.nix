{
  description = "Dylan's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
    inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        bleistein = nixpkgs.lib.nixosSystem {
          system = system;

          specialArgs = { inherit inputs; };

          modules = [
            ./nixos/configuration.nix
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            inputs.impermanence.nixosModules.impermanence
            inputs.nix-virt.nixosModules.default
          ];
        };
      };

      homeConfigurations."dylan" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = { inherit inputs; };

        modules = [
          ./home/home.nix
        ];
      };
    };
}
