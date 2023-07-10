from libqtile.lazy import lazy

colors = []
cache = '/home/julius/.cache/wal/colors'


def init_colors(cache):
    with open(cache, 'r') as file:
        for i in range(8):
            colors.append(file.readline().strip())
    colors.append('#ffffff')
    lazy.reload()


init_colors(cache)
