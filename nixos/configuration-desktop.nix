# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration-desktop.nix
      ./configuration-shared.nix
    ];

  networking.hostName = "bleistein"; # Define your hostname.

  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelParams = [ "CONFIG_MEDIA_USB_SUPPORT=y" "CONFIG_USB_VIDEO_CLASS=y" ];

  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-uuid/423E36095F33BFBE";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ly
    herbstluftwm
    libnotify
    dunst
    pulseaudio
    virt-manager
    virt-top
    ntfs3g
    rxvt-unicode

    cheese
    v4l-utils

    kitty
    tdf

    inputs.helix.packages."${pkgs.system}".helix
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    fira-code
    cozette
  ];

  services.xserver.dpi = 96;
  environment.variables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
  };

  programs.dconf.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  # sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # hardware.pulseaudio = {
  #   enable = true;
  # };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead of just the bare essentials
    # powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    # powerManagement.finegrained = false;

    # Use the Nvidia open-source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing or later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`
    nvidiaSettings = true;

    # Optionally, you may need to select the appropiate driver version for your specific GPU.
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
       version = "570.86.16"; # use new 570 drivers
       sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
       openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
       settingsSha256 = "sha256-9rtqh64TyhDF5fFAYiWl3oDHzKJqyOW3abpcf2iNRT8=";
       usePersistenced = false;
    };
  };

  # List services that you want to enable:

  # Enable the ly display manager.
  services.displayManager.ly.enable = true;

  # Enable the herbstluftwm window manager.
  services.xserver = {
    enable = true;
    autorun = false;
    windowManager.herbstluftwm = {
      enable = true;
    #   configFile = ./herbstluftwm;
    };
  };
  
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

  users.groups.libvirtd.members = [ "dylan" ];
  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirt = {
      enable = true;
      connections."qemu:///system" = {
         domains = [
          {
            definition = ./libvirt/win10.xml;
            active = true;
          }
        ]; 
        networks = [
          {
            definition = ./libvirt/net-default.xml;
            active = true;
          }
        ];
        pools = [
          {
            definition = ./libvirt/pool-default.xml;
            active = true;
            # volumes = [{
            #   present = true;
            #
            # }];
          }
        ];
      };
    };
    libvirtd = {
      onBoot = "start";
      qemu.ovmf.enable = true;
    };
  };
}
