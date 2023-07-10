from libqtile.config import Group, Match

terminal = "kitty"
browser = "firefox"
fileManager = "ranger"

groups = [
    Group(
        name="1",
        label="\ueb06",
        layout="monadtall",
        spawn=[
            terminal,
            f"{terminal} -e btm",
            f"{terminal} -e ranger",
        ]
    ),
    Group(
        name="2",
        label="\uf120 ",
        layout="monadtall",
        matches=[Match(wm_class=["nextcloud"])],
    ),
    Group(
        name="3",
        label="\uf269 ",
        layout="monadtall",
        matches=[Match(wm_class=["firefox"])],
        spawn=[browser,]
    ),
    Group(
        name="4",
        label="\ueac4 ",
        layout="monadtall",
        matches=[Match(wm_class=[f"{fileManager}"])],
    ),
    Group(
        name="5",
        label=" ",
        layout="monadtall",
        matches=[Match(wm_class=["discord"])],
        spawn=["discord"],
    ),
    Group(
        name="6",
        label="\uf1b6 ",
        layout="max",
        matches=[Match(wm_class=["steam"])],
        spawn=["steam"],
    ),
    Group(
        name="7",
        label="\uf001 ",
        layout="monadwide",
        spawn=[
            f"{terminal} -e cmus",
            f"{terminal} -e cava",
        ],
    ),
    Group(
        name="8",
        label="\ueb06 ",
        layout="monadtall",
    ),
]
