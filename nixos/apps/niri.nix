{
  config,
  lib,
  pkgs,
  var,
  ...
}: let
  cfg = config.modules.apps.niri;
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in {
  options.modules.apps.niri = with lib; {
    enable = mkEnableOption "Enable the Niri window manager.";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        mako
        swaylock
        wrappedPkgs.niri
        wrappedPkgs.waybar
      ];

      variables.NIXOS_OZONE_WL = "1";

      etc = {
        "xdg/mako/config".text = ''
          background-color=#1E1E2E
          border-color=#7aa2f7
          border-radius=8
          border-size=2
          default-timeout=5000
          font=MonaspiceAr NF 10
          icons=1
          markup=1
        '';

        "xdg/swaylock/config".text = ''
          color=1E1E2E
        '';

        "xdg/vicinae/settings.json".text = builtins.toJSON {
          theme.name = "tokyo-night";
        };
      };
    };

    programs.niri.enable = true;

    systemd.user.services.mako = {
      description = "Lightweight Wayland notification daemon";
      documentation = [ "man:mako(1)" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.mako}/bin/mako";
        Restart = "on-failure";
      };
    };

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    fonts.packages = with pkgs; [
      nerd-fonts.monaspace
      inter
      font-awesome
    ];
  };
}
