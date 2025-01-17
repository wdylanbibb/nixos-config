{ pkgs, lib, config, ... }: {
    boot = {
      initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"

        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];

      kernelParams = [
        # enable IOMMU
        "amd_iommu=on"
        "vfio-pci.ids=10de:2504,10de:228e"
      ];
    };

    virtualisation.spiceUSBRedirection.enable = true;
  }
