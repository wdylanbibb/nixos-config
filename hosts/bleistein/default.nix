{ pkgs, config, var, ... }:
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
          "10de:2504"
          "10de:228e"
        ];
        domains = [
          {
            definition = ./win11.xml;
            active = true;
          }
        ];
      };
    };
  };

  modules.system = {
    nvidia.enable = true;
    persist = {
      enable = true;
    };
    network.tailscale.enable = false;
    secrets.extraSecrets = {
      cowsay = {
        sopsFile = "${var.secrets}/bot-tokens.yaml";
      };
      weedtime = {
        sopsFile = "${var.secrets}/bot-tokens.yaml";
      };
    };
  };

  modules.apps = {
    gtk.enable = true;
    obs = {
      enable = true;
      virtualCamera.users = [ "dylan" ];
    };
    qtile.enable = true;
    lightdm.enable = true;
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
