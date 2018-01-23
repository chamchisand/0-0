#!/bin/bash

img=$1
mode=$2

if [ -z "$img" ]; then
  img=--randomize ~/Pictures
fi

line=$(file $img | grep -Po '\d+\s*x\s*\d+' | tail -1)
IFS=x read -ra size <<< $line
w=${size[0]}
h=${size[1]}
# echo img: $w x $h

if [ -z "$mode" ]; then
  screen=$(xrandr | grep -P '\*' | grep -Po '\d+\s*x\s*\d+')
  IFS=x read -ra screenSize <<< $screen
  screenWidth=${screenSize[0]}
  screenHeight=${screenSize[1]}
  # echo "screen: $screenWidth x $screenHeight"

  if [ $w -lt $screenWidth ] && [ $h -lt $screenHeight ]; then
    mode=center
  else
    mode=max
  fi
fi

feh --no-fehbg --bg-$mode $img
