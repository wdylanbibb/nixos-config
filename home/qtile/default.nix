{ ... }:
{
  home.pointerCursor.x11.enable = true;
  xdg.configFile."qtile/config.py" = {
    enable = true;
    source = ./qtile.py;
  };
}
