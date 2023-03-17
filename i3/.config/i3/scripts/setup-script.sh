#xrandr --output HDMI-2 --mode 1920x1080
if [ $(xrandr | grep -o "HDMI1") == "HDMI1" ]; then
  echo 'External HDMI monitor found - setting up dual monitor output'
  xrandr --output eDP-1 --mode 1920x1080 --pos 1920x0 --dpi 220
else
  echo 'No external HDMI monitor found - setting up single monitor output'
  xrandr --output eDP-1 --mode 1920x1080 --pos 0x0 --dpi 220
fi
RESOLUTION=1920x1080
xrandr --listmonitors | sed -n '1!p' | sed -e 's/\s[0-9].*\s\([a-zA-Z0-9\-]*\)$/\1/g' | xargs -n 1 -- bash -xc 'xrandr --output $0 --mode '$RESOLUTION' --pos 0x0 --rotate normal'
xmodmap -e "clear lock" #disable caps lock switch
xmodmap -e "keysym Caps_Lock = Escape" #set caps_lock as escape
xrandr --output HDMI-1 --mode 1920x1080
xrandr --output eDP-1 --auto
feh --bg-scale .dotfiles/background/background.jpg



