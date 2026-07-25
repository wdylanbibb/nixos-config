{
  config,
  lib,
  pkgs,
  var,
  ...
}: let
  cfg = config.modules.apps.i3;
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
  desktopPackages = with pkgs; [
    brightnessctl
    dmenu
    dunst
    evince
    feh
    file-roller
    firefox
    libnotify
    loupe
    maim
    nautilus
    networkmanagerapplet
    pamixer
    pavucontrol
    playerctl
    polkit_gnome
    wrappedPkgs.kitty
    xclip
    xdg-utils
    xrandr
    xrdb
    xsetroot
  ];
in {
  options.modules.apps.i3.enable = lib.mkEnableOption "Enable the i3 window manager";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = desktopPackages;

    services.xserver = {
      enable = true;
      dpi = 96;
      displayManager.sessionCommands = ''
        ${pkgs.xrdb}/bin/xrdb -merge /etc/X11/Xresources
        ${pkgs.xsetroot}/bin/xsetroot -cursor_name left_ptr
      '';

      windowManager.i3 = {
        enable = true;
        package = wrappedPkgs.i3;
      };
    };

    environment.variables = {
      GDK_SCALE = "1";
      GDK_DPI_SCALE = "1";
    };

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    fonts.packages = with pkgs; [nerd-fonts.monaspace inter font-awesome];
  };
}
