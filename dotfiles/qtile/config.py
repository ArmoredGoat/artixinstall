from libqtile import bar, layout, widget
from libqtile.bar import CALCULATED
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"
terminal = "kitty" 

colors = []
cache="/home/julius/.cache/wal/colors"
def load_colors(cache):
    with open(cache, 'r') as file:
        for i in range(8):
            colors.append(file.readline().strip())
    colors.append('#ffffff')
    lazy.reload()
load_colors(cache)


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h",     lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l",     lazy.layout.right(),desc="Move focus to right"),
    Key([mod], "j",     lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k",     lazy.layout.up(),   desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
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
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawn("rofi -show run"), desc="Spawn a command using a prompt widget"),
    # If rofi is throwing a tantrum, I have the inbuilt spawner still in place.
    Key([mod, "shift"], "r", lazy.spawncmd()),
]

groups = []

group_names = ["1", "2", "3", "4", "5", "6", "7",]
group_labels = ["Start", "\ue7a2", "\ueac4", "󰘑", "\uf1b6", "\uf269", "\uf001",]
group_layouts = ["monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "tile",]

for i in range(len(group_names)):
    groups.append(
        Group(
            name = group_names[i],
            layout = group_layouts[i].lower(),
            label = group_labels[i],
            )
        )

    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                groups[i].name,
                lazy.group[groups[i].name].toscreen(),
                desc="Switch to group {}".format(groups[i].name),
            ),
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"],
                groups[i].name,
                lazy.window.togroup(groups[i].name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(groups[i].name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    layout.Stack(num_stacks=2),
    layout.Bsp(),
    layout.Matrix(),
    layout.MonadTall(),
    layout.MonadWide(),
    layout.RatioTile(),
    layout.Tile(),
    layout.TreeTab(),
    layout.VerticalTile(),
    layout.Zoomy(),
]

widget_defaults = dict(
    font="Hack Nerd Font Mono",
    fontsize=16,
    padding=4,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [   
                widget.TextBox(
                    text = "\uf31f",
                    ),
                widget.Sep(),
                widget.GroupBox(),
                widget.WindowName(
                    empty_group_string = "",
                    width = CALCULATED,
                    ),
                widget.Systray(),
                widget.TextBox(
                    text="\uf4bc",
                    fontsize=20,
                    padding=1,
                    ), 
                widget.CPU(
                    format="{load_percent}%",
                    ),
                widget.TextBox(
                    text="\ue266",
                    fontsize=20,
                    padding=1,
                    ),
                widget.Memory(format="{MemPercent}%"),
                widget.TextBox(
                    text="\uf0a0",
                    fontsize=20,
                    padding=1,
                    ),
                widget.DF(
                    format="{uf}{m}",
                    measure="G",
                    partition="/",
                    visible_on_warn=False,
                    ),
                widget.TextBox(
                    background = colors[5],
                    foreground = colors[1],
                    text="󰒍",
                    fontsize=20,
                    padding=1,
                    ),
                widget.Net(
                    background = colors[1],
                    foreground = colors[5],
                    format="{down}",
                    interface="eth0",
                    padding=1,
                    prefix="M",
                    ),
                widget.TextBox(
                    text="\uf175\uf176",
                    fontsize=20,
                    padding=1,
                    ),
                widget.Net(
                    format="{up}",
                    interface="eth0",
                    padding=3,
                    prefix="M",
                    ),
                widget.TextBox(
                    text="󰚰", # \udb81\udeb0"
                    fontsize=20,
                    padding=1,
                    ),
                widget.CheckUpdates(
                    display_format="{updates}",
                    distro="Arch_checkupdates",
                    no_update_string="0",
                    update_interval=60,
                    ),
                widget.Cmus(
                    max_chars=20,
                    scroll=True,
                    scroll_repeat=True,
                    ),
                widget.Sep(),
                widget.TextBox(
                    text = "󱑏", # \udb85\udc4f
                    ),
                widget.Clock(format="%A - %H:%M:%S"),
            ],
            size = 18,
            border_width = 4,
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
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
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

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
