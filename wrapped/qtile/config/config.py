import os
import subprocess

import libqtile.resources
from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen, KeyChord
from libqtile.lazy import lazy

from qtile_extras import widget as extra_widget

from finder import Finder

mod = "mod4"
mod1 = "alt"
mod2 = "control"
home = os.path.expanduser("~")
terminal = "kitty"
edge_tolerance = 2
wallpaper_dir = os.environ.get(
    "QTILE_WALLPAPER_DIR",
    os.path.join(os.path.dirname(__file__), "wallpapers"),
)
screen_0_wallpaper = os.path.join(wallpaper_dir, "5yFVyfC.png")
screen_0_background_title = "qtile-screen-0-atop-background"
screen_0_background_command = ["retro-cool-term-atop", "-T", screen_0_background_title]
screen_0_background_pid = None
# screenshot_command = "maim -su | satty --filename - --output-filename - --early-exit --action-on-escape save-to-file | magick - \\( +clone -background black -shadow 80x3+10+10 \\) +swap -background none -layers merge +repage - | xclip -selection clipboard -target image/png -in"
screenshot_command = "maim -su | xclip -selection clipboard -t image/png"

def bordering_screen(qtile, step):
    current = qtile.current_screen
    current_left = current.x
    current_right = current.x + current.width

    def overlaps_vertically(screen):
        return screen.y < current.y + current.height and current.y < screen.y + screen.height

    if step < 0:
        candidates = [
            screen
            for screen in qtile.screens
            if screen is not current and overlaps_vertically(screen) and screen.x + screen.width <= current_left
        ]
        return max(candidates, key=lambda screen: screen.x + screen.width, default=None)

    candidates = [
        screen
        for screen in qtile.screens
        if screen is not current and overlaps_vertically(screen) and screen.x >= current_right
    ]
    return min(candidates, key=lambda screen: screen.x, default=None)

def windows_for_direction(qtile):
    current_layout = qtile.current_group.current_layout
    if current_layout.name == "screensplit":
        return current_layout.active_layout.get_windows()
    return current_layout.get_windows()

def directional_target(qtile, axis, step):
    current_window = qtile.current_group.current_window
    if current_window is None:
        return None

    current_center = (
        current_window.x + current_window.width / 2,
        current_window.y + current_window.height / 2,
    )

    candidates = []
    for win in windows_for_direction(qtile):
        if win is current_window:
            continue

        center = (win.x + win.width / 2, win.y + win.height / 2)
        primary_delta = center[axis] - current_center[axis]
        if primary_delta * step <= 0:
            continue

        secondary_delta = abs(center[1 - axis] - current_center[1 - axis])
        candidates.append((abs(primary_delta), secondary_delta, win))

    if not candidates:
        return None

    return min(candidates, key=lambda item: (item[0], item[1]))[2]

def focus_direction(axis, step):
    def _inner(qtile):
        current_window = qtile.current_group.current_window
        current_screen = qtile.current_screen
        current_layout = qtile.current_group.current_layout

        target = directional_target(qtile, axis, step)
        if target is not None:
            qtile.current_group.focus(target, True)
            return

        if axis == 0 and current_window is not None:
            if step < 0:
                at_edge = current_window.x <= current_screen.x + edge_tolerance
            else:
                at_edge = (
                    current_window.x + current_window.width
                    >= current_screen.x + current_screen.width - edge_tolerance
                )

            screen = bordering_screen(qtile, step) if at_edge else None
            if screen is not None:
                qtile.focus_screen(qtile.screens.index(screen), warp=False)
                return

        if axis != 1 or current_layout.name != "screensplit":
            return

        if step > 0:
            current_layout.next_split()
            target = current_layout.active_layout.focus_first()
        else:
            current_layout.previous_split()
            target = current_layout.active_layout.focus_last()

        if target is not None:
            qtile.current_group.focus(target, True)
    return _inner

def move_split_or_shuffle(step):
    def _inner(qtile):
        current_layout = qtile.current_group.current_layout
        if current_layout.name == "screensplit":
            if step > 0:
                current_layout.move_window_to_next_split()
            else:
                current_layout.move_window_to_previous_split()
            return

        shuffle = getattr(current_layout, "shuffle_down" if step > 0 else "shuffle_up", None)
        if shuffle is not None:
            shuffle()
    return _inner

def toggle_finder(qtile):
    current_layout = qtile.current_group.current_layout
    if isinstance(current_layout, Finder):
        current_layout.toggle_window_list()
        return

    for index, candidate in enumerate(qtile.current_group.layouts):
        if isinstance(candidate, Finder):
            qtile.current_group.use_layout(index)
            candidate.show_window_list()
            return

def hide_finder(qtile):
    current_layout = qtile.current_group.current_layout
    if isinstance(current_layout, Finder):
        current_layout.hide_window_list()

keys = [
    Key([mod], "h", lazy.layout.left(), desc="Move focus to the left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to the right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
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
    Key([mod, "shift"], "h", lazy.layout.shuffle_left()),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right()),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up()),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen on focused window"),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    # Key([mod], "space", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "Tab", lazy.layout.toggle_window_list(), desc="Toggle window finder"),
    # Key([mod], "Escape", lazy.function(hide_finder), desc="Hide window finder"),
    Key([], "Print", lazy.spawn(screenshot_command, shell=True), desc="Take a screenshot"),
]

finder_layout_config = dict(
    bg_color="#d8cbc4",
    foreground="#180e13",
    font="Eurostile Extended",
    fontsize=144,
    sections=["Default"],
)

