{
  lib,
  config,
  var,
  pkgs,
  ...
}:
let
  cfg = config.features.users;

  userFiles =
    var.users
    |> builtins.readDir
    |> builtins.attrNames
    |> map (file: "${var.users}/${file}")
    |> map (path: {
      name =
        path |> builtins.baseNameOf |> builtins.unsafeDiscardStringContext |> lib.removeSuffix ".nix";
      value = path;
    })
    |> builtins.listToAttrs;

  mkUserOptions =
    userDir:
    with lib;
    mapAttrs (
      username: userPath:
      mkOption {
        type =
          with types;
          submodule {
            options = {
              enable = mkOption {
                type = bool;
                default = true;
                description = "Enable the user.";
              };
              extraGroups = mkOption {
                type = listOf str;
                default = [
                  "wheel"
                  "networkmanager"
                ];
                description = "Extra groups for the user.";
              };
            };
          };
        default = { };
        description = "Configuration for user ${username}.";
      }
    ) userFiles;
in
{
  options.features.users = {
    enable = lib.mkEnableOption "Enable the creation of users.";
    users = mkUserOptions var.users;
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;

    users = {
      mutableUsers = false;
      defaultUserShell = pkgs.zsh;
      users = lib.mapAttrs (
        name: value:
        {
          isNormalUser = true;
          hashedPasswordFile = config.sops.secrets.passwd.path;
        }
        // value
      ) cfg.users;
    };
  };
}
