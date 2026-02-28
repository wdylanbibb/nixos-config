{ config, lib, ... }:
{
  imports = [
    ./starship.nix
    ./oh-my-zsh.nix
    ./zsh-abbr.nix
    ./zsh-f-sy-h.nix
    ./zhs-autosuggestions.nix
  ];

  options =
    with lib;
    let
      pluginModule = types.submodule (
        { config, ... }:
        {
          options = {
            src = mkOption {
              type = with types; path;
            };

            name = mkOption {
              type = with types; str;
            };

            file = mkOption {
              type = with types; str;
            };
          };

          config.file = mkDefault "${config.name}.plugins.zsh";
        }
      );
    in
    {
      plugins = mkOption {
        type = with types; listOf pluginModule;
        default = [ ];
      };
    };

  config = lib.mkIf (config.plugins != [ ]) {
    extraPackages = map (plugin: plugin.src) config.plugins;

    extraContent = lib.mkOrder 900 (
      lib.concatMapStringsSep "\n" (
        plugin: ''[[ -f "${plugin.src}/${plugin.file}" ]] && source "${plugin.src}/${plugin.file}"''
      ) config.plugins
    );
  };
}
