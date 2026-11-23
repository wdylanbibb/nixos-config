{ pkgs, config, var, ... }:
let
  # Copy a single wallpaper into the store so its path only depends on the
  # image itself, not on the whole flake source (which changes every edit).
  wallpaper =
    name:
    "${builtins.path {
      path = "${var.libInputs.self}/wallpapers/${name}";
      inherit name;
    }}";
in
{
  imports = [
    ./disko.nix
    ./data-mount.nix
    ./hardware-configuration.nix
  ];

  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr \
    --output DP-2 --mode 3840x2160 --rate 144 --pos 0x200 --primary \
    --output DP-4 --mode 2560x1440 --rate 144 --pos 3840x0 --rotate left
  '';
  services.xserver.deviceSection = ''
    BusID "PCI:12:0:0"
  '';

  features = {
    users.enable = true;
    virtualisation = {
      docker.enable = true;
      libvirt = {
        enable = true;
        pciIds = [
          "10de:2783"
          "10de:22bc"
        ];
        domains = [
          {
            definition = ./win11.xml;
            active = true;
          }
        ];
      };
    };
    k8s.enable = true;
  };

  modules.system = {
    nvidia = {
      enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    };
    persist = {
      enable = true;
    };
    network.tailscale.enable = true;
    secrets.extraSecrets = {
      cowsay = {
        sopsFile = "${var.secrets}/bot-tokens.yaml";
      };
      weedtime = {
        sopsFile = "${var.secrets}/bot-tokens.yaml";
      };
    };
  };

  modules.desktop.profile = "sway-noctalia-tokyonight";

  modules.apps = {
    obs = {
      enable = true;
      virtualCamera.users = [ "dylan" ];
    };
    qtile.enable = true;
    sway.extraConfig = ''
      output DP-2 {
        mode 3840x2160@144Hz
        position 0 200
      }

      output DP-3 {
        mode 2560x1440@144Hz
        position 3840 0
        transform 270
      }
    '';
    noctalia.settings.wallpaper.monitors = {
      DP-2.path = wallpaper "crosses_4k.png";
      DP-3.path = wallpaper "crosses_vert.png";
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };
}
