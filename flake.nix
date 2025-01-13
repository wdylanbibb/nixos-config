# Designed around the standard NixOS config from
# https://github.com/Misterio77/nix-starter-configs
# Built using the NixOS and flakes book from
# https://nixos-and-flakes.thiscute.world/
{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # Helix editor, use the master branch
    # helix.url = "github:helix-editor/helix/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust overlay: https://github.com/oxalica/rust-overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # A Neovim configuration system for Nix: https://github.com/nix-community/nixvim
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, rust-overlay, nixvim, ... }@inputs: {
    # # Please replace my-nixos with your hostname
	  # nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
	  #   system = "x86_64-linux";
	  #   specialArgs = { inherit inputs; };
	  #   modules = [
	  #     # Our main nixos configuration file
	  #     ./nixos/configuration.nix
	
    #     # make home-manager as a module of nixos so that
    #     # home-manager configuration will be deployed automatically
    #     # when executing `nixos-rebuilt switch`
    #     home-manager.nixosModules.home-manager {
    #       home-manager.useGlobalPkgs = true;
    #       home-manager.useUserPackages = true;
        
    #       home-manager.users.dylan = import ./home-manager/home.nix;
    #     }
        
    #     ({ pkgs, ... }: {
    #       nixpkgs.overlays = [ rust-overlay.overlays.default ];
    #       environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
    #     })
	  #   ];
	  # };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./nixos/configuration.nix
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ rust-overlay.overlays.default ];
          environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
        })
      ];
    };

    homeConfigurations = {
      "dylan@nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
	extraSpecialArgs = { inherit inputs; };
	modules = [
	  ./home-manager/home.nix
	  # inputs.nixvim.homeManagerModules.nixvim
	];
      };
    };
  };
}
