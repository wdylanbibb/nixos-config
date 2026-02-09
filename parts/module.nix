localInputs:
{
  config,
  lib,
  inputs,
  ...
}:
let
  mkConfig =
    dir: mkValue:
    dir
    |> builtins.readDir
    |> builtins.attrNames
    |> map (file: "${dir}/${file}")
    |> map (mod: rec {
      name = mod |> builtins.baseNameOf |> builtins.unsafeDiscardStringContext |> lib.removeSuffix ".nix";
      value = mkValue { inherit name mod; };
    })
    |> builtins.listToAttrs;
in
{
  imports = [ ];

  options.deploy = with lib; {
    hosts = mkOption {
      type = with types; nullOr path;
      default = null;
    };

    users = mkOption {
      type = with types; nullOr path;
      default = null;
    };

    nixosModules = mkOption {
      type = with types; listOf deferredModule;
      default = [ ];
    };

    homeModules = mkOption {
      type = with types; listOf deferredModule;
      default = [ ];
    };

    var = {
      nixosModules = mkOption {
        type = with types; listOf deferredModule;
        default = [ ];
      };

      homeModules = mkOption {
        type = with types; listOf deferredModule;
        default = [ ];
      };

      users = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
      };

      secrets = mkOption {
        type = with types; path;
        default = "${inputs.self}/secrets";
      };

      overlays = mkOption {
        type = with types; listOf raw;
        default = [ ];
      };
    };
  };

  config = {
    _module.args = {
      inherit localInputs;
    };

    deploy = {
      nixosModules =
        with localInputs;
        lib.filesystem.listFilesRecursive ../nixos
        ++ [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          nix-virt.nixosModules.default
        ];
      homeModules = lib.filesystem.listFilesRecursive ../home;
    };

    flake = {
      nixosConfigurations = mkConfig config.deploy.hosts (
        { name, mod }:
        localInputs.nixpkgs.lib.nixosSystem {
          modules = config.deploy.nixosModules ++ [
            mod
            localInputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs.var = config.deploy.var // {
                  libInputs = localInputs;
                };

                users = mkConfig config.deploy.var.users (
                  { name, mod }:
                  {
                    imports = config.deploy.homeModules ++ [ mod ];
                  }
                );
              };
            }
          ];
          specialArgs.var = config.deploy.var // {
            libInputs = localInputs;
            host = mod;
            hostName = name;
          };
        }
      );
    };

    perSystem =
      {
        system,
        pkgs,
        ...
      }:
      {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };

    systems = lib.mkDefault lib.systems.flakeExposed;
  };
}
