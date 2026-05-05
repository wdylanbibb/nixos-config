{
  config,
  lib,
  var,
  pkgs,
  ...
}:
let
  cfg = config.features.virtualisation;

  addUsersToGroups =
    groups:
    var.users
    |> builtins.readDir
    |> builtins.attrNames
    |> map (user: {
      name =
        user |> builtins.baseNameOf |> builtins.unsafeDiscardStringContext |> lib.removeSuffix ".nix";
      value.extraGroups = groups;
    })
    |> lib.listToAttrs;

in
{
  options.features.virtualisation = with lib; {
    docker = {
      enable = mkEnableOption "Enable docker";
    };

    libvirt = {
      enable = mkEnableOption "Enable the virtualisation feature.";

      pciIds = mkOption {
        type = with types; listOf str;
        description = "The PCI ids that are going to use the vfio driver.";
      };

      defaultPoolPath = mkOption {
        type = with types; str;
        default = "/var/lib/libvirt/images";
        description = "Location of the libvirt pool that contains VM images.";
      };

      domains = lib.mkOption {
        type =
          with lib.types;
          nullOr (
            listOf (submodule {
              options = {
                definition = lib.mkOption {
                  type = path;
                  description = "path to domain definition XML";
                };
                active = lib.mkOption {
                  type = nullOr bool;
                  default = null;
                  description = "state to put the domain in (or null for ignore)";
                };
                restart = lib.mkOption {
                  type = nullOr bool;
                  default = null;
                  description = "whether to restart on activation (or null to only restart when changed)";
                };
              };
            })
          );
        default = null;
        description = "List of VM domains.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.docker.enable {
      virtualisation.docker.enable = true;

      users.users = addUsersToGroups [ "docker" ];
    })
    (lib.mkIf cfg.libvirt.enable {
      environment.systemPackages = with pkgs; [
        looking-glass-client
        virt-manager
      ];

      users.users = addUsersToGroups [
        "kvm"
        "libvirtd"
        "qemu-libvirtd"
      ];

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
          "kvmfr.static_size_mb=128"
          "vfio-pci.ids=${lib.concatStringsSep "," cfg.libvirt.pciIds}"
        ];
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
            network = var.libInputs.nix-virt.lib.network;
            pool = var.libInputs.nix-virt.lib.pool;
          in
          {
            enable = true;
            swtpm.enable = true;
            connections."qemu:///system" = {
              domains = cfg.libvirt.domains;
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
    })
  ];
}
