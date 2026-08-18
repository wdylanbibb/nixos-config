{
  config,
  lib,
  pkgs,
  var,
  ...
}: let
  enabled = config.modules.desktop.profile == "cosmic-niri-tokyonight";
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
  cosmicWallpaper = ../../wallpapers/crosses_3x2.png;
  cosmicPanelLayout = "${pkgs.cosmic-initial-setup}/share/cosmic-layouts/top-panel-and-bottom-dock";
  initializeCosmicPanel = pkgs.writeShellScript "initialize-cosmic-panel" ''
    config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
    cosmic_config="$config_home/cosmic"

    # cosmic-session normally installs the selected layout.  Under Niri there
    # is no cosmic-session, so seed the standard layout on first launch only.
    if [[ ! -e "$cosmic_config/com.system76.CosmicPanel/v1/entries" ]]; then
      mkdir -p "$cosmic_config"
      cp -R --no-preserve=mode ${cosmicPanelLayout}/com.system76.CosmicPanel* "$cosmic_config/"
    fi
  '';
  initializeCosmicTheme = pkgs.writeShellScript "initialize-cosmic-tokyonight-theme" ''
    cosmic_ctl=${lib.getExe' pkgs.cosmic-ext-ctl "cosmic-ctl"}

    write_theme() {
      "$cosmic_ctl" write "$2" \
        --component com.system76.CosmicTheme.Dark.Builder \
        --version 1 \
        --entry "$1"
    }

    # Tokyo Night's core colors, expressed as COSMIC's normalized RGB values.
    write_theme bg_color 'Some((red: 0.101961, green: 0.105882, blue: 0.149020, alpha: 1.0))'
    write_theme primary_container_bg 'Some((red: 0.141176, green: 0.156863, blue: 0.231373, alpha: 1.0))'
    write_theme secondary_container_bg 'Some((red: 0.121569, green: 0.137255, blue: 0.207843, alpha: 1.0))'
    write_theme neutral_tint 'Some((red: 0.337255, green: 0.372549, blue: 0.537255))'
    write_theme text_tint 'Some((red: 0.752941, green: 0.792157, blue: 0.960784))'
    write_theme accent 'Some((red: 0.478431, green: 0.635294, blue: 0.968627))'
    write_theme success 'Some((red: 0.619608, green: 0.807843, blue: 0.415686))'
    write_theme warning 'Some((red: 0.878431, green: 0.686275, blue: 0.407843))'
    write_theme destructive 'Some((red: 0.968627, green: 0.462745, blue: 0.556863))'

    "$cosmic_ctl" write true \
      --component com.system76.CosmicTheme.Mode \
      --version 1 \
      --entry is_dark
    "$cosmic_ctl" write false \
      --component com.system76.CosmicTheme.Mode \
      --version 1 \
      --entry auto_switch
    "$cosmic_ctl" build-theme
  '';
  initializeCosmicBackground = pkgs.writeShellScript "initialize-cosmic-background" ''
    cosmic_ctl=${lib.getExe' pkgs.cosmic-ext-ctl "cosmic-ctl"}

    "$cosmic_ctl" write true \
      --component com.system76.CosmicBackground \
      --version 1 \
      --entry same-on-all
    "$cosmic_ctl" write \
      '(output: "all", source: Path("${cosmicWallpaper}"), filter_by_theme: false, rotation_frequency: 900, filter_method: Lanczos, scaling_mode: Zoom, sampling_method: Alphanumeric)' \
      --component com.system76.CosmicBackground \
      --version 1 \
      --entry all
  '';

  # COSMIC normally starts these from cosmic-session.  This profile uses Niri
  # as the session compositor, so give the COSMIC shell its own lifecycle.
  cosmicService = description: package: executable: {
    inherit description;
    wantedBy = ["cosmic-niri-session.target"];
    partOf = ["cosmic-niri-session.target"];
    after = ["graphical-session.target" "cosmic-tokyonight-theme.service"];
    serviceConfig = {
      ExecStart = lib.getExe' package executable;
      Restart = "on-failure";
      RestartSec = 1;
    };
  };
in {
  config = lib.mkIf enabled {
    modules.apps = {
      niri.enable = true;
      sddm.enable = true;
    };

    # Keep the full COSMIC application suite, but not cosmic-comp or
    # cosmic-session: Niri is the compositor and session manager here.
    environment = {
      systemPackages = with pkgs; [
        adwaita-icon-theme
        cosmic-app-library
        cosmic-applets
        cosmic-bg
        cosmic-design-demo
        cosmic-edit
        cosmic-ext-applet-caffeine
        cosmic-ext-applet-external-monitor-brightness
        cosmic-ext-applet-minimon
        cosmic-ext-applet-privacy-indicator
        cosmic-ext-applet-sysinfo
        cosmic-ext-applet-weather
        cosmic-ext-calculator
        cosmic-ext-ctl
        cosmic-ext-tweaks
        cosmic-files
        cosmic-icons
        cosmic-idle
        cosmic-initial-setup
        cosmic-launcher
        cosmic-monitor
        cosmic-notifications
        cosmic-osd
        cosmic-panel
        cosmic-player
        cosmic-randr
        cosmic-reader
        cosmic-screenshot
        cosmic-settings
        cosmic-settings-daemon
        cosmic-store
        cosmic-wallpapers
        hicolor-icon-theme
        networkmanagerapplet
        playerctl
        pop-icon-theme
        pop-launcher
        wl-clipboard
        xdg-user-dirs
        xwayland-satellite
        wrappedPkgs.kitty
      ];

      pathsToLink = [
        "/share/backgrounds"
        "/share/cosmic"
        "/share/cosmic-layouts"
        "/share/cosmic-themes"
      ];

      sessionVariables = {
        COSMIC_DATA_CONTROL_ENABLED = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        NIXOS_OZONE_WL = "1";
        X11_BASE_RULES_XML = "${config.services.xserver.xkb.dir}/rules/base.xml";
        X11_EXTRA_RULES_XML = "${config.services.xserver.xkb.dir}/rules/base.extras.xml";
      };
    };

    # COSMIC applications use these schemas, icons and desktop defaults even
    # though cosmic-session itself is intentionally not enabled.
    programs.dconf = {
      enable = true;
      packages = [pkgs.cosmic-session];
    };

    services = {
      accounts-daemon.enable = true;
      dbus.packages = with pkgs; [cosmic-settings-daemon cosmic-notifications];
      geoclue2 = {
        enable = true;
        enableDemoAgent = false;
        whitelistedAgents = ["geoclue-demo-agent"];
      };
      graphical-desktop.enable = true;
      gnome.gnome-keyring.enable = true;
      gvfs.enable = true;
      libinput.enable = true;
      pipewire = {
        enable = true;
        pulse.enable = true;
      };
      power-profiles-daemon.enable = lib.mkDefault true;
      upower.enable = true;
    };

    hardware.bluetooth.enable = lib.mkDefault true;
    networking.networkmanager.enable = lib.mkDefault true;
    security = {
      polkit = {
        enable = true;
        enablePkexecWrapper = true;
      };
      rtkit.enable = true;
    };

    xdg = {
      sounds.enable = true;
      icons.fallbackCursorThemes = ["Cosmic"];
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-cosmic
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
        config.niri = {
          default = lib.mkForce ["cosmic" "gnome" "gtk"];
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.FileChooser" = lib.mkForce "cosmic";
          "org.freedesktop.impl.portal.Notification" = lib.mkForce "cosmic";
          "org.freedesktop.impl.portal.ScreenCast" = "gnome";
          "org.freedesktop.impl.portal.Screenshot" = "gnome";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };
      };
    };

    systemd.user = {
      targets.cosmic-niri-session = {
        description = "COSMIC shell services for the Niri session";
        bindsTo = ["graphical-session.target"];
        after = ["graphical-session.target"];
      };

      services = {
        cosmic-tokyonight-theme = {
          description = "Apply the Tokyo Night theme to COSMIC applications";
          wantedBy = ["cosmic-niri-session.target"];
          partOf = ["cosmic-niri-session.target"];
          before = [
            "cosmic-app-library.service"
            "cosmic-launcher.service"
            "cosmic-panel.service"
            "cosmic-settings-daemon.service"
          ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = initializeCosmicTheme;
            RemainAfterExit = true;
          };
        };
        cosmic-bg =
          lib.recursiveUpdate
          (cosmicService "COSMIC wallpaper service" pkgs.cosmic-bg "cosmic-bg")
          {
            serviceConfig.ExecStartPre = initializeCosmicBackground;
          };
        cosmic-idle = cosmicService "COSMIC idle service" pkgs.cosmic-idle "cosmic-idle";
        cosmic-notifications = cosmicService "COSMIC notification daemon" pkgs.cosmic-notifications "cosmic-notifications";
        cosmic-osd = cosmicService "COSMIC on-screen display" pkgs.cosmic-osd "cosmic-osd";
        cosmic-app-library =
          lib.recursiveUpdate
          (cosmicService "COSMIC app library" pkgs.cosmic-app-library "cosmic-app-library")
          {
            # Desktop entries use executable names rather than store paths.
            path = [config.system.path];
          };
        cosmic-launcher =
          lib.recursiveUpdate
          (cosmicService "COSMIC launcher" pkgs.cosmic-launcher "cosmic-launcher")
          {
            # Match the desktop-entry search path and include the launcher's
            # backend so selected applications can be resolved and executed.
            path = [config.system.path];
          };
        cosmic-panel =
          lib.recursiveUpdate
          (cosmicService "COSMIC panel and applets" pkgs.cosmic-panel "cosmic-panel")
          {
            after = ["cosmic-notifications.service"];
            path = with pkgs; [
              cosmic-app-library
              cosmic-applets
              cosmic-launcher
              cosmic-settings
            ];
            serviceConfig.ExecStartPre = initializeCosmicPanel;
          };
        cosmic-settings-daemon = cosmicService "COSMIC settings daemon" pkgs.cosmic-settings-daemon "cosmic-settings-daemon";
      };
    };

    fonts.packages = with pkgs; [
      fira
      font-awesome
      inter
      nerd-fonts.monaspace
      noto-fonts
      open-sans
    ];
  };
}
