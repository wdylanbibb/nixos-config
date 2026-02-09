{ config, var, ... }:
{
  modules.system.secrets.extraSecrets.data = {
    sopsFile = "${var.secrets}/data.key";
    format = "binary";
  };

  environment.etc.crypttab = {
    mode = "0600";
    text = ''
      # <volume-name> <encrypted-device> [key-file] [options]
      data1 UUID=441fc6cc-a1b3-4c83-9d2b-11289357e158 ${config.sops.secrets.data.path} luks
    '';
  };

  fileSystems."/home" = {
    device = "/dev/mapper/data1";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/var/lib/libvirt/images" = {
    device = "/dev/mapper/data1";
    fsType = "btrfs";
    options = [
      "subvol=images"
      "compress=zstd"
      "noatime"
    ];
  };
}
