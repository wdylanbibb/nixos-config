{ ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  features = {
    k8s.enable = true;
    users.enable = true;
  };

  modules.system = {
    persist.enable = true;
    network.tailscale.enable = true;
  };

  modules.apps = {
    gtk.enable = true;
    niri.enable = true;
    lightdm.enable = true;
  };
}
