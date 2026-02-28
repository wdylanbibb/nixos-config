{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.zsh-abbr = with lib; {
    enable = mkEnableOption "zsh-abbr - zsh manager for auto expanding abbreviations.";

    package = mkPackageOption pkgs "zsh-abbr" { };

    abbreviations = mkOption {
      type = with types; attrsOf str;

      default = { };
    };
  };

  config = lib.mkIf config.zsh-abbr.enable {
    plugins = [
      {
        name = "zsh-abbr";
        src = config.zsh-abbr.package;
        file = "share/zsh/zsh-abbr/zsh-abbr.plugin.zsh";
      }
    ];

    environment.ABBR_USER_ABBREVIATIONS_FILE = toString (
      pkgs.writeText "user-abbreviations" (
        builtins.concatStringsSep "\n" (
          lib.mapAttrsToList (
            k: v: ''abbr ${lib.escapeShellArg k}=${lib.escapeShellArg v}''
          ) config.zsh-abbr.abbreviations
        )
      )
    );
  };
}
