inputs: {
  config,
  lib,
  pkgs,
  wlib,
  ...
}: {
  imports = [wlib.modules.default];

  options = {
    "i3.config" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.path = ./config/i3.conf;
      description = "The configuration file used by i3.";
    };

    "i3status.config" = lib.mkOption {
      type = wlib.types.file config.pkgs;
      default.path = ./config/i3status.conf;
      description = "The configuration file used by i3status.";
    };
  };

  config = {
    package = pkgs.i3-rounded;
    outputs = ["out"];
    filesToPatch = [];
    passthru.providedSessions = config.package.providedSessions;

    builderFunction = {
      config,
      lndir,
      ...
    }: ''
      mkdir -p $out
      ${lndir}/bin/lndir -silent "${config.package}" $out

      rm -f $out/bin/i3
      cat > $out/bin/i3 <<'EOF'
      #!${pkgs.runtimeShell}
      exec "${config.package}/bin/i3" \
        --config "${config."i3.config".path}" \
        "$@"
      EOF
      chmod +x $out/bin/i3

      cat > $out/bin/i3status <<'EOF'
      #!${pkgs.runtimeShell}
      exec "${pkgs.i3status}/bin/i3status" \
        --config "${config."i3status.config".path}" \
        "$@"
      EOF
      chmod +x $out/bin/i3status
    '';
  };
}
