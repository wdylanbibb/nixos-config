inputs:
{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
let
  yesNo = value: if value then "yes" else "no";

  settingsValueType =
    with lib.types;
    oneOf [
      str
      bool
      int
      float
    ];

  toKittyConfig = lib.generators.toKeyValue {
    mkKeyValue =
      key: value:
      let
        value' = (if lib.isBool value then yesNo else toString) value;
      in
      "${key} ${value'}";
  };

  toKittyKeybindings = lib.generators.toKeyValue {
    mkKeyValue = key: command: "map ${key} ${command}";
  };
in
{
  imports = [ wlib.modules.default ];

  options = with lib; {
    settings = mkOption {
      type = types.attrsOf settingsValueType;
      default = { };
      description = "Set of config settings.";
    };

    keybindings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Mapping of keybindings to actions.";
    };

    themeFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Apply a Kitty color theme. This option takes the file name of a theme
        in `kitty-themes`, without the `.conf` suffix. See
        <https://github.com/kovidgoyal/kitty-themes/tree/master/themes> for a
        list of themes.
      '';
    };

    kittens = mkOption {
      type = types.lazyAttrsOf (types.either types.path types.lines);
      default = { };
      description = "Custom python scripts to include in the config path.";
    };
  };

  config = {
    settings = {
      font_family = "family='MonaspiceAr Nerd Font' features='+calt +liga +ss10 +ss09 +ss08 +ss07'";
      bold_font = "family='MonaspiceKr Nerd Font' style='Bold' features='+calt +liga +ss10 +ss09 +ss08 +ss07'";
      italic_font = "family='MonaspiceRn Nerd Font' style='Regular' features='+calt +liga +ss10 +ss09 +ss08 +ss07'";
      bold_italic_font = "family='MonaspiceRn Nerd Font' style='Bold Italic' features='+calt +liga +ss10 +ss09 +ss08 +ss07'";

      font_size = 11.0;

      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";

      clear_all_shortcuts = true;
      kitty_mod = "ctrl+shift";

      detect_urls = true;
      url_style = "curly";

      notify_on_cmd_finish = "invisible 10.0 notify";

      allow_remote_control = true;
      listen_on = "unix:@mykitty";

      enabled_layouts = "tall,stack";
    };

    keybindings = {
      "kitty_mod+enter" = "launch --cwd=current --type os-window";
      "ctrl+t" = "launch --cwd=current --type window";
      "ctrl+alt+t" = "goto_layout tall";
      "ctrl+alt+f" = "goto_layout stack";
      "kitty_mod+e" = "kitten hints --type url --hints-text-color red";
      "kitty_mod+p" = "kitten hints --type path --hints-text-color red";
      "kitty_mod+o" = "kitten hints --type hyperlink";
      "ctrl+[" = "layout_action decrease_num_full_size_windows";
      "ctrl+]" = "layout_action increase_num_full_size_windows";
      "ctrl+shift+t" = "launch --type=tab --cwd=current";
      "kitty_mod+right" = "next_tab";
      "kitty_mod+left" = "previous_tab";
      "ctrl+shift+q" = "close_tab";
      "ctrl+tab" = "select_tab";

      "kitty_mod+r" = "start_resizing_window";
      "ctrl+left" = "resize_window narrower";
      "ctrl+right" = "resize_window wider";
      "ctrl+up" = "resize_window taller";
      "ctrl+down" = "resize_window shorter 3";
      "ctrl+home" = "resize_window reset";

      "kitty_mod+c" = "copy_to_clipboard";
      "kitty_mod+v" = "paste_from_clipboard";
      "kitty_mod+s" = "paste_from_selection";

      "ctrl+h" = "kitten pass_keys.py neighboring_window left ctrl+h";
      "ctrl+j" = "kitten pass_keys.py neighboring_window bottom ctrl+j";
      "ctrl+k" = "kitten pass_keys.py neighboring_window top ctrl+k";
      "ctrl+l" = "kitten pass_keys.py neighboring_window right ctrl+l";
      "kitty_mod+]" = "next_window";
      "kitty_mod+[" = "previous_window";
      "kitty_mod+w" = "close_window";

      "alt+s" = "show_scrollback";

      "page_up" = "scroll_page_up";
      "page_down" = "scroll_page_down";
      "kitty_mod+home" = "scroll_home";
      "kitty_mod+end" = "scroll_end";

      "alt+shift+1" = "goto_tab 1";
      "alt+shift+2" = "goto_tab 2";
      "alt+shift+3" = "goto_tab 3";
      "alt+shift+4" = "goto_tab 4";
      "alt+shift+5" = "goto_tab 5";
      "alt+shift+6" = "goto_tab 6";
      "alt+shift+7" = "goto_tab 7";
      "alt+shift+8" = "goto_tab 8";
      "alt+shift+9" = "goto_tab 9";
      "alt+shift+0" = "goto_tab 10";

      "ctrl+shift+g" = "show_last_command_output";
      "ctrl+shift+z" = "scroll_to_prompt -1";
      "ctrl+shift+x" = "scroll_to_prompt 1";
    };

    themeFile = "tokyo_night_night";

    kittens = {
      "navigate_kitty.py" = ''
        from kittens.tui.handler import result_handler
        from typing import List
        from kitty.boss import Boss

        def main():
          pass

        directions = [ "right", "left", "top", "bottom" ]

        @result_handler(no_ui=True)
        def handle_result(args: List[str], result: str, target_window_id: int, boss: Boss):
          if len(args) == 2 and args[1] in directions:
            boss.active_tab.neighboring_window(args[1])
      '';
      "pass_keys.py" = ''
        import re
        from kittens.tui.handler import result_handler
        from kitty.key_encoding import KeyEvent, parse_shortcut

        VIM_ID = "n?vim"

        def is_window_vim(window):
            fp = window.child.foreground_processes
            return any(
                re.search(VIM_ID, p["cmdline"][0] if len(p["cmdline"]) else "", re.I)
                for p in fp
            )

        def encode_key_mapping(window, key_mapping):
            mods, key = parse_shortcut(key_mapping)
            event = KeyEvent(
                mods=mods,
                key=key,
                shift=bool(mods & 1),
                alt=bool(mods & 2),
                ctrl=bool(mods & 4),
                super=bool(mods & 8),
                hyper=bool(mods & 16),
                meta=bool(mods & 32),
            ).as_window_system_event()

            return window.encoded_key(event)

        def main():
            pass

        @result_handler(no_ui=True)
        def handle_result(args, result, target_window_id, boss):
            window = boss.window_id_map.get(target_window_id)
            direction = args[2]
            key_mapping = args[3]

            if window is None:
                return
            if is_window_vim(window):
                for keymap in key_mapping.split(">"):
                    encoded = encode_key_mapping(window, keymap)
                    window.write_to_child(encoded)
            else:
                boss.active_tab.neighboring_window(direction)
      '';
    };

    env = {
      KITTY_CONFIG_DIRECTORY = toString (
        pkgs.linkFarm "kitty-merged-config" (
          let
            entry = name: path: { inherit name path; };

            configEntry = entry "kitty.conf" (
              pkgs.writeText "kitty.conf" ''
                include ${pkgs.kitty-themes}/share/kitty-themes/themes/${config.themeFile}.conf
                ${toKittyConfig config.settings}
                ${toKittyKeybindings config.keybindings}
              ''
            );

            kittenEntries = lib.mapAttrsToList (
              name: content: entry "${name}" (pkgs.writeText name content)
            ) config.kittens;
          in
          [ configEntry ] ++ kittenEntries
        )
      );
    };

    package = lib.mkDefault pkgs.kitty;
    extraPackages = with pkgs; [ kitty-themes ];
  };
}
