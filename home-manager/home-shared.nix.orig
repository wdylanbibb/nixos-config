{ config, osConfig, pkgs, inputs, lib, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home.username = "dylan";
  home.homeDirectory = "/home/dylan";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

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
<<<<<<< HEAD
    git-extras
=======
>>>>>>> 9dfd325c081feeb17fac1ed5eedd77b5c04582fd

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
  ];

  programs.git = {
    enable = true;
    userName = "Dylan Bibb";
    userEmail = "wdylanbibb@gmail.com";
    delta = {
      enable = true;
      options = {
<<<<<<< HEAD
        side-by-side = true;
=======
        "side-by-side" = true;
>>>>>>> 9dfd325c081feeb17fac1ed5eedd77b5c04582fd
      };
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git.paging = {
        colorArg = "always";
<<<<<<< HEAD
        pager = "delta --paging=never -s";
=======
        pager = "delta --paging=never";
>>>>>>> 9dfd325c081feeb17fac1ed5eedd77b5c04582fd
      };
    };
  };

  programs.firefox = {
    enable = true;
  };

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
  xdg.configFile."zellij/layouts/nix_config.kdl" = {
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
            "pane split_direction=\"Horizontal\"" = {
              "pane split_direction=\"Vertical\" command=\"nvim\"" = {
                args = [ "flake.nix" ];
              };
              "pane size=\"15%\" command=\"sudo\"" = {
                args = [ "nixos-rebuild" "--flake" ".#${osConfig.networking.hostName}" "switch" ];
              };
            };
            "pane size=\"15%\"".plugin._props.location = "zellij:strider";
          };
        };
      };
    };
  };
<<<<<<< HEAD
=======
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
>>>>>>> 9dfd325c081feeb17fac1ed5eedd77b5c04582fd
  

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
      plugins = [
        "ssh-agent"
        "git"
      	"thefuck"
      	"aliases"
      	"alias-finder"
      	"eza"
      	"rsync"
      	"ssh"
      	"vi-mode"
      	"zsh-interactive-cd"
      	"rust"
      ];
    };
    # Seems like a bad idea...
    # shellAliases = {
    #   home-manager = "home-manager --flake $(readlink /etc/nixos)#$(whoami)@$(hostname)";
    #   nixos-rebuild = "nixos-rebuild --flake $(readlink /etc/nixos)#$(whoami)@$(hostname)";
    # };
  };

  programs.vim = {
    enable = true;
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host ilab
        Hostname ilab.cs.rutgers.edu
        User wdb46
    '';
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
