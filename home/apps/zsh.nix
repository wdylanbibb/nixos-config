{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    liquidprompt
    zsh-command-time
    zsh-forgit
    jq
    fzf
    bat
    ripgrep
    zoxide
    yazi
    lazygit
    gcc
    which
    fd
    fzf
    gh
    rclone
    imagemagick
  ];

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
      "--hyperlink"
      "--header"
    ];
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "tokyo-night";
      simplified_ui = true;
      pane_frames = false;
      default_layout = "compact";
      show_startup_tips = false;
    };
  };

  programs.zsh = rec {
    enable = true;
    syntaxHighlighting.enable = true;
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
    zsh-abbr = {
      enable = true;
      abbreviations = shellAliases;
    };
    initContent = ''
      if [[ -z "$ZELLIJ" && -z "$SSH_CLIENT" ]]; then
        if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
          zellij attach -c
        else
          zellij
        fi

        if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
          exit
        fi
      fi
      [[ $- = *i* ]] && source ${pkgs.liquidprompt}/bin/liquidprompt
    '';
    sessionVariables.ZELLIJ_AUTO_EXIT = "true";
  };
}
