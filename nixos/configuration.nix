# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./impermanence.nix
    ./data-mount.nix
    ./disko-config.nix
    ./nvidia.nix
    ./tailscale.nix
    ./virtualisation
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "bleistein"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    displayManager.setupCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr \
      --output DP-2 --mode 3840x2160 --rate 144 --pos 0x200 --primary \
      --output DP-4 --mode 2560x1440 --rate 144 --pos 3840x0 --rotate left
    '';
    deviceSection = ''
      BusID "PCI:12:0:0"
    '';

    windowManager.qtile = {
      enable = true;
      extraPackages =
        python313Packages: with pkgs.python313Packages; [
          qtile-extras
          dbus-fast
        ];
    };
  };

  services.xserver.dpi = 96;
  environment.variables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    # variant = "colemak";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    users = {
      root.hashedPasswordFile = config.sops.secrets.passwd.path;
      dylan = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.passwd.path;
        home = "/home/dylan";
        extraGroups = [
          "wheel"
        ];
        packages = with pkgs; [ ];
      };
    };
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
    interactiveShellInit = ''
      if [[ -z "$ZELLIJ" && -z "$SSH_CLIENT" ]]; then
        if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
          zellij attach -c
        else
          zellij
        fi

        if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
          exit
        fi
      fi
      [[ $- = *i* ]] && source ${pkgs.liquidprompt}/bin/liquidprompt
    '';
    shellAliases = {
      md = "(){ mkdir -p $1 && cd $1 }";
    };
    ohMyZsh = {
      enable = true;
      plugins = [
        "aliases"
        "catimg"
        "colored-man-pages"
        "dircycle"
        "fancy-ctrl-z"
        "gitfast"
        "sudo"
        "zoxide"
        "ssh-agent"
        "tailscale"
      ];
    };
  };

  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
    clean = {
      enable = true;
      extraArgs = "--keep 5 --keep-since 30d";
    };
  };

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      url."https://github.com/".insteadOf = [
        "gh:"
        "github:"
      ];
      safe.directory = [ "/etc/nixos" ];
    };
  };

  programs.yazi.enable = true;

  programs.dconf.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    wget
    pciutils
    zip
    xz
    unzip
    p7zip
    gcc
    ripgrep
    jq
    eza
    fzf
    bat
    lazygit
    zoxide
    which
    tree
    btop
    usbutils
    python315
    inputs.nix-cats.packages.${pkgs.stdenv.hostPlatform.system}.nixCats

    zellij
    zsh-forgit
    zsh-command-time
    liquidprompt

    virt-manager
  ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age = {
      sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_sops" ];
      # keyFile = "/var/lib/sops-nix/key.txt";
      # generateKey = true;
    };
    secrets = {
      passwd = {
        neededForUsers = true;
      };
      ts-authkey = {
        restartUnits = [ "tailscaled.service" ];
      };
      data = {
        sopsFile = ../secrets/data.key;
        format = "binary";
      };
    };
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.monaspace
      inter
      font-awesome
    ];
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
