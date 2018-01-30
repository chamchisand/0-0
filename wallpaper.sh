#!/bin/bash

print() {
  echo $1
}

error() {
  echo $1 1>&2
  exit 1
}

if [ ! "$(which feh 2> /dev/null)" ]; then
  error ERROR: feh not installed
fi

if [ ! "$(which convert 2> /dev/null)" ]; then
  error ERROR: ImageMagick not installed
fi

if [ -z "$1" ]; then
  error "ERROR: path to image or directory is missing"
fi

if [ -d "$1" ]; then
  files=($1/*)
  img=${files[RANDOM % ${#files[@]}]}
elif [ -f "$1" ]; then
  img=$(readlink -f "$1")
else
  error "ERROR: invalid file path"
fi

shift

resize="100%"
verbose=0

while getopts ":b:r:v" o; do
  case "$o" in
    v) verbose=1 ;;
    b) bg="$OPTARG" ;;
    r) resize="$OPTARG" ;;
    *) echo "Usage: $0 [-b background] [-r resize] file"; exit 1 ;;
  esac
done

if [ -z "$bg" ]; then
  bg=$(xrdb -query | grep background | head -n 1 | awk '{ print $2 }')
fi

screen=$(xrandr | grep -P '\*' | grep -Po '\d+\s*x\s*\d+')
IFS=x read -ra screenSize <<< $screen
width=${screenSize[0]}
height=${screenSize[1]}

filename=$(basename "$img")
dir=$(dirname "$img")
ext="${filename##*.}"
filename="${filename%.*}"
output="$dir/background.$ext"

if [ "$verbose" = "1" ]; then
  line=$(file $img | grep -Po '\d+\s*x\s*\d+' | tail -1)
  IFS=x read -ra size <<< $line
  w=${size[0]}
  h=${size[1]}

  echo "image path: $img"
  echo "image size: $w x $h"
  echo "screen size: $width x $height"
  echo "background color: $bg"
  echo "resize: $resize"
fi

convert $img \
  -quality 100 \
  -geometry ${width}x${height} \
  -gravity center \
  -resize $resize \
  -background "$bg" \
  -extent ${width}x${height} \
  $output

feh --no-fehbg --bg-center $output
