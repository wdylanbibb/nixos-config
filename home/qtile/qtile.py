import os

import libqtile.resources
from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen, KeyChord
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"
mod1 = "alt"
mod2 = "control"
home = os.path.expanduser("~")
terminal = guess_terminal()

keys = [
    Key([mod], "h", lazy.layout.left(), desc="Move focus to the left"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to the right"),
    KeyChord([mod], "w", [
        Key([], "j", lazy.layout.next_split().when(layout="screensplit"), lazy.layout.next()),
        Key([], "k", lazy.layout.previous_split().when(layout="screensplit"), lazy.layout.previous()),
    ], mode=True, name="focus"),
    KeyChord([mod], "n", [
        Key([], "h", lazy.layout.grow_left()),
        Key([], "j", lazy.layout.grow_down()),
        Key([], "k", lazy.layout.grow_up()),
        Key([], "l", lazy.layout.grow_right()),
        Key([], "n", lazy.layout.normalize()),
        Key([], "m", lazy.layout.maximize()),
    ], mode=True, name="resize"),
    KeyChord([mod], "m", [
        KeyChord([], "m", [
            Key([], "h", lazy.layout.shuffle_left()),
            Key([], "j", lazy.layout.shuffle_down()),
            Key([], "k", lazy.layout.shuffle_up()),
            Key([], "l", lazy.layout.shuffle_right()),
        ], mode=True, name="move (window)"),
        KeyChord([], "w", [
            Key([], "j", lazy.layout.move_window_to_next_split().when(layout="screensplit")),
            Key([], "k", lazy.layout.move_window_to_previous_split().when(layout="screensplit")),
        ], mode=True, name="move (screensplit)")
    ]),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen on focused window"),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
]

# Screen 1 Groups:
#  - Looking Glass (Max)
#  - Dev (ScreenSplit (RatioTile/MonadThreeCol))
#  - Focus (Max)
#     - Keybind that moves current window to the focus group and moves it back when moving to another group
# Screen 2 Groups:
#  - Discord/Spotify/Youtube/etc. (VerticalTile)
groups = [
    Group(name="1", label="", screen_affinity=0, layout="screensplit"),
    Group(name="2", label="", screen_affinity=0, layout="max", layouts=[layout.Max()], matches=[Match(wm_class="looking-glass-client")]),
    Group(name="3", screen_affinity=0, layout="max", layouts=[layout.Max()]),
    Group(name="4", screen_affinity=1, layout="verticaltile", layouts=[layout.VerticalTile(border_focus=["#7aa2f7", "#bb9af7"], border_normal="#414868", border_width=1)], matches=[Match(wm_class="vesktop"), Match(wm_class="spotify")]),
]

def go_to_group(name: str):
    def _inner(qtile):
        if len(qtile.screens) == 1:
            qtile.groups_map[name].toscreen()
            return
        if name in '123':
            qtile.focus_screen(0)
            qtile.groups_map[name].toscreen()
        else:
            qtile.focus_screen(1)
            qtile.groups_map[name].toscreen()
    return _inner

def go_to_group_and_move_window(name: str):
    def _inner(qtile):
        if len(qtile.screens) == 1:
            qtile.current_window.togroup(name, switch_group=True)
            return
        if name in '123':
            qtile.current_window.togroup(name, switch_group=False)
            qtile.focus_screen(0)
            qtile.groups_map[name].toscreen()
        else:
            qtile.current_window.togroup(name, switch_group=False)
            qtile.focus_screen(1)
            qtile.groups_map[name].toscreen()
    return _inner

for i in groups:
    keys.extend([
        Key([mod], i.name, lazy.function(go_to_group(i.name))),
        Key([mod, "shift"], i.name, lazy.function(go_to_group_and_move_window(i.name)))
    ])

layouts = [
    # layout.MonadThreeCol(new_client_position="bottom", ratio=2/3, border_focus=["#7aa2f7", "#bb9af7"], border_normal="#414868", border_width=1),
    # layout.RatioTile(border_focus=["#7aa2f7", "#bb9af7"], border_normal="#414868", border_width=1),
    # layout.Max(),
    # layout.Floating(),
    layout.ScreenSplit(splits=[
        {"layout": layout.MonadThreeCol(new_client_position="bottom", ratio=2/3, border_focus=["#7aa2f7", "#bb9af7"], border_normal="#414868", border_width=1), "rect": (0, 1/3, 1, 2/3), "name": "bottom"},
        {"layout": layout.RatioTile(border_focus=["#7aa2f7", "#bb9af7"], border_normal="#414868", border_width=1), "rect": (0, 0, 1, 1/3), "name": "top"},
    ])
]

left = ""
right = ""

widget_defaults = dict(
    font="Inter Variable",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()
screens = [
    Screen(
        background="#1a1b26",
        bottom=bar.Bar(
            [
                extra_widget.CurrentLayoutIcon(),
                widget.CurrentLayout(),
                widget.ScreenSplit(),
                widget.GroupBox(
                    font="FontAwesome",
                    highlight_method="text",
                    inactive="#414868",
                    this_current_screen_border="#7aa2f7",
                    visible_groups = ['1', '2']
                ),
                widget.Prompt(),
                widget.WindowName(),
                widget.Spacer(),
                widget.Mpris2(),
                widget.Spacer(),
                widget.Chord(
                    foreground="#ff9e64",
                    name_transform=lambda name: name.upper(),
                ),
                widget.Systray(),
                widget.Clock(format="%Y-%m-%d %a %I:%M %p"),
                widget.QuickExit(),
            ],
            24,
            background = "#1E1E2E",
        ),
    ),
    Screen(
        background="#1a1b26",
    ),

]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
focus_previous_on_window_remove = False
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

idle_inhibitors = []  # type: list

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
