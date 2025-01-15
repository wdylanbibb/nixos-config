{ config, lib, pkgs, input, ... }:
{
  services.polybar = {
    script = ''
      killall -q polybar

      echo "---" | tee -a /tmp/polybar1.log
      polybar example 2>&1 | tee -a /tmp/polybar1.log &

      echo "Bars launched..."
      '';

    settings = {
      "colors" = {
        background = "#000000";
        background-alt = "#181818";
        foreground = "#cccccc";
        primary = "#ffdd33";
        secondary = "#96a6c8";
        alert = "#c73c3f";
        disabled = "#333333";
      };

      "bar/example" = {
        width = "100%";
        height = "24pt";
        radius = "0";

        background = "\${colors.background}";
        foreground = "\${colors.foreground}";

        line-size = "3pt";

        border-size = "4pt";
        border-color = "#000000";

        padding-left = "0";
        padding-right = "1";

        module-margin = "1";

        separator = "|";
        separator-foreground = "\${colors.disabled}";

        font-0 = "CozetteHiDpi";
        font-1 = "CozetteHiDpi";

        modules-left = "xworkspaces xwindow";
        modules-right = "filesystem pulseaudio xkeyboard memory cpu wlan eth date";

        cursor-click = "pointer";
        cursor-scroll = "ns-resize";

        enable-ipc = "true";
      };

      "module/systray" = {
        type = "internal/tray";

        format-margin = "8pt";
        tray-spacing = "16pt";
      };

      "module/xworkspaces" = {
        type = "internal/workspaces";

        label-active = "%name%";
        label-active-background = "\${colors.background-alt}";
        label-active-underline = "\${colors.primary}";
        label-active-padding = "1";

        label-occupied = "%name%";
        label-occupied-padding = "1";

        label-urgent = "%name%";
        label-urgent-background = "\${colors.alert}";
        label-urgent-padding = "1";

        label-empty = "%name%";
        label-empty-foreground = "\${colors.disabled}";
        label-empty-padding = "1";
      };

      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:60:...%";
      };

      "module/filesystem" = {
        type = "internal/fs";
        interval = "25";

        mount-0 = "/";

        label-mounted = "%{F#F0C674}%mountpoint%%{F-} %percentage_used%%";

        label-unmounted = "%mountpoint% not mounted";
        label-unmounted-foreground = "\${colors.disabled}";
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";

        format-volume-prefix = "VOL ";
        format-volume-prefix-foreground = "\${colors.primary}";
        format-volume = "<label-volume>";

        label-volume = "%percentage%%";

        label-muted = "muted";
        label-muted-foreground = "\${colors.disabled}";
      };

      "module/xkeyboard" = {
        type = "internal/xkeyboard";
        blacklist-0 = "num lock";

        label-layout = "%layout%";
        label-layout-foreground = "\${colors.primary}";

        label-indicator-padding = "2";
        label-indicator-margin = "1";
        label-indicator-foreground = "\${colors.background}";
        label-indicator-background = "\${colors.secondary}";
      };

      "module/memeory" = {
        type = "internal/memory";
        interval = "2";
        format-prefix = "RAM ";
        format-prefix-foreground = "\${colors.primary}";
        label = "%percentage_used:2%%";
      };

      "module/cpu" = {
        type = "internal/cpu";
        interval = "2";
        format-prefix = "CPU ";
        format-prefix-foreground = "\${colors.primary}";
        label = "%percentage:2%%";
      };

      "network-base" = {
        type = "internal/network";
        interval = "5";
        format-connected = "<label-connected>";
        format-disconnected = "<label-disconnected>";
        label-disconnected = "%{F#F0C674}%ifname%%{F#707880} disconnected";
      };

      "module/wlan" = {
        "inherit" = "network-base";
        interface-type = "wireless";
        label-connected = "%{F#F0C674}%ifname%%{F-} %essid% %local_ip%";
      };

      "module/eth" = {
        "inherit" = "network-base";
        interface-type = "wired";
        label-connected = "%{F#F0C674}%ifname%%{F-} %local_ip%";
      };

      "module/date" = {
        type = "internal/date";
        interval = "1";

        date = "%H:%M";
        date-alt = "%Y-%m-%d %H:%M:%S";

        label = "%date%";
        label-foreground = "\${colors.primary}";
      };

      "settings" = {
        screenchange-reload = "true";
        pseudo-transparency = "true";
      };
    };
  };
}
