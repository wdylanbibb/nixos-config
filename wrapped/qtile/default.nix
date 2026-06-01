inputs:
{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:
let
  qtilePackage = pkgs.python3Packages.qtile.override {
    extraPackages = with pkgs.python3Packages; [
      qtile-extras
      dbus-fast
    ];
  };

  helperPackages = with pkgs; [
    imagemagick
    maim
    nautilus
    file-roller
    evince
    satty
    xclip
    xorg.xsetroot
  ];

  helperPath = lib.makeBinPath helperPackages;
in
{
  imports = [ wlib.modules.default ];

  options."config.py" = lib.mkOption {
    type = wlib.types.file config.pkgs;
    default.path = "${./config}/config.py";
  };

  config = {
    package = qtilePackage;
    outputs = [ "out" ];
    filesToPatch = [ ];

    builderFunction =
      {
        config,
        lib,
        lndir,
        ...
      }:
      let
        configPath = config."config.py".path;
      in
      ''
        mkdir -p $out
        ${lndir}/bin/lndir -silent "${config.package}" $out

        rm -f $out/bin/qtile
        cat > $out/bin/qtile <<'EOF'
        #!${pkgs.runtimeShell}
        export PATH="${helperPath}:$PATH"

        if [ "''${1:-}" = "start" ]; then
          shift
          exec "${config.package}/bin/qtile" start -c "${configPath}" "$@"
        elif [ "''${1:-}" = "check" ]; then
          shift
          exec "${config.package}/bin/qtile" check -c "${configPath}" "$@"
        else
          exec "${config.package}/bin/qtile" "$@"
        fi
        EOF
        chmod +x $out/bin/qtile

        rm -f $out/share/xsessions/qtile.desktop
        cat > $out/share/xsessions/qtile.desktop <<EOF
        [Desktop Entry]
        Name=Qtile
        Comment=Qtile Session
        Exec=$out/bin/qtile start
        Type=Application
        Keywords=wm;tiling
        EOF

        rm -f $out/share/wayland-sessions/qtile-wayland.desktop
        cat > $out/share/wayland-sessions/qtile-wayland.desktop <<EOF
        [Desktop Entry]
        Name=Qtile (Wayland)
        Comment=Qtile Session
        Exec=$out/bin/qtile start -b wayland
        Type=Application
        Keywords=wm;tiling
        EOF
      '';
  };
}
