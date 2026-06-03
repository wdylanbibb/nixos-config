{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.apps.gtk;

  theme = {
    name = "Graphite-Dark";
    package = pkgs.graphite-gtk-theme.overrideAttrs (_old: {
      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/themes
        patchShebangs install.sh
        ./install.sh --dest $out/share/themes --name Graphite --theme default --color dark --tweaks black

        runHook postInstall
      '';
    });
  };
  iconTheme = {
    name = "HighContrast";
    package = pkgs.gnome-themes-extra;
  };
  cursorTheme = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
  };
  font = {
    name = "Inter Variable";
    package = pkgs.inter;
    size = 10;
  };

  browser = [ "firefox.desktop" ];
  fileManager = [ "org.gnome.Nautilus.desktop" ];
  documentViewer = [ "org.gnome.Evince.desktop" ];
  imageViewer = [ "org.gnome.Loupe.desktop" ];
  archiveManager = [ "org.gnome.FileRoller.desktop" ];
  videoPlayer = [ "vlc.desktop" ];

  gtkSettings = ''
    [Settings]
    gtk-application-prefer-dark-theme=true
    gtk-cursor-theme-name=${cursorTheme.name}
    gtk-cursor-theme-size=${toString cursorTheme.size}
    gtk-decoration-layout=menu:
    gtk-font-name=${font.name} ${toString font.size}
    gtk-icon-theme-name=${iconTheme.name}
    gtk-theme-name=${theme.name}
  '';

  xresources = ''
    Xcursor.theme: ${cursorTheme.name}
    Xcursor.size: ${toString cursorTheme.size}
  '';
in
{
  options.modules.apps.gtk = with lib; {
    enable = mkEnableOption "Enable system GTK, Qt, XDG, and MIME defaults.";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        desktop-file-utils
        gsettings-desktop-schemas
        shared-mime-info
        xdg-user-dirs
        xdg-utils

        firefox
        nautilus
        loupe
        evince
        file-roller
        vlc

        theme.package
        iconTheme.package
        cursorTheme.package
      ];

      variables = {
        BROWSER = "firefox";
        GTK_THEME = theme.name;
        GTK_USE_PORTAL = "1";
        XCURSOR_SIZE = toString cursorTheme.size;
        XCURSOR_THEME = cursorTheme.name;
      };

      etc = {
        "xdg/gtk-3.0/settings.ini".text = gtkSettings;
        "xdg/gtk-4.0/settings.ini".text = gtkSettings;
        "X11/Xresources".text = xresources;
        "xdg/gtk-4.0/assets".source = "${theme.package}/share/themes/${theme.name}/gtk-4.0/assets";
        "xdg/gtk-4.0/gtk.css".source = "${theme.package}/share/themes/${theme.name}/gtk-4.0/gtk.css";
        "xdg/gtk-4.0/gtk-dark.css".source = "${theme.package}/share/themes/${theme.name}/gtk-4.0/gtk-dark.css";
        "xdg/user-dirs.defaults".text = ''
          DESKTOP=Desktop
          DOWNLOAD=Downloads
          TEMPLATES=Templates
          PUBLICSHARE=Public
          DOCUMENTS=Documents
          MUSIC=Music
          PICTURES=Pictures
          VIDEOS=Videos
        '';
      };
    };

    fonts.packages = [ font.package ];

    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings."org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            cursor-size = lib.gvariant.mkUint32 cursorTheme.size;
            cursor-theme = cursorTheme.name;
            font-name = "${font.name} ${toString font.size}";
            gtk-theme = theme.name;
            icon-theme = iconTheme.name;
          };
        }
      ];
    };

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    systemd.user.tmpfiles.rules = [
      "d %h/Desktop 0755 - - -"
      "d %h/Documents 0755 - - -"
      "d %h/Downloads 0755 - - -"
      "d %h/Music 0755 - - -"
      "d %h/Pictures 0755 - - -"
      "d %h/Public 0755 - - -"
      "d %h/Templates 0755 - - -"
      "d %h/Videos 0755 - - -"
    ];

    systemd.user.services.gtk-user-defaults = {
      description = "Apply GTK and XDG user defaults";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p "$HOME/.config/gtk-3.0"
        cat > "$HOME/.config/gtk-3.0/bookmarks" <<EOF
        file://$HOME/Desktop
        file://$HOME/Documents
        file://$HOME/Downloads
        file://$HOME/Music
        file://$HOME/Pictures
        file://$HOME/Videos
        EOF

        ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update --set DESKTOP "$HOME/Desktop"
        ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update --set DOCUMENTS "$HOME/Documents"
        ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update --set DOWNLOAD "$HOME/Downloads"
        ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update --set MUSIC "$HOME/Music"
        ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update --set PICTURES "$HOME/Pictures"
        ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update --set PUBLICSHARE "$HOME/Public"
        ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update --set TEMPLATES "$HOME/Templates"
        ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update --set VIDEOS "$HOME/Videos"
      '';
    };

    xdg = {
      icons.enable = true;
      mime = {
        enable = true;
        defaultApplications = {
          "text/html" = browser;
          "application/xhtml+xml" = browser;
          "application/xml" = browser;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/chrome" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/unknown" = browser;

          "inode/directory" = fileManager;

          "application/pdf" = documentViewer;
          "application/postscript" = documentViewer;
          "application/x-bzpdf" = documentViewer;
          "application/x-gzpdf" = documentViewer;
          "image/vnd.djvu" = documentViewer;

          "image/avif" = imageViewer;
          "image/bmp" = imageViewer;
          "image/gif" = imageViewer;
          "image/heic" = imageViewer;
          "image/jpeg" = imageViewer;
          "image/jxl" = imageViewer;
          "image/png" = imageViewer;
          "image/svg+xml" = imageViewer;
          "image/tiff" = imageViewer;
          "image/webp" = imageViewer;

          "application/epub+zip" = archiveManager;
          "application/gzip" = archiveManager;
          "application/vnd.rar" = archiveManager;
          "application/x-7z-compressed" = archiveManager;
          "application/x-bzip2" = archiveManager;
          "application/x-compressed-tar" = archiveManager;
          "application/x-tar" = archiveManager;
          "application/x-xz" = archiveManager;
          "application/zip" = archiveManager;

          "video/mp4" = videoPlayer;
          "video/x-matroska" = videoPlayer;
          "video/flv" = videoPlayer;
          "video/mpeg" = videoPlayer;
          "video/ogg" = videoPlayer;
          "video/quicktime" = videoPlayer;
        };
      };
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];
        config.common = {
          default = [
            "gtk"
            "gnome"
          ];
          "org.freedesktop.impl.portal.AppChooser" = [ "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
          "org.freedesktop.impl.portal.Background" = [ "gnome" ];
          "org.freedesktop.impl.portal.Clipboard" = [ "gnome" ];
          "org.freedesktop.impl.portal.GlobalShortcuts" = [ "gnome" ];
          "org.freedesktop.impl.portal.InputCapture" = [ "gnome" ];
          "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
          "org.freedesktop.impl.portal.Usb" = [ "gnome" ];
        };
      };
    };
  };
}
