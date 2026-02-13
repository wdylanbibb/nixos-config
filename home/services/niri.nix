{
  lib,
  osConfig,
  pkgs,
  var,
  ...
}:
{
  config = lib.mkIf osConfig.modules.apps.niri.enable {
    # imports = [ var.libInputs.vicinae.homeManagerModules.default ];

    home.packages = with pkgs; [
      swaybg
      cliphist
      wl-clipboard
      wtype
      networkmanagerapplet
      mako
      pamixer
      playerctl
      brightnessctl
      libnotify
      nautilus
      file-roller
      evince
      loupe
      vicinae
    ];

    services.mako = {
      enable = true;
      settings = {
        background-color = "#1E1E2E";
        border-color = "#7aa2f7";
        border-radius = 8;
        border-size = 2;
        default-timeout = 5000;
        font = "MonaspiceAr NF 10";
        icons = true;
        markup = true;
      };
    };

    programs.swaylock = {
      enable = true;
      settings = {
        color = "1E1E2E";
      };
    };

    xdg.configFile."vicinae/settings.json" = {
      text = builtins.toJSON {
        theme.name = "tokyo-night";
      };
    };

    xdg.configFile."niri/config.kdl" = {
      enable = true;
      text = ''
        prefer-no-csd

        environment {
          ELECTRON_OZONE_PLATFORM_HINT "wayland"
          NIXOS_OZONE_WL "1"
        }

        spawn-at-startup "waybar"
        spawn-at-startup "nm-applet"
        spawn-at-startup "vesktop"
        spawn-at-startup "vicinae" "server"

        input {
          keyboard {
            xkb {
              layout "us,us(colemak)"
              options "grp:toggle,caps:ctrl_shifted_capslock"
            }
          }
          touchpad {
            tap
            dwt
            natural-scroll
          }

          warp-mouse-to-focus mode="center-xy"
          focus-follows-mouse max-scroll-amount="0%"
        }

        layout {
          gaps 16
          center-focused-column "never"
          always-center-single-column
          background-color "#1a1b26"
          empty-workspace-above-first

          preset-column-widths {
            proportion 0.33333
            proportion 0.50000
            proportion 0.66667
          }

          default-column-width {
            proportion 0.5;
          }

          border {
            width 2
            active-gradient from="#bb9af7" to="#7aa2f7" angle=45 relative-to="workspace-view"
            inactive-color "#545c7e"
            urgent-color "#ff899d"
          }

          focus-ring {
            off
          }

          shadow {
            on
            softness 30
            spread 5
            offset x=0 y=5
            draw-behind-window false
            color "#0007"
          }
        }

        window-rule {
          match app-id=r#"firefox$"# title="^Picture-in-Picture$"
          open-floating true
        }

        window-rule {
          tiled-state true
          geometry-corner-radius 12
          clip-to-geometry true
          draw-border-with-background false
          opacity 0.95
        }

        binds {
          Mod+Shift+Slash { show-hotkey-overlay; }
          Mod+Tab { spawn "vicinae" "toggle"; }
          Alt+Tab { spawn "vicinae" "vicinae://extensions/vicinae/wm/switch-windows"; }
          Mod+Return { spawn "wezterm"; }
          Super+Alt+L { spawn "swaylock"; }

          XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
          XF86AudioMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
          XF86AudioMicMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

          XF86AudioPrev allow-when-locked=true { spawn-sh "playerctl previous"; }
          XF86AudioPlay allow-when-locked=true { spawn-sh "playerctl play-pause"; }
          XF86AudioNext allow-when-locked=true { spawn-sh "playerctl next"; }

          XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+5%"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "5%-"; }
          
          // Project Launcher
          // Password Manager
          // Screen Recording
          Mod+P     { spawn "nautilus"; }

          // Notification Center
          // Drop down terminal
          XF86AudioMedia { spawn "spotify"; }

          Mod+O repeat=false { toggle-overview; }
          Mod+Q repeat=false { close-window; }

          Mod+Left  { focus-column-left; }
          Mod+Down  { focus-window-down; }
          Mod+Up    { focus-window-up; }
          Mod+Right { focus-column-right; }
          Mod+H     { focus-column-left; }
          Mod+J     { focus-window-or-workspace-down; }
          Mod+K     { focus-window-or-workspace-up; }
          Mod+L     { focus-column-right; }


          Mod+Ctrl+Left  { move-column-left; }
          Mod+Ctrl+Down  { move-window-down; }
          Mod+Ctrl+Up    { move-window-up; }
          Mod+Ctrl+Right { move-column-right; }
          Mod+Ctrl+H     { move-column-left; }
          Mod+Ctrl+J     { move-window-down; }
          Mod+Ctrl+K     { move-window-up; }
          Mod+Ctrl+L     { move-column-right; }

          Mod+U { focus-workspace-down; }
          Mod+I { focus-workspace-up; }
          Mod+Ctrl+U { move-column-to-workspace-down; }
          Mod+Ctrl+I { move-column-to-workspace-up; }
          Mod+Shift+U { move-workspace-down; }
          Mod+Shift+I { move-workspace-up; }

          Mod+BracketLeft { consume-or-expel-window-left; }
          Mod+BracketRight { consume-or-expel-window-right; }

          Mod+Comma { consume-window-into-column; }
          Mod+Period { expel-window-from-column; }

          Mod+R { switch-preset-column-width; }
          Mod+Shift+R { switch-preset-window-height; }
          Mod+Ctrl+R { reset-window-height; }
          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }

          Mod+Ctrl+F { expand-column-to-available-width; }

          Mod+Ctrl+C { center-visible-columns; }

          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }

          Mod+Shift+Minus { set-window-height "-10%"; }
          Mod+Shift+Equal { set-window-height "+10%"; }

          Mod+W { toggle-column-tabbed-display; }

          Mod+C repeat=false { spawn-sh "wtype -k XF86Copy"; }
          Mod+V repeat=false { spawn-sh "wtype -k XF86Paste"; }

          Print { screenshot; }
          Ctrl+Print { screenshot-screen; }
          Alt+Print { screenshot-window; }

          Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

          Mod+Shift+E { quit; }
          Ctrl+Alt+Delete { quit; }

          Mod+Shift+P { power-off-monitors; }
        }
      '';
    };
  };
}
