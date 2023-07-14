import os
from libqtile import bar, extension, qtile, widget
from libqtile.lazy import lazy
from colors import nord

home = os.path.expanduser('~')
config = os.path.expanduser('~/.config/qtile/')
assets = os.path.expanduser('~/.config/qtile/assets/')

def search():
    qtile.spawn("rofi -show drun")


def power():
    qtile.spawn("sh -c ~/.config/rofi/scripts/power")


widget_defaults = dict(
    background=nord[2],
    font="DejaVu Sans Mono Nerd Font",
    fontsize=16,
    foreground=nord[6],
    padding=2,
)
extension_defaults = widget_defaults.copy()


def init_widget_list():
    widget_list = [
        widget.Spacer(
            background=nord[1],
            length=10,
        ),
        widget.Image(
            background=nord[1],
            filename=assets + '/icons/icon_launch.png',
            margin=5,
            mouse_callbacks={"Button1": power},
        ),
        widget.Image(
            filename=assets + '/separators/sep_wave_rl_nord1_nord2.png',
        ),
        widget.GroupBox(
            active=nord[4],
            background=nord[2],
            block_highlight_text_color=nord[4],
            borderwidth=3,
            center_aligned=True,
            disable_drag=True,
            font="DejaVu Sans Mono Nerd Font",
            fontsize=16,
            highlight_method='block',
            inactive=nord[10],
            other_current_screen_border=nord[3],
            other_screen_border=nord[3],
            this_current_screen_border=nord[1],
            this_screen_border=nord[1],
            urgent_border=nord[11],
        ),
        widget.Spacer(
            length=8,
            background=nord[2]
        ),
        widget.Image(
            filename=assets + '/separators/sep_straight_lr_nord2_nord1.png',
        ),
        widget.Image(
            background=nord[1],
            filename=assets + '/icons/icon_layout.png',
        ),
        widget.CurrentLayout(
            fmt='{}',
            background=nord[1],
            font="Hack Nerd Font Mono Bold",
            fontsize=13,
            foreground=nord[5],
        ),
        widget.Image(
            filename=assets + '/separators/sep_wave_lr_nord1_nord2.png',
        ),
        widget.Image(
            background=nord[2],
            filename=assets + '/icons/icon_search.png',
            margin=2,
            mouse_callbacks={"Button1": search},
        ),
        widget.TextBox(
            background=nord[2],
            foreground=nord[5],
            fmt='Search',
            font="Hack Nerd Font Mono Bold",
            fontsize=13,
            mouse_callbacks={"Button1": search},
        ),
        widget.Image(
            filename=assets + '/separators/sep_circle_r.png',
        ),
        widget.WindowName(
            background=nord[1],
            foreground=nord[5],
            empty_group_string="Desktop",
            font="DejaVu Sans Mono Nerd Font Bold",
            format="{name}",
        ),
        widget.Image(
            filename=assets + '/separators/sep_circle_l.png',
        ),
        widget.Systray(
            background=nord[2],
        ),
        widget.TextBox(
            background=nord[2],
            text=' ',
        ),
        widget.Image(
            filename=assets + '/separators/sep_wave_rl_nord2_nord1.png',
        ),
        widget.Image(
            background=nord[1],
            filename=assets + '/icons/icon_thermometer.png',
            margin=4,
        ),
        widget.Spacer(
            background=nord[1],
            length=-2,
        ),
        widget.ThermalSensor(
            background=nord[1],
            threshold=90,
            update_interval=5,
        ),
        widget.Image(
            filename=assets + '/separators/sep_straight_rl_nord1_nord2.png',
        ),
        widget.BatteryIcon(
               background=nord[2], 
               theme_path=assets + '/icons/battery/'
                ),
        widget.Battery(
            background=nord[2],
            font="DejaVu Sans Mono Nerd Font",
            fontsize=14,
            foreground=nord[5],
                ),
        widget.Image(
            filename=assets + '/separators/sep_straight_rl_nord2_nord1.png',
        ),
        widget.Spacer(
                background=nord[1],
                length=5,
                ),
        widget.Wlan(
            background=nord[1],
            disconnected_message='Test',
            foreground=nord[5],
            format='{essid} Test',
                ),
        widget.Image(
            filename=assets + '/separators/sep_straight_rl_nord1_nord2.png',
        ),
        widget.Volume(
            background=nord[2],
            theme_path=assets + '/icons/volume/',
            emoji=True,
        ),
        widget.Spacer(
            background=nord[2],
            length=-7,
        ),
        widget.Volume(
            background=nord[2],
            foreground=nord[5],
        ),
        widget.Image(
            filename=assets + '/separators/sep_wave_lr_nord2_nord1.png',
        ),
        widget.Image(
            background=nord[1],
            filename=assets + '/icons/icon_clock.png',
            margin=4,
        ),
        widget.Spacer(
                background=nord[1],
                length=-5,
                ),
        widget.Clock(
            background=nord[1],
            font="DejaVu Sans Mono Nerd Font",
            fontsize=14,
            foreground=nord[5],
            format="%H:%M",
        ),
        widget.Spacer(
            background=nord[1],
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
