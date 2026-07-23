{
  config,
  lib,
  pkgs,
  var,
  ...
}: let
  cfg = config.modules.apps.sway;
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in {
  options.modules.apps.sway.enable =
    lib.mkEnableOption "Enable the Sway compositor.";

  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      extraOptions = ["--unsupported-gpu"];
      wrapperFeatures.gtk = true;
    };

    environment = {
      systemPackages = with pkgs; [
        fuzzel
        mako
        swaylock
        wrappedPkgs.waybar
      ];

      variables.NIXOS_OZONE_WL = "1";

      etc."sway/config".text = ''
        include /etc/sway/config.d/*

        set $mod Mod4
        set $left h
        set $down j
        set $up k
        set $right l
        set $term kitty
        set $menu fuzzel

        exec waybar
        exec mako
        exec swayidle -w \
            timeout 300 'swaylock -f -c 000000' \
            timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
            before-sleep 'swaylock -f -c 000000'

        input * {
          xkb_layout us
        }

        focus_follows_mouse yes
        gaps outer 2
        default_border pixel 2
        floating_modifier $mod normal

        output DP-2 {
          position 0 200
        }

        output DP-3 {
          position 3840 0
          transform 270
        }

        bindsym $mod+Return exec $term
        bindsym $mod+d exec $menu
        bindsym $mod+q kill
        bindsym $mod+Shift+e exit
        bindsym $mod+Shift+c reload

        bindsym $mod+$left focus left
        bindsym $mod+$down focus down
        bindsym $mod+$up focus up
        bindsym $mod+$right focus right
        bindsym $mod+Left focus left
        bindsym $mod+Right focus right
        bindsym $mod+Up focus up
        bindsym $mod+Down focus down

        bindsym $mod+Shift+$left move left
        bindsym $mod+Shift+$down move down
        bindsym $mod+Shift+$up move up
        bindsym $mod+Shift+$right move right
        bindsym $mod+Shift+Left move left
        bindsym $mod+Shift+Down move down
        bindsym $mod+Shift+Up move up
        bindsym $mod+Shift+Right move right

        bindsym $mod+1 workspace number 1
        bindsym $mod+2 workspace number 2
        bindsym $mod+3 workspace number 3
        bindsym $mod+4 workspace number 4
        bindsym $mod+5 workspace number 5
        bindsym $mod+Shift+1 move container to workspace number 1
        bindsym $mod+Shift+2 move container to workspace number 2
        bindsym $mod+Shift+3 move container to workspace number 3
        bindsym $mod+Shift+4 move container to workspace number 4
        bindsym $mod+Shift+5 move container to workspace number 5

        bindsym $mod+b splith
        bindsym $mod+v splitv

        bindsym $mod+s layout stacking
        bindsym $mod+w layout tabbed
        bindsym $mod+e layout toggle split

        bindsym $mod+f fullscreen toggle
        bindsym $mod+Shift+space floating toggle
        bindsym $mod+space focus mode_toggle

        bindsym $mod+a focus parent

        mode "resize" {
          bindsym $left resize shrink width 10px
          bindsym $down resize grow height 10px
          bindsym $up resize shrink height 10px
          bindsym $right resize grow width 10px

          bindsym Left resize shrink width 10px
          bindsym Down resize grow height 10px
          bindsym Up resize shrink height 10px
          bindsym Right resize grow width 10px

          bindsym Return mode "default"
          bindsym Escape mode "default"
        }
        bindsym $mod+r mode "resize"
      '';
    };

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
