#!/bin/bash

# This script is basically taking all existing JPG files in given directory
# and reducing their size without so much quality reduction.
# It's helpful when you want to send lots of photos via mail etc.
#
# This script requies imagemagick package installed.
#

if [ $# -eq 0 ]; then
    echo "Oh c'mon man! Give me ONE parameter: directory where your jpg files sits."
    exit 1
fi

shopt -s nullglob
cd $1

for f in *.jpg
do
	echo "Dieting jpg file - $f"
        `convert -interlace Plane -gaussian-blur 0.05 -quality 85% $f "m_$f"`
done

cd -
