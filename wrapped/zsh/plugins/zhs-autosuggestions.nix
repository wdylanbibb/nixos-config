{ config, lib, pkgs, ... }:
{
  options.autosuggestions = with lib; {
    enable = mkEnableOption "fish-like inline autosuggestions for zsh.";

    package = mkPackageOption pkgs "zsh-autosuggestions" { };
  };

  config = lib.mkIf config.autosuggestions.enable {
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = config.autosuggestions.package;
        file = "share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
    ];
  };
}
