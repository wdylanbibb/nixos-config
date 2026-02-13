{
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf osConfig.modules.apps.niri.enable {
    programs.waybar = {
      enable = true;
      settings.mainBar = {
        reload_style_on_change = true;
        toggle = true;
        layer = "top";
        position = "top";
        modules-left = [
          "custom/cachy"
          "clock"
          "niri/workspaces"
        ];
        modules-center = [
          "niri/window"
        ];
        modules-right = [
          "group/extras"
          "pulseaudio#microphone"
          "group/audio"
          # "group/brightness"
          "battery"
          "niri/language"
        ];

        "group/extras" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 400;
            children-class = "extras";
            transition-left-to-right = true;
          };
          modules = [
            "custom/menu"
            "tray"
            "mpris"
            # "bluetooth"
            "custom/tailscale"
            "custom/clipboard"
          ];
        };
        "group/brightness" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 400;
            children-class = "brightness";
            transition-left-to-right = true;
          };
          modules = [
            "backlight"
            "backlight/slider"
          ];
        };
        "group/audio" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 400;
            children-class = "audio";
            transition-left-to-right = false;
          };
          modules = [
            "pulseaudio"
            "pulseaudio/slider"
          ];
        };

        "custom/cachy" = {
          format = "";
          tooltip = false;
          on-click = "wezterm";
        };
        "niri/workspaces" = {
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            default = "󰄰";
            active = "󰄯";
          };
        };
        "niri/window" = {
          "format" = "{}";
          "empty-format" = "";
          "rewrite" = {
            "(.*) - YouTube — Mozilla Firefox" = "󰗃 $1";
            "(.*) — Mozilla Firefox" = "󰖟 $1";
          };
        };
        cpu = {
          format = "{icon}";
          format-icons = [
            "󰝦"
            "󰪞"
            "󰪟"
            "󰪠"
            "󰪡"
            "󰪢"
            "󰪣"
            "󰪤"
            "󰪥"
          ];
          interval = 1;
          tooltip = true;
          tooltip-format = "CPU Frequency: {avg_frequency} GHz";
          on-click = "foot btop";
        };
        "custom/clipboard" = {
          format = "";
          tooltip = true;
          tooltip-format = "View Clipboard History";
          on-click = "vicinae vicinae://extensions/vicinae/clipboard/history";
        };
        clock = {
          interval = 1;
          format = "{:%I:%M %p}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b>{}</b></span>";
            };
          };
          actions = {
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
        mpris = {
          format = "{player_icon}";
          format-paused = "{status_icon}";
          tooltip-format = "{player_icon} {title} - {artist}";
          tooltip-format-paused = "{status_icon} {title} - {artist}";
          player-icons.default = "";
          status-icons = {
            paused = "";
            playing = "";
            stopped = "";
          };
          on-click-right = "";
          menu = "on-click-right";
          menu-file = "${pkgs.writeTextFile {
            name = "waybar-mpris-menu.xml";
            text = ''
              <?xml version="1.0" encoding="UTF-8"?>
              <interface>
                <object class="GtkMenu" id="menu">
                  <child>
                    <object class="GtkMenuItem" id="next">
                      <property name="label">Next</property>
                    </object>
                  </child>
                  <child>
                    <object class="GtkSeparatorMenuItem" id="delimeter1" />
                  </child>
                  <child>
                    <object class="GtkMenuItem" id="previous">
                      <property name="label">Previous</property>
                    </object>
                  </child>
                </object>
              </interface>
            '';
          }}";
          menu-actions = {
            next = "playerctl next";
            previous = "playerctl previous";
          };
        };
        "custom/menu" = {
          format = "<span size='14pt'>󰅃</span>";
          rotate = 90;
          tooltip = false;
        };
        tray = {
          spacing = 2;
          reverse-direction = true;
          icon-size = 15;
          show-passive-items = false;
        };
        "custom/tailscale" = {
          # on-click = ./scripts/waybar-tailscale/waybar-tailscale-toggle.sh;
          exec = "${pkgs.writeTextFile {
            name = "waybar-tailscale-status.sh";
            executable = true;
            text = ''
              #!/usr/bin/env bash

              STATUS_KEY="BackendState"
              RUNNING="Running"

              status="$(tailscale status --json | jq -r '.'$STATUS_KEY)"
              if [ "$status" = $RUNNING ]; then
                T=''${2:-"green"}
                F=''${3:-"red"}

                peers=$(tailscale status --json | jq -r --arg T "'$T'" --arg F "'$F'" '.Peer[] | ("<span color=" + (if .Online then $T else $F end) + ">" + (.DNSName | split(".")[0]) + "</span>")' | sed ':a;N;$!ba;s/\n/\\n/g')
                exitnode=$(tailscale status --json | jq -r '.Peer[] | select(.ExitNode == true).DNSName | split(".")[0]')
                echo "{\"text\":\"''${exitnode}\",\"class\":\"connected\",\"alt\":\"connected\",\"tooltip\":\"''${peers}\"}"

              else
                echo "{\"text\":\"\",\"class\":\"stopped\",\"alt\":\"stopped\",\"tooltip\":\"The VPN is not active.\"}"
              fi
            '';
          }}";
          exec-on-event = true;
          format = "{icon}";
          format-icons = {
            connected = "";
            stopped = "";
          };
          tooltip = true;
          return-type = "json";
          interval = 1;
          signal = 1;
        };
        network = {
          format-icons = {
            wifi = [
              "<span size='12pt'>󰤯</span>"
              "<span size='12pt'>󰤟</span>"
              "<span size='12pt'>󰤢</span>"
              "<span size='12pt'>󰤥</span>"
              "<span size='12pt'>󰤨</span>"
            ];
            ethernet = "<span size='12pt'>󰈀</span>";
            disabled = "<span size='12pt'>󰤭</span>";
            disconnected = "<span size='12pt'>󰤩</span>";
          };
          format-wifi = "{icon}";
          format-ethernet = "{icon}";
          format-disconnected = "{icon}";
          format-disabled = "{icon}";
          interval = 5;
          tooltip-format = "{essid}\t{gwaddr}";
          # on-click = "rfkill toggle wifi";
          # on-click-right = "nm-connection-editor";
          tooltip = true;
          max-length = 20;
        };
        bluetooth = {
          interval = 5;
          format-on = "<span size='12pt'>󰂯</span>";
          format-off = "<span size='12pt'>󰂲</span>";
          format-disabled = "<span size='12pt'>󰂲</span>";
          format-connected = "<span size='12pt'>󰂱</span>";
          tooltip = true;
          tooltip-format = "{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_address} | Battery: {device_battery_percentage}%";
          on-click = "blueman-manager";
          on-click-right = "rfkill toggle bluetooth";
        };
        "pulseaudio#microphone" = {
          format = "{format_source}";
          format-source = "<span size='12pt'>󰍬</span>";
          format-source-muted = "<span size='12pt'>󰍭</span>";
          on-click = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          tooltip = false;
        };
        "pulseaudio/slider" = {
          min = 0;
          max = 100;
          orientation = "horizontal";
        };
        pulseaudio = {
          interval = 1;
          format = "{icon}";
          format-icons = [
            "<span size='12pt'>󰕿</span>"
            "<span size='12pt'>󰖀</span>"
            "<span size='12pt'>󰕾</span>"
          ];
          format-muted = "<span size='12pt'>󰝟</span>";
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          on-click-right = "pavucontrol";
          reverse-scrolling = true;
          tooltip = true;
          tooltip-format = "Volume: {volume}%\n{desc}";
          ignored-sinks = [ "Easy Effects Sink" ];
        };
        "backlight/slider" = {
          min = 0;
          max = 100;
          orientation = "horizontal";
          device = "intel_backlight";
        };
        backlight = {
          device = "intel_backlight";
          format = "{icon}";
          format-icons = [
            "󰃚"
            "󰃛"
            "󰃜"
            "󰃝"
            "󰃞"
            "󰃟"
            "󰃠"
          ];
          reverse-scrolling = true;
          smooth-scrolling-threshold = 0.2;
          tooltip = false;
        };
        battery = {
          interval = 5;
          states = {
            critical = 20;
          };
          format = "{icon}";
          format-icons = [
            "<span size='12pt'>󰁺</span>"
            "<span size='12pt'>󰁻</span>"
            "<span size='12pt'>󰁼</span>"
            "<span size='12pt'>󰁽</span>"
            "<span size='12pt'>󰁾</span>"
            "<span size='12pt'>󰁿</span>"
            "<span size='12pt'>󰂀</span>"
            "<span size='12pt'>󰂁</span>"
            "<span size='12pt'>󰂂</span>"
            "<span size='12pt'>󰁹</span>"
          ];
          format-charging = "<span size='12pt'>󰂄</span>";
          format-plugged = "<span size='12pt'>󰚥</span>";
          format-critical = "<span size='12pt'>󰂃</span>";
          tooltip = true;
          tooltip-format = "Charge: {capacity}%";
          tooltip-format-charging = "Charging: {capacity}%";
        };
      };
      style = ''
        @define-color cursor #CDD6F4;
        @define-color background #1E1E2E;
        @define-color foreground #CDD6F4;
        @define-color color0  #45475A;
        @define-color color1  #F38BA8;
        @define-color color2  #A6E3A1;
        @define-color color3  #F9E2AF;
        @define-color color4  #89B4FA;
        @define-color color5  #F5C2E7;
        @define-color color6  #94E2D5;
        @define-color color7  #BAC2DE;
        @define-color color8  #585B70;
        @define-color color9  #F38BA8;
        @define-color color10 #A6E3A1;
        @define-color color11 #F9E2AF;
        @define-color color12 #89B4FA;
        @define-color color13 #F5C2E7;
        @define-color color14 #94E2D5;
        @define-color color15 #A6ADC8;

        * {
          font-family: "MonaspiceAr NF";
          font-size: 14;
          border-radius: 0;
          box-shadow: none;
        }

        window#waybar {
          background: @background;
        }

        .modules-right {
          margin-top: -8px;
          margin-bottom: -8px;
        }

        .modules-center {
          margin-top: -8px;
          margin-bottom: -8px;
        }

        .modules-left {
          margin-top: -8px;
          margin-bottom: -8px;
        }

        #custom-cachy:hover,
        #cpu:hover,
        #custom-clipboard:hover,
        #network:hover,
        #mpris:hover,
        #custom-tailscale:hover,
        #bluetooth:hover,
        #pulseaudio:hover,
        #pulseaudio.microphone:hover,
        #pulseaudio.sink-muted:hover {
          opacity: 0.5;
        }

        #custom-cachy,
        #cpu,
        #clock,
        #mpris,
        #custom-menu,
        #tray,
        #network,
        #custom-tailscale,
        #bluetooth,
        #pulseaudio,
        #pulseaudio.microphone,
        #backlight,
        #language,
        #battery {
          padding-left: 6px;
          padding-right: 6px;
        }

        #custom-clipboard {
          padding-left: 6px;
          padding-right: 10px;
        }

        #custom-cachy,
        #cpu,
        #custom-clipboard,
        #clock,
        #mpris,
        #custom-menu,
        #tray,
        #network,
        #custom-tailscale,
        #bluetooth,
        #backlight {
          color: @foreground;
        }

        #language,
        #battery,
        #pulseaudio,
        #pulseaudio.microphone {
          color: @background;
        }

        #custom-menu,
        #tray,
        #mpris,
        #bluetooth,
        #cpu,
        #custom-tailscale,
        #custom-clipboard {
          background: #12121c;
        }

        #custom-menu {
          border-radius: 40px 0 0 40px;
        }

        #workspaces button {
          color: @foreground;
          padding: 0;
        }
        #workspaces button.active {
          color: @color2;
        }

        #clock {
          color: @color4;
        }

        /* #mpris { */
        /*   color: @color3; */
        /* } */

        #network.disabled {
          color: @color1;
        }
        #network.wifi {
          color: @color2;
        }
        #network.ethernet {
          color: @color3;
        }

        #custom-tailscale.stopped {
          opacity: 0.5;
        }

        #bluetooth.disabled {
          color: @color1;
        }
        #bluetooth.connected {
          color: @color4;
        }

        /* #pulseaudio.sink-muted:not(.microphone) { */
        /*   color: @color3; */
        /* } */
        /* #pulseaudio.microphone.source-muted { */
        /*   color: @color1; */
        /* } */

        /* #battery.plugged { */
        /*   color: @color4; */
        /* } */
        /* #battery.charging { */
        /*   color: @color2; */
        /* } */
        /* #battery.critical { */
        /*   color: @color3; */
        /* } */

        #language {
          background: @color4;
        }

        #battery {
          background: @color2;
        }

        #pulseaudio {
          background: @color3;
        }

        #pulseaudio.microphone {
          background: @color1;
        }

        tooltip {
          background: @background;
          border: 1px solid @foreground;
          border-radius: 8px;
        }
        tooltip * {
          color: @foreground;
          margin: 2px;
          background: @background;
        }

        #pulseaudio-slider,
        #backlight-slider {
          background: @color3;
        }

        #pulseaudio-slider slider,
        #backlight-slider slider {
          background: transparent;
        }

        #pulseaudio-slider trough,
        #backlight-slider trough {
          min-width: 90px;
          min-height: 10px;
          border-radius: 8px;
          background: @background;
        }

        #pulseaudio-slider highlight {
          border-radius: 8px;
          background: @color4;
        }
        #backlight-slider highlight {
          border-radius: 8px;
          background: @color3;
        }

        menu {
          background: @background;
          border: 1px solid @foreground;
          border-radius: 8px;
        }
        menuitem {
          border-radius: 8px;
        }
      '';
    };
  };
}
