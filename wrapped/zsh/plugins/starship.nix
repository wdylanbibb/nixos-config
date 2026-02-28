{
  config,
  lib,
  pkgs,
  ...
}:
let
  tomlFmt = pkgs.formats.toml { };

  starshipConfigFromPreset =
    pkgs.runCommand "starship-${config.starship.preset}.toml"
      {
        buildInputs = [ config.starship.package ];
      }
      ''
        starship preset ${config.starship.preset} > $out
      '';

  starshipConfigFromAttrs = tomlFmt.generate "starship.toml" config.starship.config;

  starshipConfig =
    if config.starship.preset != null then
      starshipConfigFromPreset
    else
      starshipConfigFromAttrs;
in
{
  options.starship = with lib; {
    enable = mkEnableOption "starship";

    package = mkPackageOption pkgs "starship" { };

    preset = mkOption {
      type = with types; nullOr str;
      default = null;
    };

    config = mkOption {
      type = tomlFmt.type;
      default = { };
    };
  };

  config = lib.mkIf config.starship.enable {
    extraPackages = [ config.starship.package ];

    extraContent = lib.mkOrder 1000 ''
      export STARSHIP_CONFIG="${starshipConfig}"
      eval "$(starship init zsh)"
    '';
  };
}
