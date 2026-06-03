from __future__ import annotations

from typing import TYPE_CHECKING

from libqtile import pangocffi
from libqtile.command.base import expose_command
from libqtile.config import ScreenRect
from libqtile.layout.base import Layout
from libqtile.layout.tree import TreeTab, Window
from xcffib.xproto import StackMode

if TYPE_CHECKING:
    from collections.abc import Sequence
    from typing import Any, Self

    from libqtile.backend import base
    from libqtile.group import _Group


class Finder(TreeTab):
    """Tree layout with a fullscreen, on-demand window finder."""

    defaults = [
        *TreeTab.defaults,
        ("bg_color", "#ffffff", "Background color of the finder panel."),
        ("foreground", "#000000", "Foreground color of window names."),
        ("font", "Eurostile Extended", "Font used for window names."),
        ("overlay_opacity", 0.96, "Opacity of the fullscreen finder panel."),
        ("row_x", 72, "Left padding for the window list."),
        ("row_y", 72, "Top padding for the window list."),
        ("row_gap", 10, "Vertical gap between window names."),
    ]

    def __init__(self, **config):
        super().__init__(**config)
        self.add_defaults(Finder.defaults)
        self._finder_visible = False
        self._last_screen_rect = None
        self._rows = []

    def clone(self, group: _Group) -> Self:
        clone = super().clone(group)
        clone._finder_visible = False
        clone._last_screen_rect = None
        clone._rows = []
        return clone

    def layout(self, windows: Sequence[base.Window], screen_rect: ScreenRect) -> None:
        self._last_screen_rect = screen_rect
        if self._finder_visible:
            self._resize_panel(screen_rect)
        Layout.layout(self, windows, screen_rect)

    def configure(self, client: base.Window, screen_rect: ScreenRect) -> None:
        if self._nodes and client is self._focused:
            client.place(
                screen_rect.x,
                screen_rect.y,
                screen_rect.width,
                screen_rect.height,
                0,
                None,
            )
            client.unhide()
            if self._finder_visible:
                self._raise_panel()
        else:
            client.hide()

    def show(self, screen_rect: ScreenRect) -> None:
        self._last_screen_rect = screen_rect
        if self._finder_visible:
            self._resize_panel(screen_rect)
            self._panel.unhide()
            self._raise_panel()

    def hide(self) -> None:
        self.hide_window_list()

    def _create_panel(self, screen_rect: ScreenRect) -> None:
        super()._create_panel(screen_rect)
        self._panel.opacity = self.overlay_opacity

    def _resize_panel(self, screen_rect: ScreenRect) -> None:
        self.panel_width = screen_rect.width
        if not self._panel:
            self._create_panel(screen_rect)

        self._panel.place(
            screen_rect.x,
            screen_rect.y,
            screen_rect.width,
            screen_rect.height,
            0,
            None,
            above=True,
        )
        self._create_drawer(screen_rect)
        self.draw_panel()
        self._raise_panel()

    def _raise_panel(self) -> None:
        if not self._panel:
            return

        self._panel.window.configure(stackmode=StackMode.Above)
        self.group.qtile.core.conn.flush()

    def draw_panel(self, *args) -> None:
        if not self._finder_visible:
            return

        self._rows = []
        if not self._panel:
            return

        self._drawer.clear(self.bg_color)
        rows = []
        total_height = 0
        for level, node in self._window_nodes(self._tree):
            title = node.window.name or "Untitled"
            if node.window is self._focused:
                title = f"> {title}"

            self._layout.font_family = self.font
            self._layout.font_size = self.fontsize
            self._layout.text = title
            rows.append((level, node, title, self._layout.height))
            total_height += self._layout.height

        if not rows:
            self._drawer.draw(offsetx=0, width=self._drawer.width)
            return

        total_height += self.row_gap * (len(rows) - 1)
        y = max(0, (self._drawer.height - total_height) // 2)

        for level, node, title, text_height in rows:
            self._layout.font_family = self.font
            self._layout.font_size = self.fontsize
            self._layout.text = title
            self._layout.colour = self.foreground
            self._layout.width = self._drawer.width - self.row_x * 2
            self._layout.layout.set_alignment(pangocffi.ALIGNMENTS["left"])
            self._layout.draw(x=self.row_x + level * self.level_shift, y=y)

            row_height = text_height + self.row_gap
            self._rows.append((y, y + row_height, node))
            y += row_height

        self._drawer.draw(offsetx=0, width=self._drawer.width)

    def _window_nodes(self, node, level=0):
        for child in node.children:
            if isinstance(child, Window):
                yield level, child
                if child.expanded:
                    yield from self._window_nodes(child, level + 1)
            elif child.expanded:
                yield from self._window_nodes(child, level)

    def _current_screen_rect(self) -> ScreenRect | None:
        if self.group.screen is not None:
            return self.group.screen.get_rect()
        return self._last_screen_rect

    @expose_command()
    def show_window_list(self) -> None:
        screen_rect = self._current_screen_rect()
        if screen_rect is None:
            return

        self._finder_visible = True
        self._resize_panel(screen_rect)
        self._panel.unhide()
        self._raise_panel()

    @expose_command()
    def hide_window_list(self) -> None:
        self._finder_visible = False
        if self._panel:
            self._panel.hide()

    @expose_command()
    def toggle_window_list(self) -> None:
        if self._finder_visible:
            self.hide_window_list()
        else:
            self.show_window_list()

    @expose_command("down")
    def next(self) -> None:
        super().next()
        if self._finder_visible:
            self.draw_panel()
            self._raise_panel()

    @expose_command("up")
    def previous(self) -> None:
        super().previous()
        if self._finder_visible:
            self.draw_panel()
            self._raise_panel()

    @expose_command()
    def select_window(self) -> None:
        self.hide_window_list()

    def process_button_click(self, x, y, button):
        if button != 1:
            return

        for top, bottom, node in self._rows:
            if top <= y < bottom:
                self.group.focus(node.window, False)
                self.hide_window_list()
                return

    @expose_command()
    def info(self) -> dict[str, Any]:
        info = super().info()
        info["finder_visible"] = self._finder_visible
        return info
