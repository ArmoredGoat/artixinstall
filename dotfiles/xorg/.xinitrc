#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# A U T O S T A R T

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

#picom &
# Check if there is already a cached color scheme and if yes, reload it.
# Otherwise run pywal and create a color scheme.
if [[ -d ~/.cache/wal ]]; then
    wal -R &
else
    wal -i ~/.local/share/backgrounds/hollow_knight_lantern.png
fi
#sh ~/.config/pipewire/.pipewire-start.sh &

# Start Qtile
exec dbus-launch --exit-with-session /home/julius/.local/bin/qtile start