from libqtile import layout
from colors import colors
from libqtile.config import Match

layouts = [
    layout.Columns(
        margin=5,
        border_focus=colors[4],
        border_normal=colors[1],
        border_width=1,
    ),

    layout.Max(
        margin=5,
        border_focus=colors[1],
        border_normal=colors[1],
        border_width=0,
    ),

    layout.Matrix(
        margin=5,
        border_focus=colors[5],
        border_normal=colors[1],
        border_width=1,
    ),

    layout.MonadTall(
        margin=5,
        border_focus=colors[3],
        border_normal=colors[1],
        border_width=1,
    ),

    layout.MonadWide(
        margin=5,
        border_focus=colors[3],
        border_normal=colors[1],
        border_width=1,
    ),

    layout.Tile(
        margin=5,
        border_focus=colors[5],
        border_normal=colors[1],
        border_width=1,
    ),

    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.RatioTile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

floating_layout = layout.Floating(
    float_rules=[
        # Run utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(wm_class="Clicker Heroes"),
    ]
)
