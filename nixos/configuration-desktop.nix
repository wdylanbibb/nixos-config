# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, modulesPath, ... }:
{
  imports =
    [
      ./hardware-configuration-desktop.nix
      ./configuration-shared.nix
    ];

  networking.hostName = "bleistein"; # Define your hostname.

  boot.kernelPackages = pkgs.linuxPackages_latest;

  users.mutableUsers = false;
  users.users.dylan.hashedPasswordFile = "/persist/passwords/dylan";

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/libvirt/images"
      "/var/lib/sops-nix"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

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
    age
  ];

  sops = {
    # Adds secrets.yml to the nix store
    defaultSopsFile = ../secrets/example.yaml;
    age = {
      # Automatically imports SSH keys as age keys
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      # Using an age key that is expected to already be in the filesystem
      keyFile = "/var/lib/sops-nix/key.txt";
      # Generates new key if above does not exist
      generateKey = true;
    };
    # Actual specification of the secrets
    secrets = {
      example-key = {};
      "myservice/my_subdir/my_secret" = {};
      dylan-password = {};
    };
  };

  programs.git.config = {
    user = {
      name = "Dylan Bibb";
      email = "wdylanbibb@gmail.com";
    };
  };

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
