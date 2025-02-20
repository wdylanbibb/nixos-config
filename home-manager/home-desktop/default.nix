{ config, lib, pkgs, ... }:
{
  imports = [
    ../home-shared.nix
    ./herbstluftwm.nix
    ./polybar.nix
  ];

  xsession.windowManager.herbstluftwm.enable = true;

  home.packages = with pkgs; [
    pipes-rs
    rofi
    wezterm
    xdotool
    maim
    imagemagick
    polybar-pulseaudio-control
    strawberry
    moonlight-qt
  ];

  programs.git = {
    enable = true;
    extraConfig = {
      safe = {
        directory = [ "/etc/nixos" ];
      };
    };
  };

  programs.zsh = {
    sessionVariables = {
      TERMINAL = "wezterm";
    };
  };

  services.polybar = {
    package = pkgs.polybar.override {
      pulseSupport = true;
    };
    enable = true;
  };
  systemd.user.services.polybar = {
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require("wezterm")
      local act = wezterm.action
      return {
        keys = {},
        use_fancy_tab_bar = false,
        tab_bar_at_bottom = true,
        hide_tab_bar_if_only_one_tab = true,
        font_size = 8,
        font = wezterm.font("Cozette"),
        front_end = "WebGpu",
      }'';
  };

  home.file = {
    Desktop.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Desktop";
    Dev.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Dev";
    Documents.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Documents";
    Downloads.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Downloads";
    Music.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Music";
    Pictures.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Pictures";
    Public.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Public";
    School.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/School";
    Templates.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Templates";
    Videos.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Videos";
  };
}
