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

wmname = "qtile"
# E O F
