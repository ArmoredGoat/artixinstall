<<<<<<< HEAD
# import re   # searching and manipulating strings using regular expressions
# import socket  # creating and using network sockets
# import subprocess  # spawn new processes, connect to pipes, obtain return codes

from colors import colors
# K E Y B I N D S

from keys import keys

# M O U S E

from mouse import mouse

# G R O U P S

from groups import groups

# L A Y O U T S

from layouts import layouts, floating_layout

# S C R E E N S

from screens import screens

=======
from libqtile import bar, layout, widget, hook, qtile
import libqtile.bar
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

# G E N E R A L

mod = "mod4"
terminal = "kitty"

# C O L O R S

colors = []

theme = "/home/julius/.local/share/themes/saharan_day.conf"


def load_colors(theme):
    with open(theme, 'r') as file:
        # Scan file and append color value if line starts with "color"
        for line in file:
            if line.startswith("color"):
                colorIndex = line.find('#')
                colors.append(line[colorIndex:].strip())
    lazy.reload()


load_colors(theme)

# K E Y B I N D S

keys = [
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(),
        desc="Move window focus to next/other window"),

    # Move windows
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),
        desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(),
        desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(),
        desc="Move window up"),

    # Resize windows
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(),
        desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(),
        desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(),
        desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(),
        desc="Grow window up"),
    Key([mod], "f", lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen for focused window"),

    # Reset windows
    Key([mod], "n", lazy.layout.normalize(),
        desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),

    # Toggle between layouts
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),

    # Spawn/kill applications/windows
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "r", lazy.spawn("rofi -show drun"),
        desc="Spawn a command using a prompt widget"),
    Key([mod], "s", lazy.spawn("flameshot gui"),
        desc="Take a screenshot"),
    Key([mod], "p", lazy.spawn("sh -c ~/.config/rofi/scripts/power"),
        desc="Open menu with power options"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),

    # General
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),

    # Audio controls
    Key([mod, "shift"], "m", lazy.spawn("amixer -D default set Master toggle"),
        desc="Mute audio"),
    Key([mod, "shift"], "j", lazy.spawn(
        "amixer -D default sset Master 5%- unmute"),
        desc="Decrease audio volume by five percent"),
    Key([mod, "shift"], "k", lazy.spawn(
        "amixer -D default sset Master 5%+ unmute"),
        desc="Decrease audio volume by five percent"),
    Key([mod], "c", lazy.spawn("kitty -e cmus"),)
]

# G R O U P S

groups = [
    Group(name="1", label="\ueb06", layout="monadtall",
          matches=[Match(wm_class=["Freetube"])]),
    Group("2", label="\uf120", layout="monadtall",
          matches=[Match(wm_class=["nextcloud"])]),
    Group("3", label="\ueac4", layout="monadtall",
          matches=[Match(wm_class=["ranger"])]),
    Group("4", label="󱋊", layout="monadtall",
          matches=[Match(wm_class=["discord"])],
          spawn=["discord"]),
    Group("5", label="\uf1b6", layout="monadtall",
          matches=[Match(wm_class=["Steam"])],
          spawn=["Steam"]),
    Group("6", label="\uf269", layout="max",
          matches=[Match(wm_class=["firefox"])],
          spawn=["firefox"]),
    Group("7", label="\uf001", layout="tile",
          matches=[Match(wm_class=["spotify"])],
          spawn=["kitty", "kitty -e vis", "kitty -e cmus"]),
    Group("8", label="\ueb06", layout="monadtall",
          matches=[Match(wm_class=["cmus"])]),
]

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod], i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"], i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(
                    i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

# L A Y O U T S

