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
    boot.initrd.postResumeCommands = lib.mkAfter ''
      mkdir /btrfs_tmp
      mount /dev/disk/by-partlabel/disk-main-root /btrfs_tmp
      if [[ -e /btrfs_tmp ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      unmount /btrfs_tmp
    '';

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
