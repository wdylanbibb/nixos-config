{ config, lib, pkgs, ... }:
{
  options.f-sy-h = with lib; {
    enable = mkEnableOption "fast zsh syntax highlighting.";

    package = mkPackageOption pkgs "zsh-f-sy-h" { };
  };

  config = lib.mkIf config.f-sy-h.enable {
    plugins = [
      {
        name = "zsh-f-sy-h";
        src = config.f-sy-h.package;
        file = "share/zsh/site-functions/F-Sy-H.plugin.zsh";
      }
    ];
  };
}
