{
  config,
  lib,
  var,
  ...
}:
let
  cfg = config.modules.system.secrets;
in
{
  options.modules.system.secrets = with lib; {
    defaultSopsFile = mkOption {
      type = with types; path;
      description = "The directory to retrieve secrets from.";
      default = "${var.secrets}/secrets.yaml";
    };

    sshKeyPaths = mkOption {
      type = with types; listOf str;
      description = "SSH keys to be used for reading secrets.";
    };

    extraSecrets = mkOption {
      type =
        with types;
        attrsOf (submodule {
          options = {
            format = mkOption {
              type = types.enum [
                "yaml"
                "json"
                "binary"
                "dotenv"
                "ini"
              ];
              default = "yaml";
              description = ''
                File format used to decrypt the sops secret.
                Binary files are written to the target file as is.
              '';
            };
            sopsFile = mkOption {
              type = types.path;
              defaultText = literalExpression "\${config.sops.defaultSopsFile}";
              description = "Sops file the secret is loaded from.";
            };
            restartUnits = mkOption {
              type = with types; listOf str;
              default = [ ];
              description = "Names of units that should be restarted when this secret changes.";
            };
            reloadUnits = mkOption {
              type = with types; listOf str;
              default = [ ];
              description = "Names of units that should be reloaded when this secret changes.";
            };
            neededForUsers = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Enabling this option causes the secret to be decrypted before users and groups are created.
                This can be used to retrieve user's passwords from sops-nix.
                Setting this option moves the secret to /run/secrets-for-users and disallows setting owner and group to anything else than root.
              '';
            };
          };
        });
      default = { };
    };
  };

  config = {
    modules.system.secrets.sshKeyPaths = lib.mkDefault [
      "${lib.optionalString config.modules.system.persist.enable "/persist"}/etc/ssh/ssh_host_ed25519_sops"
    ];

    sops = {
      defaultSopsFile = cfg.defaultSopsFile;
      age.sshKeyPaths = cfg.sshKeyPaths;
      secrets = {
        passwd.neededForUsers = true;
        ts-authkey = lib.mkIf config.modules.system.network.tailscale.enable {
          restartUnits = [ "tailscaled.service" ];
        };
      }
      // cfg.extraSecrets;
    };
  };
}
