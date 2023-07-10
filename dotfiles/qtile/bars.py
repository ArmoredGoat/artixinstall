import os
from libqtile import bar, extension, qtile, widget
from libqtile.lazy import lazy

home = os.path.expanduser('~')
config = os.path.expanduser('~/.config/qtile/')
assets = os.path.expanduser('~/.config/qtile/assets/')

colors = []
cache = '/home/julius/.cache/wal/colors'


def init_colors(cache):
    with open(cache, 'r') as file:
        for i in range(8):
            colors.append(file.readline().strip())
    colors.append('#ffffff')
    lazy.reload()


init_colors(cache)


def search():
    qtile.cmd_spawn("rofi -show drun")


def power():
    qtile.cmd_spawn("sh -c ~/.config/rofi/scripts/power")


widget_defaults = dict(
    background=colors[2],
    font="Hack Nerd Font",
    fontsize=16,
    foreground=colors[6],
    padding=2,
)
extension_defaults = widget_defaults.copy()


def init_widget_list():
    widget_list = [
        widget.Spacer(
            background=colors[1],
            length=10,
        ),
        widget.Image(
            background=colors[1],
            filename=assets + '/icons/icon_launch.png',
            margin=1,
            mouse_callbacks={"Button1": power},
        ),
        widget.Image(
            background=colors[1],
            filename=assets + '/separators/sep_wave_rl.png',
        ),
        widget.GroupBox(
            active=colors[5],
            block_highlight_text_color=colors[5],
            borderwidth=3,
            disable_drag=True,
            highlight_color=colors[2],
            highlight_method='line',
            inactive=colors[4],
            other_current_screen_border=colors[4],
            other_screen_border=colors[4],
            this_current_screen_border=colors[6],
            this_screen_border=colors[6],
            urgent_border=colors[1],
        ),
        widget.Spacer(
            length=8,
        ),
        widget.Image(
            filename=assets + '/separators/sep_straight_lr.png',
        ),
        widget.Image(
            filename=assets + '/icons/icon_layout.png',
        ),
        widget.CurrentLayout(
            fmt='{}',
            font="Hack Nerd Font Mono Bold",
            fontsize=14,
        ),
        widget.Image(
            background=colors[1],
            filename=assets + '/separators/sep_wave_lr.png',
        ),
        widget.Image(
            background=colors[1],
            filename=assets + '/icons/icon_search.png',
            margin=2,
            mouse_callbacks={"Button1": search},
        ),
        widget.TextBox(
            background=colors[1],
            fmt='Search',
            font="Hack Nerd Font Mono Bold",
            fontsize=13,
            mouse_callbacks={"Button1": search},
        ),
        widget.Image(
            filename=assets + '/separators/sep_circle_r.png',
        ),
        widget.WindowName(
            empty_group_string="Desktop",
            font="Hack Nerd Font Mono Bold",
            format="{name}",
        ),
        widget.Image(
            filename=assets + '/separators/sep_circle_l.png',
        ),
        widget.Systray(
            background=colors[1],
        ),
        widget.TextBox(
            background=colors[1],
            text=' ',
        ),
        widget.Image(
            background=colors[1],
            filename=assets + '/separators/sep_wave_rl.png',
        ),
        widget.Image(
            filename=assets + '/icons/icon_cpu.png'
        ),
        widget.Spacer(
            length=-5,
        ),
        widget.CPU(
            format="{load_percent}%",
            update_interval=5,
        ),
        widget.Image(
            filename=assets + '/separators/sep_straight_rl.png',
        ),
        widget.Image(
            filename=assets + '/icons/icon_ram.png',
            margin=3,
        ),
        widget.Spacer(
            length=-5,
        ),
        widget.Memory(
            format="{MemPercent}%",
            update_interval=5,
        ),
        widget.Image(
            filename=assets + '/separators/sep_straight_rl.png',
        ),
        widget.Image(
            filename=assets + '/icons/icon_thermometer.png',
            margin=4,
        ),
        widget.Spacer(
            length=-2,
        ),
        widget.ThermalSensor(
            threshold=90,
            update_interval=5,
        ),
        widget.Image(
            filename=assets + '/separators/sep_straight_rl.png',
        ),
        widget.Volume(
            theme_path=assets + '/volume/',
            emoji=True,
        ),
        widget.Spacer(
            length=-7,
        ),
        widget.Volume(
        ),
        widget.Image(
            filename=assets + '/separators/sep_wave_lr.png',
        ),
        widget.Image(
            background=colors[1],
            filename=assets + '/icons/icon_clock.png',
            margin=5,
        ),
        widget.Clock(
            background=colors[1],
            format="%H:%M:%S"
        ),
        widget.Spacer(
            background=colors[1],
            length=10,
        ),
    ]
    return widget_list


def init_widget_list_main():
    widget_list_main_bar = init_widget_list()
    return widget_list_main_bar


def init_widget_list_side():
    widget_list_side_bar = init_widget_list()
    del widget_list_side_bar[14:15]
    return widget_list_side_bar


main_bar = bar.Bar(
    widgets=init_widget_list_main(),
    size=30,
    margin=[5, 5, 0, 5],
)

side_bar_one = bar.Bar(
    widgets=init_widget_list_side(),
    size=30,
    margin=[5, 5, 0, 5],
)

side_bar_two = bar.Bar(
    widgets=init_widget_list_side(),
    size=30,
    margin=[5, 5, 0, 5],
)
