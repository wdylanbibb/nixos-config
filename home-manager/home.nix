{ config, osConfig, inputs, lib, pkgs, ... }:
{
  imports = [
    # ../home-shared.nix
    ./herbstluftwm.nix
    ./polybar.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "dylan";
  home.homeDirectory = "/home/dylan";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xsession.windowManager.herbstluftwm.enable = true;

  home.packages = with pkgs; [
    neofetch
    nnn

    zip
    xz
    unzip
    p7zip

    gcc

    ripgrep
    jq
    eza
    fzf
    thefuck
    bat
    xclip
    lazygit
    git-extras

    zoxide

    which
    tree

    btop
    cowsay
    fortune

    usbutils

    vesktop
    spotify

    rust-analyzer

    monaspace

    zsh-forgit
    zsh-command-time

    liquidprompt

    gimp
    pipes-rs
    rofi
    wezterm
    xdotool
    maim
    imagemagick
    polybar-pulseaudio-control
    strawberry
    moonlight-qt
  ];

  programs.git = {
    enable = true;
    userName = "Dylan Bibb";
    userEmail = "wdylanbibb@gmail.com";
    delta = {
      enable = true;
      options.side-by-side = true;
    };
    extraConfig = {
      safe = {
        directory = [ "/etc/nixos" ];
      };
    };
  };

  programs.lazygit = {
    enable = true;
    settings.git.paging = {
      colorArg = "always";
      pager = "delta --paging=never -s";
    };
  };

  programs.firefox.enable = true;
  programs.zoxide.enable = true;

  programs.zellij = {
    enable = true;
    settings = {
      plugins = {
        autolock = {
          _props = {
            location = "https://github.com/fresh2dev/zellij-autolock/releases/download/0.2.2/zellij-autolock.wasm";
          };
          is_enabled = false;
        };
        multitask = {
          _props = {
            location = "file:${inputs.zellij-nix.plugins.${pkgs.system}.multitask}/bin/multitask.wasm";
          };
          shell = "${pkgs.zsh}/bin/zsh";
        };
      };
      load_plugins = {
        "autolock" = [];
      };
      keybinds = {
        normal = {
          "bind \"Ctrl l\"".Run = { 
            _args = [ "zellij" "run" "--floating" "--" "lazygit" ];
            close_on_exit = true;
          };
        };
      };
    };
  };
  xdg.configFile."zellij/layouts/nixos_config.kdl" = {
    enable = true;
    text = lib.hm.generators.toKDL { } {
      layout = {
        tab = {
          _props = {
            name = "Nixos Config";
            cwd = "/etc/nixos";
            focus = true;
          };
          "pane size=1 borderless=true".plugin._props.location = "zellij:tab-bar";
          "pane split_direction=\"Vertical\"" = {
            # "pane size=\"15%\"".plugin._props.location = "zellij:strider";
            "pane split_direction=\"Horizontal\"" = {
              pane.edit = "flake.nix";
              "pane size=\"15%\" command=\"sudo\"".args = [ "nixos-rebuild" "switch" "--flake" ".#${osConfig.networking.hostName}" ];
            };
          };
        };
      };
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    localVariables = {
      ZELLIJ_AUTO_EXIT = true;
    };
    initExtra = ''
      if [[ -z "$ZELLIJ" ]]; then
        if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
          zellij attach -c
        else
          zellij -l welcome
        fi

        if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
          exit
        fi
      fi
      [[ $- = *i* ]] && source ${pkgs.liquidprompt}/bin/liquidprompt
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [ "ssh-agent" "git" "thefuck" "aliases" "alias-finder" "eza" "rsync" "ssh" "vi-mode" "zsh-interactive-cd" "rust" ];
    };
    sessionVariables = {
      TERMINAL = "wezterm";
    };
  };

  programs.vim.enable = true;

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host ilab
        Hostname ilab.cs.rutgers.edu
        User wdb46
    '';
  };

  services.polybar = {
    package = pkgs.polybar.override {
      pulseSupport = true;
    };
    enable = true;
  };
  systemd.user.services.polybar = {
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require("wezterm")
      local act = wezterm.action
      return {
        keys = {},
        use_fancy_tab_bar = false,
        tab_bar_at_bottom = true,
        hide_tab_bar_if_only_one_tab = true,
        font_size = 8,
        font = wezterm.font("Cozette"),
        front_end = "WebGpu",
      }'';
  };

  programs.btop = {
    enable = true;
    settings = {
      show_io_stat = false;
      disks_filter = "exclude=/persist /etc/NetworkManager/system-connections /etc/nixos /home /nix /var/lib/libvirt/images /var/lib/nixos /var/lib/systemd/coredump /var/log /etc/ssh /var/lib/sops-nix";
    };
  };

  home.file = {
    Desktop.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Desktop";
    Dev.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Dev";
    Documents.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Documents";
    Downloads.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Downloads";
    Music.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Music";
    Pictures.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Pictures";
    Public.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Public";
    School.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/School";
    Templates.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Templates";
    Videos.source = config.lib.file.mkOutOfStoreSymlink "/mnt/Data/home/Videos";
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
