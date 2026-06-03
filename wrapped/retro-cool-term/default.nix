inputs: {
  config,
  lib,
  pkgs,
  wlib,
  ...
}: let
  spaceMonoFont = pkgs.stdenvNoCC.mkDerivation {
    pname = "space-mono-local";
    version = "1.0";
    src = ./fonts/Space_Mono;
    installPhase = ''
      runHook preInstall
      install -Dm644 SpaceMono-Bold.ttf $out/share/fonts/truetype/SpaceMono-Bold.ttf
      runHook postInstall
    '';
  };

  fontconfig = pkgs.makeFontsConf {
    fontDirectories = [spaceMonoFont];
  };

  settings = builtins.toJSON {
    fps = 20;
    x = 0;
    y = 0;
    width = 1024;
    height = 768;
    windowScaling = 1;
    showTerminalSize = false;
    fontScaling = 1;
    fontNames = [
      "System: Space Mono"
      "COMMODORE_PET"
      "COMMODORE_PET"
    ];
    showMenubar = false;
    bloomQuality = 0.5;
    burnInQuality = 0.5;
    useCustomCommand = false;
    customCommand = "";
  };

  profile = builtins.toJSON {
    ambientLight = 0.07;
    backgroundColor = "#180e13";
    bloom = 0.07;
    brightness = 0.5;
    burnIn = 0.15;
    chromaColor = 0.2483;
    contrast = 0.7959;
    flickering = 0;
    fontColor = "#8187aa";
    fontName = "System: Space Mono";
    fontWidth = 1;
    glowingLine = 0;
    horizontalSync = 0;
    jitter = 0;
    rasterization = 0;
    rbgShift = 0;
    saturationColor = 0.2483;
    screenCurvature = 0;
    staticNoise = 0.1;
    windowOpacity = 1;
    margin = 0;
    blinkingCursor = false;
    frameMargin = 0;
  };

  customProfiles = builtins.toJSON [
    {
      text = "Space Mono Atop";
      obj_string = profile;
      builtin = false;
    }
  ];

  retroCoolTerm = pkgs.symlinkJoin {
    name = "retro-cool-term";
    paths = [pkgs.cool-retro-term];
    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.sqlite
    ];
    postBuild = ''
      config_dir=$out/share/retro-cool-term/config
      storage_dir=$config_dir/cool-retro-term/cool-retro-term/QML/OfflineStorage/Databases
      mkdir -p "$storage_dir" $out/share/fonts/truetype

      ln -s ${spaceMonoFont}/share/fonts/truetype/SpaceMono-Bold.ttf \
        $out/share/fonts/truetype/SpaceMono-Bold.ttf

      cat > "$storage_dir/27e743fe85b8912a46804fed99e8a9ab.ini" <<'EOF'
      [General]
      Description=StorageDatabase
      Driver=QSQLITE
      EstimatedSize=100000
      Name=coolretroterm1
      Version=1.0
      EOF

      sqlite3 "$storage_dir/27e743fe85b8912a46804fed99e8a9ab.sqlite" <<'EOF'
      CREATE TABLE settings(setting TEXT UNIQUE, value TEXT);
      INSERT INTO settings VALUES('_CURRENT_SETTINGS', '${settings}');
      INSERT INTO settings VALUES('_CURRENT_PROFILE', '${profile}');
      INSERT INTO settings VALUES('_CUSTOM_PROFILES', '${customProfiles}');
      EOF

      rm -f $out/bin/retro-cool-term
      makeWrapper ${pkgs.cool-retro-term}/bin/cool-retro-term $out/bin/retro-cool-term \
        --set FONTCONFIG_FILE ${fontconfig} \
        --run 'export XDG_DATA_HOME="$(${pkgs.coreutils}/bin/mktemp -d "''${TMPDIR:-/tmp}/retro-cool-term.XXXXXX")"; ${pkgs.coreutils}/bin/cp -R '"$config_dir"'/cool-retro-term "$XDG_DATA_HOME/"; ${pkgs.coreutils}/bin/chmod -R u+w "$XDG_DATA_HOME/cool-retro-term"' \
        --add-flags "--profile 'Space Mono Atop'"

      cat > $out/bin/retro-cool-term-atop <<'EOF'
      #!${pkgs.runtimeShell}
      exec "$(dirname "$0")/retro-cool-term" "$@" -e ${pkgs.runtimeShell} -lc 'export TERM=xterm-256color; ${pkgs.atop}/bin/atop; code=$?; echo atop exited with status $code; sleep 360'
      EOF
      chmod +x $out/bin/retro-cool-term-atop
    '';
  };
in {
  imports = [wlib.modules.default];

  config = {
    package = retroCoolTerm;
    outputs = ["out"];
    filesToPatch = [];

    builderFunction = {
      config,
      lndir,
      ...
    }: ''
      mkdir -p $out
      ${lndir}/bin/lndir -silent "${config.package}" $out
    '';
  };
}
