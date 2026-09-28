{
  config,
  lib,
  pkgs,
  var,
  ...
}: let
  enabled = config.modules.desktop.profile == "niri-noctalia-tokyonight";
  noctaliaConfig = pkgs.writeTextDir "noctalia/config.toml" ''
    [theme]
    mode = "dark"
    source = "builtin"
    builtin = "Tokyo-Night"

    [wallpaper]
    enabled = true

    [wallpaper.default]
    path = "${../../wallpapers/crosses_3x2.png}"

    [bar.default]
    margin_ends = 0
    widget_spacing = 10
    start = ["launcher", "workspaces", "taskbar"]
    center = ["clock"]
    end = ["media", "tray", "notifications", "clipboard", "network", "volume", "brightness", "battery", "control-center", "session"]

    [widget.taskbar]
    pinned = ["firefox", "kitty"]
    group_by_workspace = true
    only_active_workspace = true
    show_workspace_label = true
  '';
in {
  imports = [var.libInputs.noctalia.nixosModules.default];

  config = lib.mkIf enabled {
    modules.apps = {
      niri = {
        enable = true;
        actions = {
          applications = ["noctalia" "msg" "panel-toggle" "launcher"];
          files = ["nautilus"];
          launcher = ["noctalia" "msg" "panel-toggle" "launcher"];
          media = ["noctalia" "msg" "panel-toggle" "control-center" "media"];
          settings = ["noctalia" "msg" "settings-toggle"];
          terminal = ["kitty"];
        };
      };
      sddm.enable = true;
    };

    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
      systemd = {
        enable = true;
        target = "niri-shell.target";
      };
    };

    # Noctalia treats this as the root containing noctalia/config.toml. Its
    # GUI-managed overrides remain writable under the user's XDG state home.
    environment.sessionVariables = {
      NOCTALIA_CONFIG_HOME = noctaliaConfig;
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      NIXOS_OZONE_WL = "1";
    };

    environment.systemPackages = [pkgs.nautilus];

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