groups = [
    Group(name="1", screen_affinity=0, layout="screensplit"),
    Group(name="2", screen_affinity=0, layout="finder", layouts=[Finder(**finder_layout_config)]),
    Group(name="v", screen_affinity=0, layout="max", layouts=[layout.Max()], matches=[Match(wm_class="looking-glass-client")]),
    Group(name="4", screen_affinity=1, layout="verticaltile", layouts=[layout.VerticalTile(border_focus="#FFFFFF", border_normal="#000000", border_width=4)], matches=[Match(wm_class="vesktop"), Match(wm_class="spotify")]),
]

def focus_group(name: str, screen_index: int | None = None):
    group = qtile.groups_map[name]
    if len(qtile.screens) == 1:
        group.toscreen()
        return
    if screen_index is None:
        screen_index = group.screen_affinity if group.screen_affinity is not None else 0
    screen_index = min(screen_index, len(qtile.screens) - 1)
    qtile.focus_screen(screen_index, warp=False)
    if group.screen is not qtile.current_screen:
        group.toscreen()

def go_to_group(name: str):
    def _inner(qtile):
        focus_group(name)
    return _inner

def go_to_group_and_move_window(name: str):
    def _inner(qtile):
        group = qtile.groups_map[name]
        if len(qtile.screens) == 1:
            qtile.current_window.togroup(name, switch_group=True)
            return
        qtile.current_window.togroup(name, switch_group=False)
        qtile.focus_screen(group.screen_affinity if group.screen_affinity is not None else 0)
        group.toscreen()
    return _inner

def is_screen_0_background(window):
    if getattr(window, "_is_screen_0_background", False):
        return True

    if getattr(window, "name", None) == screen_0_background_title:
        window._is_screen_0_background = True
        return True

    if screen_0_background_pid is None:
        return False

    try:
        pid = window.get_pid()
    except Exception:
        return False

    if pid == screen_0_background_pid:
        window._is_screen_0_background = True
        return True

    return False

def screen_0_background_rect():
    screen = qtile.screens[0]
    return screen.get_rect()

def send_screen_0_background_to_bottom(window):
    if not is_screen_0_background(window):
        return

    if hasattr(window, "can_steal_focus"):
        window.can_steal_focus = False

    if len(qtile.screens) > 0 and getattr(window, "group", None) is not None:
        rect = screen_0_background_rect()
        window.static(0, rect.x, rect.y, rect.width, rect.height)
        return

    if len(qtile.screens) > 0 and hasattr(window, "place"):
        rect = screen_0_background_rect()
        window.place(rect.x, rect.y, rect.width, rect.height, 0, "#000000")

    if hasattr(window, "keep_below"):
        window.keep_below(True)

def refocus_current_group():
    win = qtile.current_group.current_window
    if win is not None and not is_screen_0_background(win):
        qtile.current_group.focus(win, warp=False, force=True)
        return
    qtile.core.clear_focus()

for i in groups:
    keys.extend([
        Key([mod], i.name, lazy.function(go_to_group(i.name))),
        Key([mod, "shift"], i.name, lazy.function(go_to_group_and_move_window(i.name)))
    ])

layouts = [
    layout.ScreenSplit(splits=[
        {"layout": layout.MonadThreeCol(new_client_position="bottom", ratio=2/3, border_focus="#FFFFFF", border_normal="#000000", border_width=4), "rect": (0, 1/3, 1, 2/3), "name": "bottom"},
        {"layout": layout.RatioTile(border_focus=["#7aa2f7", "#bb9af7"], border_normal="#414868", border_width=1), "rect": (0, 0, 1, 1/3), "name": "top"},
    ]),
    Finder(**finder_layout_config),
]

left = ""
right = ""

@hook.subscribe.startup_once
def set_root_cursor():
    global screen_0_background_pid
    qtile.spawn("xsetroot -cursor_name left_ptr")
    qtile.spawn("looking-glass-client -F")
    qtile.spawn("vesktop")
    qtile.spawn("spotify")
    log = open("/tmp/retro-cool-term-atop.log", "ab")
    screen_0_background_pid = subprocess.Popen(
        screen_0_background_command,
        stdout=log,
        stderr=subprocess.STDOUT,
    ).pid

@hook.subscribe.client_managed
def manage_screen_0_background(window):
    send_screen_0_background_to_bottom(window)
    qtile.call_later(0.5, send_screen_0_background_to_bottom, window)

@hook.subscribe.client_name_updated
def manage_renamed_screen_0_background(window):
    send_screen_0_background_to_bottom(window)

@hook.subscribe.client_focus
def keep_screen_0_background_unfocused(window):
    if is_screen_0_background(window):
        send_screen_0_background_to_bottom(window)
        refocus_current_group()

@hook.subscribe.client_mouse_enter
def ignore_screen_0_background_mouse_enter(window):
    if is_screen_0_background(window):
        send_screen_0_background_to_bottom(window)
        refocus_current_group()

widget_defaults = dict(
    font="Univers67CondensedBold",
    fontsize=24,
    padding=3,
    foreground="#20181d",
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        background="#1a1b26",
        left=bar.Gap(2),
        right=bar.Gap(2),
        bottom=bar.Bar(
            [
                widget.GroupBox(
                    highlight_method="text",
                    inactive="#FFFFFF",
                    this_current_screen_border="#000000",
                    visible_groups = ['1', '2']
                ),
                widget.Prompt(),
                widget.WindowName(),
                widget.Spacer(),
                widget.Mpris2(),
                widget.Spacer(),
                widget.Systray(),
                widget.Clock(format="%Y-%m-%d %a %I:%M %p"),
                widget.QuickExit(),
            ],
            32,
            background = "#FFFFFF",
        ),
    ), Screen(
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

auto_minimize = True

idle_inhibitors = []  # type: list

wmname = "LG3D"
