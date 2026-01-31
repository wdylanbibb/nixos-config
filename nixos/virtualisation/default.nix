{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
      "kvmfr"
    ];

    kernelParams = [
      "amd_iommu=on"
      "vfio-pci.ids=10de:2504,10de:228e"
      "kvmfr.static_size_mb=128"
    ];

    # extraModprobeConfig = ''
    #   options vfio-pci id=10de:2504,10de:228e
    #   softdep nvidia pre: vfio-pci
    #   softdep nouveau pre: vfio-pci
    # '';
  };

  services.udev.packages = lib.singleton (
    pkgs.writeTextFile {
      name = "kvmfr";
      text = ''
        SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-kvmfr.rules";
    }
  );

  users.users.dylan.extraGroups = [
    "kvm"
    "libvirtd"
    "qemu-libvirtd"
  ];

  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      onBoot = "start";
      qemu = {
        swtpm.enable = true;
        verbatimConfig = ''
          namespaces = []
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
            "/dev/rtc", "/dev/hpet", "/dev/vfio/vfio",
            "/dev/kvmfr0"
          ]
        '';
      };
    };
    libvirt =
      let
        network = inputs.nix-virt.lib.network;
        pool = inputs.nix-virt.lib.pool;
      in
      {
        enable = true;
        swtpm.enable = true;
        connections."qemu:///system" = {
          domains = [
            {
              definition = ./win11.xml;
              active = true;
            }
          ];
          networks = [
            {
              definition = network.writeXML (
                network.templates.bridge {
                  uuid = "328a77bc-5fa0-4083-b5e7-e0e4d1f232d8";
                  subnet_byte = 122;
                }
              );
              active = true;
            }
          ];
          pools = [
            {
              definition = pool.writeXML {
                name = "default";
                uuid = "23d340b0-93e5-499c-9e4f-9f32df6bf2aa";
                type = "dir";
                target.path = "/var/lib/libvirt/images";
              };
              active = true;
            }
          ];
        };
      };
  };

  environment.systemPackages = with pkgs; [
    looking-glass-client
  ];
}
