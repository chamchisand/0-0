#!/bin/bash

if [ -z "$1" ]; then
  echo ERROR: image path is requied
  exit 1
fi

img=$(readlink -f "$1")
mode=$2

if [ -d "$img" ]; then
  feh --no-fehbg --bg-max --randomize $img
  exit
fi

if [ ! -f "$img" ]; then
  echo ERROR: invalid image path
  exit 1
fi

if [ -z "$mode" ]; then
  line=$(file $img | grep -Po '\d+\s*x\s*\d+' | tail -1)
  IFS=x read -ra size <<< $line
  w=${size[0]}
  h=${size[1]}

  screen=$(xrandr | grep -P '\*' | grep -Po '\d+\s*x\s*\d+')
  IFS=x read -ra screenSize <<< $screen
  screenWidth=${screenSize[0]}
  screenHeight=${screenSize[1]}
  echo "screen: $screenWidth x $screenHeight"

  if [ $w -lt $screenWidth ] && [ $h -lt $screenHeight ]; then
    mode=center
  else
    mode=max
  fi
fi

feh --no-fehbg --bg-$mode $img
