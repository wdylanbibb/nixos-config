{ config, pkgs, ... }:
{
  xsession.windowManager.herbstluftwm = {
    keybinds = {
      Mod4-Return = "spawn \${TERMINAL:-xterm}";
      # Mod4-Return = "spawn wezterm start zellij";
      Mod4-d = "spawn rofi -show drun";

      Print = "spawn bash -c 'maim -s | xclip -selection clipboard -t image/png'";
      Control-Print = "spawn bash -c 'maim -st 99999999 | magick - \\( +clone -background black -shadow 80x3+10+10 \\) +swap -background none -layers merge +repage - | xclip -selection clipboard -t image/png'";

      Mod4-Shift-q = "quit";
      Mod4-Shift-r = "reload";
      Mod4-Shift-c = "close";

      Mod4-h = "focus left";
      Mod4-j = "focus down";
      Mod4-k = "focus up";
      Mod4-l = "focus right";

      Mod4-Shift-h = "shift left";
      Mod4-Shift-j = "shift down";
      Mod4-Shift-k = "shift up";
      Mod4-Shift-l = "shift right";

      # splitting frames
      # create an empty frame at the specified direction
      Mod4-u = "split bottom 0.5";
      Mod4-o = "split right 0.5";
      # let the current frame explode into subframes
      Mod4-Control-space = "split explode";

      # resizing frames and floating clients
      Mod4-Control-h = "resize left +0.02";
      Mod4-Control-j = "resize down +0.02";
      Mod4-Control-k = "resize up +0.02";
      Mod4-Control-l = "resize right +0.02";
      Mod4-Control-Left = "resize left +0.02";
      Mod4-Control-Down = "resize down +0.02";
      Mod4-Control-Up = "resize up +0.02";
      Mod4-Control-Right = "resize right +0.02";

      # layouting
      Mod4-r = "remove";
      Mod4-s = "floating toggle";
      Mod4-f = "fullscreen toggle";
      Mod4-Shift-f = "set_attr clients.focus.floating toggle";
      Mod4-Shift-d = "set_attr clients.focus.decorated toggle";
      Mod4-Shift-m = "set_attr clients.focus.minimized true";
      Mod4-Control-m = "jumpto last-minimized";
      Mod4-p = "pseudotile toggle";

      # cycle through layouts
      # Mod4-space = "or , and . compare tags.focus.curframe_wcount = 2 . cycle_layout 1 verticle horizontal max vertical grid , cycle_layout 1";
      Mod4-space = "cycle_layout 1 horizontal max vertical grid";

      # focus
      Mod4-BackSpace = "cycle_monitor";
      Mod4-Tab = "cycle_all 1";
      Mod4-Shift-Tab = "cycle_all -1";
      Mod4-c = "cycle";
      Mod4-i = "jumpto urgent";

      # Tag switching for monitor 1
      Mod4-1 = "or CASE and . compare monitors.focus.index = 0 . use 1";
      Mod4-2 = "or CASE and . compare monitors.focus.index = 0 . use 2";
      Mod4-3 = "or CASE and . compare monitors.focus.index = 0 . use 3";
      Mod4-4 = "or CASE and . compare monitors.focus.index = 0 . use 4";
      Mod4-5 = "or CASE and . compare monitors.focus.index = 0 . use 5";
      Mod4-Shift-1 = "move 1";
      Mod4-Shift-2 = "move 2";
      Mod4-Shift-3 = "move 3";
      Mod4-Shift-4 = "move 4";
      Mod4-Shift-5 = "move 5";

      # Swap monitor positions of VM and monitor 0 (main display)
      # Need to spawn bash process because otherwise awk commands get cached
      Mod4-v = ''spawn bash -c "herbstclient chain , move_monitor 0 \$(herbstclient monitor_rect VM | awk '{print \$3 \"x\" \$4 \"+\" \$1 \"+\" \$2}') , \
        move_monitor VM \$(herbstclient monitor_rect 0 | awk '{print \$3 \"x\" \$4 \"+\" \$1 \"+\" \$2}') , \
        focus_monitor \$(if [[ \"\$(herbstclient monitor_rect VM | awk '{print \$1}')\" == \"3840\" ]]; then echo VM; else echo 0; fi)"'';
      Mod4-Shift-v = "shift_to_monitor VM";
    };
    mousebinds = {
      Mod4-B1 = "move";
      Mod4-B2 = "zoom";
      Mod4-B3 = "resize";
    };
    settings = {
      swap_monitors_to_get_tag = "0";
      focus_stealing_prevention = "off";

      frame_border_active_color = "#000000";
      frame_border_normal_color = "#333333";
      frame_bg_normal_color = "#FFFF00";
      frame_bg_active_color = "#333333";
      frame_border_width = "1";
      show_frame_decorations = "focused_if_multiple";
      frame_bg_transparent = "on";
      # frame_transparent_width = "5";
      frame_gap = "0";

      window_gap = "0";
      frame_padding = "0";
      smart_window_surroundings = "off";
      smart_frame_surroundings = "on";
      mouse_recenter_gap = "0";

      tree_stype = "╾│ ├└╼─┐";
    };
    rules = [
      "focus=on" # normally focus new clients
      "floatplacement=smart"
      # "focus=off" # normally do not focus new clients
      # give focus to most common terminals
      # "class~'(.*[Rr]xvt.*|.*[Tt]erm|Konsole)' focus=on"
      "windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' floating=on"
      "windowtype='_NET_WM_WINDOW_TYPE_DIALOG' focus=on"
      "windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)' manage=off"
      "fixedsize floating=on"
      "class=\"__AUTOSTART_BTOP\" manage=off hook=btopdesktop"
      "class=\"__AUTOSTART_PIPES\" manage=off hook=pipesdesktop"
      "class='com.moonlight_stream.Moonlight' tag=VM monitor=VM fullscreen=on"
      "class='vesktop' tag=T fullscreen=on"
    ];
    tags = [ "1" "L" "T" "R" "VM" "2" "3" "4" "5" ];
    extraConfig = 
      # ''
      # pkill -x btop
      # pkill -x pipes-rs
      # herbstclient emit_hook reload
      ''
      xsetroot -solid '#000000'
      herbstclient attr theme.tiling.reset 1
      herbstclient attr theme.floating.reset 1
      herbstclient attr theme.fullscreen.reset 1
      herbstclient set frame_border_active_color '#000000'
      herbstclient set frame_border_normal_color '#333333'
      herbstclient set frame_bg_normal_color '#FFFF00'
      herbstclient set frame_bg_active_color '#333333'
      herbstclient set frame_border_width 1
      herbstclient set show_frame_decorations 'focused_if_multiple'
      herbstclient set frame_bg_transparent on
      # herbstclient set frame_transparent_width 5
      herbstclient set frame_gap 0

      herbstclient attr theme.title_height 10
      herbstclient attr theme.title_when always
      herbstclient attr theme.title_font 'Cozette' # example using Xft
      # herbstclient attr theme.title_font '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*'
      herbstclient attr theme.title_depth 3 # space below the title's baseline
      herbstclient attr theme.active.color '#000000'
      herbstclient attr theme.title_color '#cccccc'
      herbstclient attr theme.normal.color '#333333'
      herbstclient attr theme.urgent.color '#00FFFF'
      herbstclient attr theme.tab_color '#333333'
      herbstclient attr theme.active.tab_color '#333333'
      herbstclient attr theme.active.tab_outer_color '#333333'
      herbstclient attr theme.active.tab_title_color '#cccccc'
      herbstclient attr theme.normal.title_color '#cccccc'
      # herbstclient attr theme.inner_width 1
      herbstclient attr theme.inner_color black
      herbstclient attr theme.border_width 1
      # herbstclient attr theme.floating.border_width 4
      # herbstclient attr theme.floating.outer_width 1
      herbstclient attr theme.floating.outer_color black
      herbstclient attr theme.active.inner_color '#000000'
      herbstclient attr theme.urgent.inner_color '#00FF00'
      herbstclient attr theme.normal.inner_color '#333333'

      # herbstclient attr theme.fullscreen.title_height 15
      # herbstclient attr theme.fullscreen.title_when multiple_tabs
      # herbstclient attr theme.fullscreen.title_font 'Iosevka Nerd Font Mono:pixelsize=14' # example using Xft
      # # herbstclient attr theme.title_font '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*'
      # herbstclient attr theme.fullscreen.title_depth 3 # space below the title's baseline
      # herbstclient attr theme.fullscreen.title_color '#ffffff'
      # herbstclient attr theme.fullscreen.normal.title_color '#898989'
      # copy inner color to outer_color
      for state in active urgent normal; do
        herbstclient substitute C theme.''${state}.inner_color \
          attr theme.''${state}.outer_color C
      done
      herbstclient attr theme.tiling.outer_width 1
      herbstclient attr theme.background_color '#141414'

      herbstclient set window_gap 0
      herbstclient set frame_padding 0
      herbstclient set smart_window_surroundings off
      herbstclient set smart_frame_surroundings on
      herbstclient set mouse_recenter_gap 0

      herbstclient set_monitors 2560x1440+640+720 640x2118+0+42 2560x678+640+42 640x2118+3200+42 2560x1440+3840+0
      herbstclient rename_monitor 4 "VM"

      ${pkgs.bash}/bin/bash ${config.xdg.configHome}/herbstluftwm/bg_programs &
      '';
  };
  xdg.configFile."herbstluftwm/bg_programs" = {
    enable = true;
    text = ''
      ${pkgs.procps}/bin/pkill -x pipes-rs
      ${pkgs.procps}/bin/pkill -x btop

      fix_btop_window() {
        ${pkgs.herbstluftwm}/bin/herbstclient lower $1
        ${pkgs.xdotool}/bin/xdotool windowmove $1 3200 42
        ${pkgs.xdotool}/bin/xdotool windowsize $1 640 2118
      }

      fix_pipes_window() {
        ${pkgs.herbstluftwm}/bin/herbstclient lower $1
        ${pkgs.xdotool}/bin/xdotool windowmove $1 0 42
        ${pkgs.xdotool}/bin/xdotool windowsize $1 3200 2118
      }

      fix_btop_window $(${pkgs.herbstluftwm}/bin/herbstclient --last-arg --wait rule btopdesktop) &
      fix_pipes_window $(${pkgs.herbstluftwm}/bin/herbstclient --last-arg --wait rule pipesdesktop) &

      ${pkgs.wezterm}/bin/wezterm --config window_padding=\{left=0,right=0,top=0,bottom=0\} --config enable_tab_bar=false --config font_size=10 start --class "__AUTOSTART_BTOP" ${pkgs.btop}/bin/btop &
      PID1=$!
      ${pkgs.wezterm}/bin/wezterm --config window_padding=\{left=0,right=0,top=0,bottom=0\} --config enable_tab_bar=false --config font_size=10 start --class "__AUTOSTART_PIPES" ${pkgs.pipes-rs}/bin/pipes-rs -k=curved -p=10
    '';
  };
}
