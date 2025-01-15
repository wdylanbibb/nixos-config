{ config, pkgs, inputs, ... }:
{
  xsession.windowManager.herbstluftwm = {
    keybinds = {
      Mod4-Shift-q = "quit";
      Mod4-Shift-r = "reload";
      Mod4-Shift-c = "close";

      Mod4-h = "focus left";
      Mod4-j = "focus down";
      Mod4-k = "focus up";
      Mod4-l = "focus right";

      Mod4-Return = "spawn \$\{TERMINAL:-xterm\}";
    };
  };
}
