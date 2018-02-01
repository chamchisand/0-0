#!/bin/bash

error() {
  echo $1 1>&2
  exit 1
}

usage() {
  echo "Usage: $0 <path> [-b background color] [-r resize]
Options:
  -b background color [default: background color from Xresources]
  -r image size [default: 100%]"
  exit 1
}

if [ ! "$(which feh 2> /dev/null)" ]; then
  error ERROR: feh is not installed
fi

if [ ! "$(which convert 2> /dev/null)" ]; then
  error ERROR: ImageMagick is not installed
fi

if [ -z "$1" ]; then
  usage
fi

resize="100%"
verbose=0
path=$1
shift

if [ -d "$path" ]; then
  path=$(find $path -type f -regex '.*\.\(jpg\|jpeg\|png\)$' | shuf | head -n 1)
fi

if [ -f "$path" ]; then
  path=$(readlink -f "$path")
else
  error "ERROR: $path is not valid file path"
fi

while getopts ":b:r:v" o; do
  case "$o" in
    v) verbose=1 ;;
    b) bg="$OPTARG" ;;
    r) resize="$OPTARG" ;;
    *) usage; exit 1 ;;
  esac
done

if [ -z "$bg" ]; then
  bg=$(xrdb -query | grep background | head -n 1 | awk '{ print $2 }')
fi

screen=$(xrandr | grep -P '\*' | grep -Po '\d+\s*x\s*\d+')
IFS=x read -ra screenSize <<< $screen
width=${screenSize[0]}
height=${screenSize[1]}

filename=$(basename "$path")
dir=$(dirname "$path")
ext="${filename##*.}"
filename="${filename%.*}"
output="/tmp/wallpaper.$ext"

if [ "$verbose" = "1" ]; then
  line=$(file $path | grep -Po '\d+\s*x\s*\d+' | tail -1)
  IFS=x read -ra size <<< $line
  w=${size[0]}
  h=${size[1]}

  echo "image path: $path"
  echo "image size: $w x $h"
  echo "screen size: $width x $height"
  echo "background color: $bg"
  echo "resize: $resize"
fi

convert $path \
  -quality 100 \
  -geometry ${width}x${height} \
  -gravity center \
  -resize $resize \
  -background "${bg:-#000000}" \
  -extent ${width}x${height} \
  $output

feh --no-fehbg --bg-center $output
rm $output
