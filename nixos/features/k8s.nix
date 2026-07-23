{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.k8s;
in
{
  options.features.k8s = with lib; {
    enable = mkEnableOption "Enable Talos linux and Kubernetes programs and config";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        kubernetes
        kubernetes-helm
        sops
        talosctl
        fluxcd
      ];

      variables = {
        KUBECONFIG = config.sops.secrets.kubeconfig.path;
        TALOSCONFIG = config.sops.secrets.talos-config.path;
      };
    };

    sops.secrets = {
      kubeconfig = {
        owner = "dylan";
        group = "users";
      };
      talos-config = {
        owner = "dylan";
        group = "users";
      };

      # talos-auth = {
      #   owner = "dylan";
      #   group = "users";
      # };
    };
  };
}
