{ config, lib, ... }:
let
  cfg = config.modules.system.persist;
in
{
  options.modules.system.persist = with lib; {
    enable = mkEnableOption "Enable impermanence.";

    directory = mkOption {
      type = with types; str;
      description = "Which directory to save persisted files.";
      default = "/persist";
      readOnly = true;
    };

    extraDirectories = mkOption {
      type = with types; listOf (either attrs str);
      description = "Extra directories to persist.";
      default = [ ];
    };

    extraFiles = mkOption {
      type = with types; listOf (either attrs str);
      description = "Extra files to persist.";
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    # Reset root subvolume on boot
    boot.initrd.systemd.enable = true;

    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root subvolume";
      wantedBy = [ "initrd.target" ];

      requires = [ "dev-disk-by\\x2dpartlabel-disk\\x2dmain\\x2droot.device" ];
      after = [ "dev-disk-by\\x2dpartlabel-disk\\x2dmain\\x2droot.device" ];
      before = [ "sysroot.mount" ];

      unitConfig.DefaultDependencies = false;
      serviceConfig.Type = "oneshot";

      script = ''
        set -euo pipefail

        mkdir -p /btrfs_tmp
        mount /dev/disk/by-partlabel/disk-main-root /btrfs_tmp

        cleanup() {
          umount /btrfs_tmp
        }
        trap cleanup EXIT

        delete_subvolume_recursively() {
          local subvolume="$1"

          while IFS= read -r child; do
            delete_subvolume_recursively "/btrfs_tmp/$child"
          done < <(
            btrfs subvolume list -o "$subvolume" |
              cut -f 9- -d ' '
          )

          btrfs subvolume delete "$subvolume"
        }

        if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots

          timestamp="$(
            date \
              --date="@$(stat -c %Y /btrfs_tmp/root)" \
              "+%Y-%m-%d_%H:%M:%S"
          )"

          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        if [[ -d /btrfs_tmp/old_roots ]]; then
          while IFS= read -r old_root; do
            delete_subvolume_recursively "$old_root"
          done < <(
            find /btrfs_tmp/old_roots \
              -mindepth 1 \
              -maxdepth 1 \
              -type d \
              -mtime +30 \
              -print
          )
        fi

        btrfs subvolume create /btrfs_tmp/root
      '';
    };

    # Use /persist as the persistence root, matching Disko's mountpoint
    environment.persistence.${cfg.directory} = {
      enable = cfg.enable;
      hideMounts = true;
      directories = cfg.extraDirectories ++ [
        "/etc/nixos" # System configuration
        "/etc/ssh" # Secret Key
        "/etc/NetworkManager/system-connections" # Network Connections
        "/var/spool"
        "/srv"
        "/root"
      ];
      files = cfg.extraFiles ++ [ "/etc/machine-id" ];
    };
  };
}
