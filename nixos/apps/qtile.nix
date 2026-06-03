{
  config,
  lib,
  pkgs,
  var,
  ...
}: let
  cfg = config.modules.apps.qtile;
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
  qtileConfig = wrappedPkgs.qtile.passthru.configuration."config.py".path;
  qtileConfigDir = builtins.dirOf qtileConfig;
  qtileHelperPackages = with pkgs; [
    imagemagick
    maim
    nautilus
    file-roller
    evince
    satty
    xclip
    atop
    wrappedPkgs.retro-cool-term
    xorg.xsetroot
  ];
  eurostileFont = pkgs.stdenvNoCC.mkDerivation {
    pname = "eurostile-extended";
    version = "1.0";
    src = ../../wrapped/qtile/fonts;
    installPhase = ''
      runHook preInstall
      install -Dm644 EurostileExtendedBlack.ttf \
        $out/share/fonts/truetype/EurostileExtendedBlack.ttf
      runHook postInstall
    '';
  };
in {
  options.modules.apps.qtile = with lib; {
    enable = mkEnableOption "Enable the QTile window manager.";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];

      systemPackages = qtileHelperPackages;
      etc."xdg/qtile".source = qtileConfigDir;
    };

    programs.dconf.enable = true;

    services.xserver = {
      enable = true;
      dpi = 96;
      displayManager.sessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge /etc/X11/Xresources
        ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
      '';
      windowManager.qtile = {
        enable = true;
        package = pkgs.python3Packages.qtile;
        extraPackages = python3Packages:
          with python3Packages; [
            qtile-extras
            dbus-fast
          ];
      };
    };

    environment.variables = {
      GDK_SCALE = "1";
      GDK_DPI_SCALE = "1";
      QTILE_WALLPAPER_DIR = "${../../wrapped/qtile/wallpapers}";
    };

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    fonts.packages = with pkgs; [
      eurostileFont
      wrappedPkgs.retro-cool-term
      nerd-fonts.monaspace
      inter
      font-awesome
    ];
  };
}
