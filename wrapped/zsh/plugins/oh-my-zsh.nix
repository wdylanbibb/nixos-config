{ config, lib, pkgs, ... }:
{
  options =
    with lib;
    let
      ohMyZshModule = types.submodule {
        options = {
          enable = mkEnableOption "oh-my-zsh";

          package = mkPackageOption pkgs "oh-my-zsh" { };

          plugins = mkOption {
            type = with types; listOf str;
            default = [ ];
          };

          theme = mkOption {
            type = with types; str;
            default = "";
          };
        };
      };
    in
    {
      oh-my-zsh = mkOption {
        type = ohMyZshModule;

        default = { };
      };
    };

  config = lib.mkIf config.oh-my-zsh.enable {
    extraPackages = [ config.oh-my-zsh.package ];

    extraContent = lib.mkOrder 800 ''
      ${lib.optionalString (config.oh-my-zsh.plugins != [ ]) "plugins=(${lib.concatStringsSep " " config.oh-my-zsh.plugins})"}
      ${lib.optionalString (config.oh-my-zsh.theme != "") ''ZSH_THEME="${config.oh-my-zsh.theme}"''}
      source ${config.oh-my-zsh.package}/share/oh-my-zsh/oh-my-zsh.sh
      '';
  };
}
