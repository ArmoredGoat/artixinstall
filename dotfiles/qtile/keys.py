from libqtile.config import Key
from libqtile.lazy import lazy

from groups import groups

meta = "mod4"
alt = "mod1"
hyper = [meta, alt, "shift", "control"]
meh = [alt, "shift", "control"]

terminal = "kitty"
browser = "firefox"
file_manager = "ranger"
music_player = "kitty -e cmus"

keys = [
    # Switch between windows in current stack pane
    Key([meta], "k",
        lazy.layout.up(),
        desc="Move focus up",
        ),
    Key([meta], "j",
        lazy.layout.down(),
        desc="Move focus down",
        ),
    Key([meta], "h",
        lazy.layout.left(),
        desc="Move focus to the left",
        ),
    Key([meta], "l",
        lazy.layout.right(),
        desc="Move focus to the right",
        ),

    # Move windows in current stack
    Key([meta, "shift"], "h",
        lazy.layout.shuffle_left(),
        desc="Move window to the left",
        ),
    Key([meta, "shift"], "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right"
        ),
    Key([meta, "shift"], "j",
        lazy.layout.shuffle_down(),
        desc="Move window down",
        ),
    Key([meta, "shift"], "k",
        lazy.layout.shuffle_up(),
        desc="Move window up",
        ),

    # Switch between screens
    Key([meta], "u",
        lazy.to_screen(2),
        desc="Move focus to left screen",
        ),
    Key([meta], "i",
        lazy.to_screen(0),
        desc="Move focus to center screeen",
        ),
    Key([meta], "o",
        lazy.to_screen(1),
        desc="Move focus to right screen",
        ),

    # Resize window
    Key([meta, "control"], "h",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add(),
        desc="Grow window to the left",
        ),
    Key([meta, "control"], "l",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete(),
        desc="Grow window to the right",
        ),
    Key([meta, "control"], "j",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        desc="Grow window down",
        ),
    Key([meta, "control"], "k",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        desc="Grow window up",
        ),

    # Toggle fullscreen and floating
    Key([meta], "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen for focused window",
        ),
    Key([meta, "shift"], "f",
        lazy.window.toggle_floating(),
        desc="Toggle floating for focused window",
        ),

    # Reset window size
    Key([meta], "n",
        lazy.layout.normalize(),
        desc="Reset all window sizes",
        ),
    # Maximize window size
    Key([meta], "m",
        lazy.layout.maximize(),
        desc="Reset all window sizes",
        ),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([meta, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
        ),

    # Toggle between layouts
    Key([meta], "Tab",
        lazy.next_layout(),
        desc="Toggle to next layout",
        ),
    Key([meta, "shift"], "Tab",
        lazy.prev_layout(),
        desc="Toggle to previous layout",
        ),

    # Spawn/kill applications/windows
    Key([meta], "Return",
        lazy.spawn(terminal),
        desc="Launch terminal",
        ),
    Key([meta], "w",
        lazy.window.kill(),
        desc="Kill focused window",
        ),

    # Applications
    Key(meh, "r",
        lazy.spawn("rofi -show drun"),
        desc="Spawn a command using a prompt widget",
        ),
    Key(meh, "t",
        lazy.spawn("rofi -show window"),
        desc="Spawn rofi to switch windows",
        ),
    Key(meh, "s",
        lazy.spawn("flameshot gui"),
        desc="Take a screenshot",
        ),
    Key(meh, "b",
        lazy.spawn(browser),
        desc="Spawn firefox"
        ),
    Key(hyper, "p",
        lazy.spawn("sh -c ~/.config/rofi/scripts/power"),
        desc="Open menu with power options",
        ),

    # General
    Key([meta, "control"], "r",
        lazy.reload_config(),
        desc="Reload the config",
        ),
    Key([meta, "control"], "q",
        lazy.shutdown(),
        desc="Shutdown Qtile",
        ),

    # Audio controls
    Key([meta, "shift"], "m",
        lazy.spawn("amixer -D default set Master toggle"),
        desc="Mute audio",
        ),
    Key([meta, "shift"], "j",
        lazy.spawn("amixer -D default sset Master 5%- unmute"),
        desc="Decrease audio volume by five percent",
        ),
    Key([meta, "shift"], "k",
        lazy.spawn("amixer -D default sset Master 5%+ unmute"),
        desc="Decrease audio volume by five percent",
        ),

    # Media controls

    Key(hyper, "i", lazy.spawn("playerctl play-pause"),
        desc="Play/Pause player"),
    Key(hyper, "o", lazy.spawn("playerctl next"),
        desc="Skip to next"),
    Key(hyper, "u", lazy.spawn("playerctl previous"),
        desc="Skip to previous"),
]

for i in groups:
    keys.extend(
        [
            # meta1 + letter of group = switch to group
            Key(
                [meta], i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # meta1 + shift + letter of group = switch to & move focused window
            # to group
            Key(
                [meta, "shift"], i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(
                    i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # meta1 + shift + letter of group = move focused window to group
            # Key([meta, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

# L A Z Y   F U N C T I O N S


@lazy.function  # decorator delay execution of function until needed
def window_to_prev_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i - 1].name)


@lazy.function
def window_to_next_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i + 1].name)
