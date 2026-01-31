{ ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      local wezterm = require("wezterm")
      local act = wezterm.action
      return {
        color_scheme = "tokyonight_night",
        disable_default_key_bindings = true,
        keys = {
          {
            key = "c",
            mods = "CTRL|SHIFT",
            action = act.CopyTo "Clipboard"
          },
          {
            key = "v",
            mods = "CTRL|SHIFT",
            action = act.PasteFrom "Clipboard"
          },
        },
        window_padding = {
          left = 0,
          right = 0,
          top = 1,
          bottom = 0,
        },
        tab_bar_at_bottom = true,
        hide_tab_bar_if_only_one_tab = true,
        font_size = 10,
        font = wezterm.font({
          family = "MonaspiceAr NF",
          weight = "Regular",
          harfbuzz_features = { "calt", "liga", "dlig", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08" }
        }),
        font_rules = {
          {
            intensity = "Normal",
            italic = true,
            font = wezterm.font({
              family = "MonaspiceRn NF",
              weight = "ExtraLight",
              stretch = "Normal",
              style = "Normal",
              harfbuzz_features = { "calt", "liga", "dlig", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08" }
            }),
          },
          {
            intensity = "Bold",
            italic = false,
            font = wezterm.font({
              family = "MonaspiceKr NF",
              weight = "Light",
              stretch = "Normal",
              style = "Normal",
              harfbuzz_features = { "calt", "liga", "dlig", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08" }
            }),
          },
        },
        underline_position = -1,
        front_end = "WebGpu",
      }
    '';
  };
}
