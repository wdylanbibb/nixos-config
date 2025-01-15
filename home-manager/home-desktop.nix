{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ./home-shared.nix
    ./herbstluftwm.nix
    ./polybar.nix
  ];

  xsession.windowManager.herbstluftwm.enable = true;

  home.packages = with pkgs; [
    pipes-rs
    rofi
    polybar
    cozette
    wezterm
    xdotool
  ];

  programs.zsh = {
    sessionVariables = {
      TERMINAL = "xterm";
    };
  };

  services.polybar = {
    enable = true;
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require("wezterm")
      local act = wezterm.action
      return {
        keys = {
          { key = [[\]], mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
          {
            key = [[|]],
            mods = "ALT|SHIFT",
            action = act.SplitPane({ top_level = true, direction = "Right", size = { Percent = 50 } }),
          },
          { key = [[-]], mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
          {
            key = [[_]],
            mods = "ALT|SHIFT",
            action = act.SplitPane({ top_level = true, direction = "Down", size = { Percent = 50 } }),
          },
          { key = "n", mods = "ALT", action = act.SpawnTab("CurrentPaneDomain") },
          { key = "Q", mods = "ALT", action = act.CloseCurrentTab({ confirm = false }) },
          { key = "q", mods = "ALT", action = act.CloseCurrentPane({ confirm = false }) },
          { key = "z", mods = "ALT", action = act.TogglePaneZoomState },
          { key = "F11", mods = "ALT", action = act.ToggleFullScreen },
          { key = "h", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 1 }) },
          { key = "j", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 1 }) },
          { key = "k", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 1 }) },
          { key = "l", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 1 }) },

          { key = "h", mods = "ALT", action = act.EmitEvent("ActivatePaneDirection-left") },
          { key = "j", mods = "ALT", action = act.EmitEvent("ActivatePaneDirection-down") },
          { key = "k", mods = "ALT", action = act.EmitEvent("ActivatePaneDirection-up") },
          { key = "l", mods = "ALT", action = act.EmitEvent("ActivatePaneDirection-right") },

          { key = "[", mods = "ALT", action = act.ActivateTabRelative(-1) },
          { key = "]", mods = "ALT", action = act.ActivateTabRelative(1) },
          { key = "{", mods = "SHIFT|ALT", action = act.MoveTabRelative(-1) },
          { key = "}", mods = "SHIFT|ALT", action = act.MoveTabRelative(1) },
          { key = "v", mods = "ALT", action = act.ActivateCopyMode },
          { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
          { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
          { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
          { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
          { key = "1", mods = "ALT", action = act.ActivateTab(0) },
          { key = "2", mods = "ALT", action = act.ActivateTab(1) },
          { key = "3", mods = "ALT", action = act.ActivateTab(2) },
          { key = "4", mods = "ALT", action = act.ActivateTab(3) },
          { key = "5", mods = "ALT", action = act.ActivateTab(4) },
          { key = "6", mods = "ALT", action = act.ActivateTab(5) },
          { key = "7", mods = "ALT", action = act.ActivateTab(6) },
          { key = "8", mods = "ALT", action = act.ActivateTab(7) },
          { key = "9", mods = "ALT", action = act.ActivateTab(8) },
        },
        font_size = 16;
        font = wezterm.font("CozetteHiDpi"),
        front_end = "WebGpu",
      }'';
  };
}
