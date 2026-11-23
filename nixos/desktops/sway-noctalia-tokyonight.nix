{
  config,
  lib,
  pkgs,
  var,
  ...
}: let
  enabled = config.modules.desktop.profile == "sway-noctalia-tokyonight";
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
  noctaliaDefaults = {
    theme = {
      mode = "dark";
      source = "builtin";
      builtin = "Tokyo-Night";
    };
    wallpaper = {
      enabled = true;
      default.path = "${../../wallpapers/crosses_4k.png}";
    };
    bar.default = {
      margin_ends = 0;
      widget_spacing = 10;
      start = ["launcher" "workspaces" "taskbar"];
      center = ["clock"];
      end = ["media" "tray" "notifications" "clipboard" "network" "volume" "brightness" "battery" "control-center" "session"];
    };
    widget.taskbar = {
      pinned = ["firefox" "kitty"];
      group_by_workspace = true;
      only_active_workspace = true;
      show_workspace_label = true;
    };
  };
  noctaliaSettings = lib.recursiveUpdate noctaliaDefaults config.modules.apps.noctalia.settings;
  noctaliaConfigFile = (pkgs.formats.toml {}).generate "config.toml" noctaliaSettings;
  noctaliaConfig = pkgs.linkFarm "noctalia-config" [
    {
      name = "noctalia/config.toml";
      path = noctaliaConfigFile;
    }
  ];
in {
  config = lib.mkIf enabled {
    modules.apps = {
      gtk.enable = true;
      noctaliaGreeter.enable = true;
      sway = {
        enable = true;
        extraConfig = ''
          # Save screenshots in the user's default screenshot directory and copy them to the clipboard.
          bindsym Print exec grimshot --notify copysave screen
          bindsym Shift+Print exec grimshot --notify copysave area
          bindsym Mod1+Print exec grimshot --notify copysave active
        '';
      };
    };

    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
      systemd = {
        enable = true;
        target = "sway-shell.target";
      };
    };

    environment = {
      sessionVariables = {
        NOCTALIA_CONFIG_HOME = noctaliaConfig;
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        NIXOS_OZONE_WL = "1";
      };
      systemPackages = [
        pkgs.nautilus
        pkgs.sway-contrib.grimshot
        wrappedPkgs.kitty
      ];
    };

    systemd.user.services.noctalia.environment.NOCTALIA_CONFIG_HOME = noctaliaConfig;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    security.rtkit.enable = true;

    fonts.packages = with pkgs; [
      font-awesome
      inter
      nerd-fonts.monaspace
      noto-fonts
    ];
  };
}
