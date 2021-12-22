if [ $(xrandr | grep -o "HDMI1") == "HDMI1" ]; then
  echo 'External HDMI monitor found - setting up dual monitor output'
  xrandr --output eDP-1 --mode 1920x1080 --pos 1920x0 --dpi 220
else
  echo 'No external HDMI monitor found - setting up single monitor output'
  xrandr --output eDP-1 --mode 1920x1080 --pos 0x0 --dpi 220
fi

