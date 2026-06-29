{
  lib,
  config,
  pkgs,
  var,
  ...
}:
let
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
  obsCfg = config.modules.apps.obs;
in
{
  options.modules.apps.obs = with lib; {
    enable = mkEnableOption "Enable OBS Studio.";

    virtualCamera = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable v4l2loopback support for the OBS virtual camera.";
      };

      users = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = "Users to add to the video group for virtual camera access.";
      };
    };
  };

  config = lib.mkMerge [
    {
      environment = {
        variables = {
          KUBECONFIG = config.sops.secrets.kubeconfig.path;
          TALOSCONFIG = config.sops.secrets.talos-config.path;
        };

        systemPackages = with pkgs; [
          vim
          rust-bin.stable.latest.default
          rust-analyzer
          vscode-extensions.vadimcn.vscode-lldb.adapter
          wrappedPkgs.git
          wrappedPkgs.neovim
          wrappedPkgs.kitty
          wrappedPkgs.zsh
          liquidprompt
          eza
          zsh-command-time
          zsh-forgit
          jq
          fzf
          bat
          ripgrep
          zoxide
          yazi
          lazygit
          bottom
          gcc
          which
          fd
          fzf
          gh
          rclone
          imagemagick

          spotify
          firefox
          vesktop
        ];
        enableAllTerminfo = true;
      };

      time.timeZone = "America/New_York";
      i18n.defaultLocale = "en_US.UTF-8";

      programs.zsh.shellInit = ''
        export KUBECONFIG="${config.sops.secrets.kubeconfig.path}"
        export TALOSCONFIG="${config.sops.secrets.talos-config.path}"
      '';
    }
    (lib.mkIf obsCfg.enable (
      lib.mkMerge [
        {
          programs.obs-studio = {
            enable = true;
            plugins = with pkgs.obs-studio-plugins; [ looking-glass-obs ];
          };
        }

        (lib.mkIf obsCfg.virtualCamera.enable {
          boot = {
            extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
            kernelModules = [ "v4l2loopback" ];
            extraModprobeConfig = ''
              options v4l2loopback devices=1 card_label="OBS Virtual Camera" exclusive_caps=1
            '';
          };

          users.users = lib.genAttrs obsCfg.virtualCamera.users (_: {
            extraGroups = [ "video" ];
          });
        })
      ]
    ))
  ];
}
