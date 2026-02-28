inputs:
{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
{
  imports = [
    wlib.modules.default
    ./plugins
  ];

  options = with lib; {
    shellAliases = mkOption {
      type = with types; attrsOf str;
      default = { };
    };

    environment = mkOption {
      type = with types; attrsOf str;
      default = { };
    };

    extraContent = mkOption {
      type = with types; lines;
      default = "";
    };

    ".zshrc" =
      let
        aliasesStr = builtins.concatStringsSep "\n" (
          lib.mapAttrsToList (
            k: v: "alias -- ${lib.escapeShellArg k}=${lib.escapeShellArg v}"
          ) config.shellAliases
        );
      in
      mkOption {
        type = wlib.types.file config.pkgs;
        default.content = ''
          ${lib.optionalString (aliasesStr != "") aliasesStr}
          ${config.extraContent}
        '';
      };

    ".zshenv" = mkOption {
      type = wlib.types.file config.pkgs;
      default.content = builtins.concatStringsSep "\n" [
        (lib.concatMapAttrsStringSep "\n" (k: v: "${k}=${v}") config.environment)
      ];
    };
  };

  config = rec {
    oh-my-zsh = {
      enable = true;
      plugins = [
        "aliases"
        "catimg"
        "colored-man-pages"
        "dircycle"
        "fancy-ctrl-z"
        "gitfast"
        "sudo"
        "zoxide"
        "ssh-agent"
        "tailscale"
        "helm"
        "kubectl"
        "kube-ps1"
      ];
    };

    autosuggestions.enable = true;

    f-sy-h.enable = true;

    zsh-abbr = {
      enable = true;
      abbreviations = shellAliases;
    };

    starship = {
      enable = true;
      preset = "jetpack";
    };

    shellAliases = {
      nos = "nh os switch -a";
      nhs = "nh home switch -a";
      g = "lazygit";
      y = "yazi";

      lD = "eza -glD";
      lDD = "eza -glDa";
      lS = "eza -gl -ssize";
      lT = "eza -gl -snewest";
      la = "eza -a";
      ldot = "eza -gld .*";
      ll = "eza -l";
      lla = "eza -la";
      ls = "eza";
      lsd = "eza -gd";
      lsdl = "eza -gld";
      lt = "eza --tree";
      l = "eza -lah";
      lsa = "eza -lah";

      egrep = "grep -E";
      fgrep = "grep -F";
    };

    env.ZDOTDIR = toString (
      config.pkgs.linkFarm "zsh-merged-config" [
        {
          name = ".zshrc";
          inherit (config.".zshrc") path;
        }
        {
          name = ".zshenv";
          inherit (config.".zshenv") path;
        }
      ]
    );

    package = lib.mkDefault pkgs.zsh;
  };
}
