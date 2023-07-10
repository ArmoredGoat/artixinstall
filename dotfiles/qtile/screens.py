from bars import main_bar, side_bar_one, side_bar_two
from libqtile.config import Screen

main_screen = Screen(top=main_bar)
side_screen_one = Screen(top=side_bar_one)
side_screen_two = Screen(top=side_bar_two)

screens = [main_screen, side_screen_one, side_screen_two]
