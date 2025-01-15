# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration-desktop.nix
      ./configuration-shared.nix
    ];

  networking.hostName = "bleistein"; # Define your hostname.

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ly
    herbstluftwm
  ];

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
}
