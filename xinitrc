#!/bin/sh

sysmodmap=/etc/X11/xinit/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
userkeys=$HOME/.xbindkeysrc
usermodmap=$HOME/.Xmodmap
userprofile=$HOME/.xprofile
userresources=$HOME/.Xresources

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

if [ -f $userkeys ]; then
  xbindkeys
fi

if [ -f $userprofile ]; then
  . $userprofile
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Scale screen resolution
xrandr --dpi 168

# Faster key repeat
xset r rate 285 30

# Sync clipboards
autocutsel -fork &
autocutsel -selection PRIMARY -fork &

# Start Redshift (https://wiki.archlinux.org/index.php/redshift)
redshift &

# Start xcape (https://github.com/alols/xcape)
xcape &

# Start Compton (https://github.com/chjj/compton)
compton -b

# Start i3
exec i3
