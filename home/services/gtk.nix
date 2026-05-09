{
  config,
  pkgs,
  ...
}: let
  browser = ["firefox.desktop"];
  fileManager = ["org.gnome.Nautilus.desktop"];
  documentViewer = ["org.gnome.Evince.desktop"];
  imageViewer = ["org.gnome.Loupe.desktop"];
  archiveManager = ["org.gnome.FileRoller.desktop"];
in {
  home = {
    packages = with pkgs; [
      desktop-file-utils
      gsettings-desktop-schemas
      shared-mime-info
      xdg-utils
    ];

    sessionVariables = {
      BROWSER = "firefox";
      GTK_THEME = config.gtk.theme.name;
      GTK_USE_PORTAL = "1";
    };
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
    gtk3 = {
      extraConfig = {
        gtk-decoration-layout = "menu:";
      };
      bookmarks = [
        "file://${config.home.homeDirectory}/Desktop"
        "file://${config.home.homeDirectory}/Documents"
        "file://${config.home.homeDirectory}/Downloads"
        "file://${config.home.homeDirectory}/Music"
        "file://${config.home.homeDirectory}/Pictures"
        "file://${config.home.homeDirectory}/Videos"
      ];
    };
    gtk4.extraConfig = {
      gtk-decoration-layout = "menu:";
    };
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Inter Variable";
      size = 10;
      package = pkgs.inter;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    cursor-size = config.home.pointerCursor.size;
    cursor-theme = config.home.pointerCursor.name;
    font-name = "${config.gtk.font.name} ${toString config.gtk.font.size}";
    gtk-theme = config.gtk.theme.name;
    icon-theme = config.gtk.iconTheme.name;
  };

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplicationPackages = with pkgs; [
        firefox
        nautilus
        loupe
        evince
        file-roller
      ];
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
        "org.freedesktop.impl.portal.AppChooser" = ["gtk"];
        "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
        "org.freedesktop.impl.portal.Settings" = ["gtk"];
        "org.freedesktop.impl.portal.Background" = ["gnome"];
        "org.freedesktop.impl.portal.Clipboard" = ["gnome"];
        "org.freedesktop.impl.portal.GlobalShortcuts" = ["gnome"];
        "org.freedesktop.impl.portal.InputCapture" = ["gnome"];
        "org.freedesktop.impl.portal.RemoteDesktop" = ["gnome"];
        "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
        "org.freedesktop.impl.portal.Screenshot" = ["gnome"];
        "org.freedesktop.impl.portal.Usb" = ["gnome"];
      };
    };
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      publicShare = "${config.home.homeDirectory}/Public";
      templates = "${config.home.homeDirectory}/Templates";
      videos = "${config.home.homeDirectory}/Videos";
    };
    configFile = {
      "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
      "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
      "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };
}
