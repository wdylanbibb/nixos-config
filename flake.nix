# TODO:
#  * Declarative Virtual Machine creation
#     * https://github.com/AshleyYakeley/NixVirt
#  * Impermanence
#     * https://grahamc.com/blog/erase-your-darlings/
#     * https://grahamc.com/blog/erase-your-darlings/
#     * https://www.reddit.com/r/NixOS/comments/u09cz9/comment/i44jtnm/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button


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
    helix.url = "github:helix-editor/helix/master";

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

    # Zellij flake: https://github.com/a-kenji/zellij-nix
    zellij-nix = {
      url = "github:a-kenji/zellij-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake to declare virtual machines: https://flakehub.com/flake/AshleyYakeley/NixVirt?view=usage
    nix-virt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/0.5.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, rust-overlay, nixvim, zellij-nix, nix-virt, ... }@inputs: {
    nixosConfigurations = {
      spreckle = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration-laptop.nix
          home-manager.nixosModules.home-manager {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.dylan = import ./home-manager/home-laptop.nix;
          }
          ({ pkgs, ... }: {
            nixpkgs.overlays = [ rust-overlay.overlays.default ];
            environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
          })
        ];
      };

      bleistein = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          nix-virt.nixosModules.default
          ./nixos/configuration-desktop.nix
          home-manager.nixosModules.home-manager {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.dylan = import ./home-manager/home-desktop;
          }
          ({ pkgs, ... }: {
            nixpkgs.overlays = [ rust-overlay.overlays.default ];
            environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
          })
        ];
      };
    };
  };
}
