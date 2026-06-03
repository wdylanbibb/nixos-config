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
    backgroundColor = "#000000";
    fontColor = "#ffffff";
    flickering = 0;
    horizontalSync = 0;
    staticNoise = 0;
    chromaColor = 1;
    saturationColor = 1;
    screenCurvature = 0;
    glowingLine = 0;
    burnIn = 0.7632;
    bloom = 0.168;
    rasterization = 0;
    jitter = 0.0661;
    rbgShift = 0.1733;
    brightness = 1;
    contrast = 1;
    ambientLight = 0;
    windowOpacity = 1;
    fontName = "System: Space Mono";
    fontWidth = 1.4;
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

  monitorCommand = pkgs.writeShellApplication {
    name = "retro-cool-term-monitor";
    runtimeInputs = with pkgs; [
      bottom
      coreutils
      ncurses
    ];
    text = ''
      export TERM=xterm-256color

      lines="$(tput lines 2>/dev/null || printf 48)"
      bottom_lines=$((lines - 20))
      if [ "$bottom_lines" -lt 1 ]; then
        bottom_lines=1
      fi

      config="$(mktemp "''${TMPDIR:-/tmp}/retro-cool-term-bottom.XXXXXX.toml")"
      cleanup() {
        rm -f "$config"
      }
      trap cleanup EXIT

      cat > "$config" <<BTM_CONFIG
      dot_marker = true
      default_widget_type = "cpu"

      [[row]]
        [[row.child]]
        type="cpu"
      [[row]]
        ratio=2
        [[row.child]]
          ratio=4
          type="mem"
        [[row.child]]
          ratio=3
          [[row.child.child]]
            type="temp"
          [[row.child.child]]
            type="disk"
      BTM_CONFIG

      set +e
      btm -m --default_widget_type cpu --config_location "$config"
      code=$?
      set -e
      echo bottom exited with status "$code"
      sleep 360
    '';
  };

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
      exec "$(dirname "$0")/retro-cool-term" "$@" -e ${monitorCommand}/bin/retro-cool-term-monitor
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