layouts = [
    layout.Columns(
        margin=5,
        border_focus=colors[1],
        border_normal=colors[13],
        border_width=1,
    ),

    layout.Max(
        margin=5,
        border_focus=colors[1],
        border_normal=colors[13],
        border_width=0,
    ),

    layout.Matrix(
        margin=5,
        border_focus=colors[1],
        border_normal=colors[13],
        border_width=1,
    ),

    layout.MonadTall(
        margin=5,
        border_focus=colors[1],
        border_normal=colors[13],
        border_width=1,
    ),

    layout.MonadWide(
        margin=5,
        border_focus=colors[1],
        border_normal=colors[13],
        border_width=1,
    ),

    layout.Tile(
        margin=5,
        border_focus=colors[1],
        border_normal=colors[13],
        border_width=1,
    ),

    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.RatioTile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

# B A R

widget_defaults = dict(
    font="Hack Nerd Font",
    fontsize=16,
    padding=4,
)
extension_defaults = widget_defaults.copy()


def search():
    qtile.cmd_spawn("rofi -show drun")


def power():
    qtile.cmd_spawn("sh -c ~/.config/rofi/scripts/power")


screens = [
    Screen(
        top=bar.Bar(
            [
                widget.Spacer(
                    length=15,
                    background=colors[13],
                ),

                widget.Image(
                    background=colors[13],
                    filename='~/.config/qtile/assets/icons/icon_launch_earth.png',
                    margin=2,
                    mouse_callbacks={"Button1": power},
                ),

                widget.Image(
                    background=colors[13],
                    filename='~/.config/qtile/assets/separators/sep_wave_rl.png',
                ),

                widget.GroupBox(
                    active=colors[5],
                    background=colors[12],
                    block_highlight_text_color=colors[5],
                    highlight_color=colors[11],
                    inactive=colors[13],
                    borderwidth=3,
                    disable_drag=True,
                    fontsize=16,
                    foreground=colors[5],
                    highlight_method='block',
                    other_current_screen_border=colors[10],
                    other_screen_border=colors[10],
                    this_current_screen_border=colors[13],
                    this_screen_border=colors[13],
                    urgent_border=colors[13],
                ),

                widget.Spacer(
                    length=8,
                    background=colors[12],
                ),

                widget.Image(
                    background=colors[12],
                    filename='~/.config/qtile/assets/separators/sep_straight_lr.png',
                ),

                widget.Image(
                    background=colors[12],
                    filename='~/.config/qtile/assets/icons/icon_layout.png',
                ),

                widget.CurrentLayout(
                    background=colors[12],
                    foreground=colors[5],
                    fmt='{}',
                    font="Hack Nerd Font Mono Bold",
                    fontsize=13,
                ),

                widget.Image(
                    background=colors[12],
                    filename='~/.config/qtile/assets/separators/sep_wave_lr.png',
                ),

                widget.Image(
                    filename='~/.config/qtile/assets/icons/icon_search.png',
                    margin=2,
                    background=colors[13],
                    mouse_callbacks={"Button1": search},
                ),

                widget.TextBox(
                    fmt='Search',
                    background=colors[13],
                    font="Hack Nerd Font Mono Bold",
                    fontsize=13,
                    foreground=colors[5],
                    mouse_callbacks={"Button1": search},
                ),

                widget.Image(
                    background=colors[13],
                    filename='~/.config/qtile/assets/separators/sep_circle_r.png',
                ),

                widget.WindowName(
                    background=colors[12],
                    font="Hack Nerd Font Mono Bold",
                    fontsize=16,
                    foreground=colors[5],
                    format="{name}",
                    empty_group_string="Desktop",
                ),

                widget.Image(
                    background=colors[13],
                    filename='~/.config/qtile/assets/separators/sep_circle_l.png',
                ),

                widget.Systray(
                    background=colors[13],
                    fontsize=2,
                ),

                widget.TextBox(
                    background=colors[13],
                    text=' ',
                ),

                widget.Image(
                    background=colors[13],
                    filename='~/.config/qtile/assets/separators/sep_wave_rl.png',
                ),

                widget.Image(
                    background=colors[12],
                    filename='~/.config/qtile/assets/icons/icon_cpu.png'
                ),

                widget.Spacer(
                    background=colors[12],
                    length=-7,
                ),

                widget.CPU(
                    background=colors[12],
                    foreground=colors[5],
                    format="{load_percent}%",
                ),

                widget.Image(
                    background=colors[12],
                    filename='~/.config/qtile/assets/separators/sep_straight_rl.png',
                ),

                widget.Image(
                    background=colors[12],
                    filename='~/.config/qtile/assets/icons/icon_ram.png',
                    margin=3,
                ),

                widget.Spacer(
                    background=colors[12],
                    length=-7,
                ),

                widget.Memory(
                    background=colors[12],
                    foreground=colors[5],
                    format="{MemPercent}%",
                    update_interval=5,
                ),

                widget.Image(
                    background=colors[12],
                    filename='~/.config/qtile/assets/separators/sep_straight_rl.png',
                ),

                widget.Image(
                    background=colors[12],
                    filename='~/.config/qtile/assets/icons/icon_hdd.png',
                    margin=3,
                ),

                widget.Spacer(
                    background=colors[12],
                    length=-3,
                ),

                widget.DF(
                    foreground=colors[5],
                    format="{uf}{m}",
                    measure="G",
                    partition="/",
                    visible_on_warn=False,
                    background=colors[12],
                ),

                widget.Image(
                    background=colors[12],
                    filename='~/.config/qtile/assets/separators/sep_straight_rl.png',
                ),

                # widget.Image(
                #   background=colors[12],
                #   filename='~/.config/qtile/assets/icons/icon_update.png',
                #   margin=3,
                # ),

                # widget.Spacer(
                #    background=colors[12],
                #    length=-7,
                # ),

                # widget.CheckUpdates(
                #    background=colors[12],
                #    display_format="{updates}",
                #    distro="Arch_checkupdates",
                #    foreground=colors[5],
                #    no_update_string="0",
                #    update_interval=60,
                # ),

                # widget.Image(
                #    background=colors[12],
                #    filename='~/.config/qtile/assets/separators/sep_straight_rl.png',
                # ),

                widget.Volume(
                    background=colors[12],
                    font="Hack Nerd Font Mono",
                    fontsize=13,
                    theme_path='~/.config/qtile/assets/volume/',
                    emoji=True,
                ),

                widget.Spacer(
                    length=-10,
                    background=colors[12],
                ),

                widget.Volume(
                    background=colors[12],
                    font='Hack Nerd Font Mono',
                    foreground=colors[5],
                ),

                widget.Image(
                    background=colors[12],
                    filename='~/.config/qtile/assets/separators/sep_wave_lr.png',
                ),

                widget.Image(
                    background=colors[13],
                    filename='~/.config/qtile/assets/icons/icon_clock.png',
                    margin=5,
                ),

                widget.Clock(
                    background=colors[13],
                    foreground=colors[5],
                    font="Hack Nerd Font Mono",
                    format="%H:%M:%S"
                ),

                widget.Spacer(
                    length=15,
                    background=colors[13],
                ),
            ],
            size=30,
            border_color=colors[13],
            border_width=[0, 0, 0, 0],
            margin=[10, 30, 6, 30],
        ),
    ),
]

# H O O K S


# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]
>>>>>>> 00ed6e06fd2518bb1d1223c953b4a5fa380c83d7

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False


auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If applications like steam games want to auto-minimize themselves when losing
# focus, respect that.
auto_minimize = True

<<<<<<< HEAD
wmname = "qtile"
=======
# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

>>>>>>> 00ed6e06fd2518bb1d1223c953b4a5fa380c83d7
# E O F
