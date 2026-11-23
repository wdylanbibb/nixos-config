{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.apps.sway;
  swayConfig = pkgs.writeText "sway-noctalia.conf" ''
    set $mod Mod4
    set $left h
    set $down j
    set $up k
    set $right l
    set $term kitty

    set $tokyonight_bg #1a1b26
    set $tokyonight_bg_highlight #292e42
    set $tokyonight_border #3b4261
    set $tokyonight_fg #c0caf5
    set $tokyonight_fg_dark #565f89
    set $tokyonight_blue #7aa2f7
    set $tokyonight_yellow #e0af68
    set $tokyonight_red #f7768e

    client.focused          $tokyonight_blue          $tokyonight_blue            $tokyonight_bg         $tokyonight_yellow $tokyonight_blue
    client.focused_inactive $tokyonight_border        $tokyonight_bg_highlight    $tokyonight_fg         $tokyonight_border $tokyonight_border
    client.unfocused        $tokyonight_bg_highlight  $tokyonight_bg              $tokyonight_fg_dark    $tokyonight_bg_highlight $tokyonight_bg_highlight
    client.urgent           $tokyonight_red           $tokyonight_red             $tokyonight_bg         $tokyonight_red $tokyonight_red
    client.placeholder      $tokyonight_yellow        $tokyonight_bg_highlight    $tokyonight_fg         $tokyonight_yellow $tokyonight_yellow
    client.background       $tokyonight_bg

    font pango:monospace 8
    floating_modifier $mod
    focus_follows_mouse yes
    gaps outer 5
    default_border pixel 2

    # Import the compositor environment before starting the Noctalia shell.
    exec "systemctl --user import-environment WAYLAND_DISPLAY DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE; systemctl --user start sway-shell.target"

    # Noctalia is the desktop shell: bar, wallpaper, launcher, notifications,
    # control center, settings, and session controls.
    bindsym $mod+d exec noctalia msg panel-toggle launcher
    bindsym $mod+Tab exec noctalia msg panel-toggle launcher
    bindsym $mod+Shift+s exec noctalia msg settings-toggle
    bindsym $mod+Shift+e exec noctalia msg panel-toggle session
    bindsym XF86AudioMedia exec noctalia msg panel-toggle control-center media

    bindsym $mod+Return exec $term
    bindsym $mod+p exec nautilus
    bindsym $mod+q kill
    bindsym $mod+Shift+c reload
    bindsym $mod+Shift+r restart

    bindsym XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+
    bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-
    bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindsym XF86AudioMicMute exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    bindsym XF86AudioPrev exec playerctl previous
    bindsym XF86AudioPlay exec playerctl play-pause
    bindsym XF86AudioNext exec playerctl next
    bindsym XF86MonBrightnessUp exec brightnessctl --class=backlight set +5%
    bindsym XF86MonBrightnessDown exec brightnessctl --class=backlight set 5%-

    bindsym $mod+$left focus left
    bindsym $mod+$down focus down
    bindsym $mod+$up focus up
    bindsym $mod+$right focus right
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

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
      bindsym $left resize shrink width 10 px or 10 ppt
      bindsym $down resize grow height 10 px or 10 ppt
      bindsym $up resize shrink height 10 px or 10 ppt
      bindsym $right resize grow width 10 px or 10 ppt
      bindsym Left resize shrink width 10 px or 10 ppt
      bindsym Down resize grow height 10 px or 10 ppt
      bindsym Up resize shrink height 10 px or 10 ppt
      bindsym Right resize grow width 10 px or 10 ppt
      bindsym Return mode "default"
      bindsym Escape mode "default"
    }
    bindsym $mod+r mode "resize"

    include /etc/sway/config.d/*

    # Physical output layout belongs to the host, not the desktop profile.
    ${cfg.extraConfig}
  '';
in {
  options.modules.apps.sway = {
    enable = lib.mkEnableOption "Enable Sway with the Noctalia desktop shell";
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Host-specific Sway configuration appended to the shared configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      extraOptions = ["--config" "${swayConfig}"];
      extraPackages = with pkgs; [
        brightnessctl
        nautilus
        playerctl
        wl-clipboard
        xwayland-satellite
      ];
    };

    environment.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      NIXOS_OZONE_WL = "1";
    };

    # Wayland applications use this portal to capture Sway outputs via PipeWire.
    # Use slurp explicitly so multi-monitor selection does not depend on xdpw's
    # optional launcher auto-detection.
    xdg.portal.wlr = {
      enable = true;
      settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or";
        # Allocate linear DMA-BUFs when the consumer doesn't negotiate an
        # explicit modifier (consumers that do, like Chromium, bypass this).
        # xdpw only treats the literal "1" as true; the INI generator would
        # render Nix `true` as "true", which xdpw silently parses as false.
        force_mod_linear = 1;
        max_fps = 60;
      };
    };

    systemd.user.targets.sway-shell = {
      description = "Desktop shell services for the Sway session";
      bindsTo = ["sway-session.target"];
      after = ["sway-session.target"];
    };
  };
}
