{ lib, ... }:
{
  options.modules.desktop.profile = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [ "niri-tokyonight" "xfce-i3-tokyonight" ] );
    default = null;
    description = "Preconfigured graphical desktop profile.";
  };
}
