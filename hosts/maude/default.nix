{ ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  features.users.enable = true;

  modules.system = {
    persist.enable = true;
    network.tailscale.enable = true;
  };

  modules.apps = {
    niri.enable = true;
    lightdm.enable = true;
  };
}
