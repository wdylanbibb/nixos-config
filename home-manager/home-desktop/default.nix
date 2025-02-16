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
    Music.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/Music";
    Pictures.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/Pictures";
    School.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/School";
    dev.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/Dev";
  };
}
