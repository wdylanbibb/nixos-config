{
  lib,
  pkgs,
  var,
  ...
}:
let
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  environment = {
    systemPackages = with pkgs; [
      vim
      rust-bin.stable.latest.default
      rust-analyzer
      vscode-extensions.vadimcn.vscode-lldb.adapter
      wrappedPkgs.git
      wrappedPkgs.neovim
      wrappedPkgs.kitty
      wrappedPkgs.zsh
      liquidprompt
      eza
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

      spotify
      firefox
      vesktop
    ];
    enableAllTerminfo = true;
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
}
