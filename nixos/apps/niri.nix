{
  config,
  lib,
  pkgs,
  var,
  ...
}: let
  cfg = config.modules.apps.niri;
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
  actionDescriptions = {
    applications = "Open the application browser.";
    files = "Open the file manager.";
    launcher = "Open the application launcher.";
    media = "Open the media application or controls.";
    settings = "Open desktop settings.";
    terminal = "Open the terminal.";
  };
  configuredActions = lib.filterAttrs (_: command: command != null) cfg.actions;
  niriAction = pkgs.writeShellApplication {
    name = "niri-action";
    text = ''
      case "''${1:-}" in
        ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: command: ''
          ${lib.escapeShellArg name})
            shift
            exec ${lib.escapeShellArgs command} "$@"
            ;;
        '')
        configuredActions
      )}
        *)
          echo "Unsupported Niri action: ''${1:-}" >&2
          exit 2
          ;;
      esac
    '';
  };
in {
  options.modules.apps.niri = {
    enable = lib.mkEnableOption "Enable the Niri window manager.";
    actions = lib.mapAttrs (_: description:
      lib.mkOption {
        type = lib.types.nullOr (lib.types.nonEmptyListOf lib.types.str);
        default = null;
        inherit description;
      })
    actionDescriptions;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [niriAction];

    programs.niri = {
      enable = true;
      package = wrappedPkgs.niri;
      useNautilus = false;
    };

    systemd.user.targets.niri-shell = {
      description = "Desktop shell services for the Niri session";
      bindsTo = ["graphical-session.target"];
      after = ["graphical-session.target"];
    };
  };
}
