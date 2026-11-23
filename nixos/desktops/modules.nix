{
  lib,
  pkgs,
  ...
}: let
  tomlFormat = pkgs.formats.toml {};
in {
  options.modules = {
    desktop.profile = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [
        "cosmic-niri-tokyonight"
        "niri-noctalia-tokyonight"
        "sway-noctalia-tokyonight"
        "xfce-i3-tokyonight"
      ]);
      default = null;
      description = "Preconfigured graphical desktop profile.";
    };

    apps.noctalia.settings = lib.mkOption {
      type = tomlFormat.type;
      default = {};
      description = ''
        Machine-specific Noctalia settings merged recursively over the
        selected desktop profile's defaults.
      '';
    };
  };
}
