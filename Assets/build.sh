#!/usr/bin/env sh
#
# This script is used to generate application images.
# -- Requires rsvg-convert (from the rsvg package) and Inkscape.
#
# Copyright (C) 2015  Matt Borgerson
# 
# This file is part of TrayPlay.
# 
# TrayPlay is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# TrayPlay is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with TrayPlay.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $SCRIPT_DIR

DEST_DIR=../TrayPlay/Images.xcassets/AppIcon.appiconset

# Rasterize Application Icon
#----------------------------
for i in 16 32 128 256 512
do
    res2x=`expr $i \* 2`
    echo "Building App Icon $i"
    rsvg-convert -w $i -d 72 -o "$DEST_DIR/icon_$i.png" icon.svg
    rsvg-convert -w $res2x -d 144 -o "$DEST_DIR/icon_$i@2x.png" icon.svg
done

DEST_DIR=../TrayPlay/Images

# Rasterize Status Bar Icons
#----------------------------
echo "Building Status Off Icon"
rsvg-convert -h 23 -d 72 -o "$DEST_DIR/status_off.png" status_off.svg
rsvg-convert -h 46 -d 144 -o "$DEST_DIR/status_off@2x.png" status_off.svg

echo "Building Status On Icon"
rsvg-convert -h 23 -d 72 -o "$DEST_DIR/status_on.png" status_on.svg
rsvg-convert -h 46 -d 144 -o "$DEST_DIR/status_on@2x.png" status_on.svg

# Convert Button Icons to PDF
#-----------------------------
for icon_name in next pause play prev hamburger close arrow_right
do
    echo "Building $icon_name Icon"
    inkscape --without-gui --export-pdf="$DEST_DIR/$icon_name.pdf" "$icon_name.svg"
done

popd
