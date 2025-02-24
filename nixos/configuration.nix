# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, modulesPath, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./neovim
    ];

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking
  networking = {
    networkmanager.enable = true;
    hostName = "bleistein";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
    };
  };

  # Configure keymap in X11
  services = {
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    users.dylan = {
      isNormalUser = true;
      description = "Dylan Bibb";
      hashedPasswordFile = "/persist/passwords/dylan";
      extraGroups = [ "networkmanager" "wheel" ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment = {
    # List packages installed in system profile. To search, run
    # $ nix search wget
    systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      firefox
      git
      zsh
      wget
      pciutils
      sshfs
      fuse3
      inputs.zellij-nix.packages."${pkgs.system}".zellij
      
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

    # List directories in root to persist between boots
    persistence."/persist" = {
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
  };

  fonts = {
    fontconfig.allowBitmaps = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      fira-code
      cozette
    ]; 
  };

  programs.zsh.enable = true;

  programs.fuse.userAllowOther = true;

  programs.git.config = {
    user = {
      name = "Dylan Bibb";
      email = "wdylanbibb@gmail.com";
    };
  };

  # Fix 4K Monitor HiDpi issues
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

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;

  # sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  sops = {
    # Adds secrets.yml to the nix store
    defaultSopsFile = ../secrets/secrets.yaml;
    age = {
      # Automatically imports SSH keys as age keys
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      # Using an age key that is expected to already be in the filesystem
      keyFile = "/persist/var/lib/sops-nix/key.txt";
      # Generates new key if above does not exist
      generateKey = true;
    };
    # Actual specification of the secrets
    secrets = {
      dylan-passwd = {
        neededForUsers = true;
      };
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

  services.openssh.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
