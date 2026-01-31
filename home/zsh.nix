{ ... }:
{
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
    oh-my-zsh = {
      plugins = [ "helm" "kubectl" "kube-ps1" ];
    };
    shellAliases = {
      nos = "nh os switch";
      nhs = "nh home switch";
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
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    extraOptions = [ "--group-directories-first" "--hyperlink" "--header" ];
  };
}
