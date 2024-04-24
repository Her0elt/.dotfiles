xmodmap -e "clear lock" #disable caps lock switch
xmodmap -e "keysym Caps_Lock = Escape" #set caps_lock as escape
feh --bg-scale .dotfiles/background/background.jpg
RESOLUTION=1920x1080
xrandr --listmonitors | sed -n '1!p' | sed -e 's/\s[0-9].*\s\([a-zA-Z0-9\-]*\)$/\1/g' | xargs -n 1 -- bash -xc 'xrandr --output $0 --scale-from '$RESOLUTION' --pos 0x0 --rotate normal'

