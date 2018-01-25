#!/bin/bash

error() {
  echo $1 1>&2;
}

usage() {
  error "Usage: $0 [-b background] [-r resize] file"
}

while getopts ":b:m:r:" o; do
  case "$o" in
    m) mode="$OPTARG" ;;
    b) bg="$OPTARG" ;;
    r) resize="$OPTARG" ;;
    *) usage; exit 1 ;;
  esac
done

shift $((OPTIND-1))
mode=${mode:=max}
bg=${bg:=#000000}

if [ -z "$1" ]; then
  usage; exit 1;
fi

if [ -d "$1" ]; then
  echo "Randomly pick background from $1"
  feh --no-fehbg --bg-$mode --randomize $1
  exit
fi

if [ ! -f "$1" ]; then
  error "ERROR: invalid file path"
fi

img=$(readlink -f "$1")

echo "img=$img"
echo "bg=$bg"
echo "mode=$mode"
echo "resize=$resize"

line=$(file $img | grep -Po '\d+\s*x\s*\d+' | tail -1)
IFS=x read -ra size <<< $line
w=${size[0]}
h=${size[1]}
echo img: $w x $h

screen=$(xrandr | grep -P '\*' | grep -Po '\d+\s*x\s*\d+')
IFS=x read -ra screenSize <<< $screen
screenWidth=${screenSize[0]}
screenHeight=${screenSize[1]}
echo "screen: $screenWidth x $screenHeight"

if [ -z "$mode" ]; then
  if [ $w -lt $screenWidth ] && [ $h -lt $screenHeight ]; then
    mode=center
  else
    mode=max
  fi
fi

if [ ! "$(which convert 2> /dev/null)" ]; then
  echo ERROR: ImageMagick not installed
  exit 1
fi

filename=$(basename "$img")
dir=$(dirname "$img")
ext="${filename##*.}"
filename="${filename%.*}"
output="$dir/background-$filename-$RANDOM.$ext"
echo "output=$output"


if [ -z "$resize" ]; then
  resize="${screenWidth}x${screenHeight}"
fi

convert $img \
  -quality 100 \
  -gravity center \
  -resize $resize \
  -background "$bg" \
  -extent ${screenWidth}x${screenHeight} \
  $output

feh --no-fehbg --bg-center $output
