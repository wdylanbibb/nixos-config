{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.apps.codex;
in {
  options.modules.apps.codex = {
    enable = lib.mkEnableOption "OpenAI Codex CLI";

    package = lib.mkPackageOption pkgs "codex" {};

    daemon = {
      enable = lib.mkEnableOption "the Codex app-server daemon at user-session startup";

      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        example = ["--enable" "responses_websockets"];
        description = "Additional arguments passed to `codex app-server daemon`.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable || cfg.daemon.enable) {
      environment.systemPackages = [cfg.package];
    })

    (lib.mkIf cfg.daemon.enable {
      systemd.user.services.codex-app-server = {
        description = "Codex app-server daemon";
        wantedBy = ["default.target"];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.escapeShellArgs (
            ["${cfg.package}/bin/codex" "app-server" "daemon"]
            ++ cfg.daemon.extraArgs
            ++ ["start"]
          );
          ExecStop = "${cfg.package}/bin/codex app-server daemon stop";
        };
      };
    })
  ];
}
