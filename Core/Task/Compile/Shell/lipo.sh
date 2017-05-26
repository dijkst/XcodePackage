#!/bin/sh

#  lipo.sh
#  Package
#
#  Created by Whirlwind on 16/3/14.
#  Copyright © 2016年 taobao. All rights reserved.
#
#  Usage:
#   ./lipo.sh
#

iphoneos="iphoneos"
iphonesimulator="iphonesimulator"

for os in os/*; do
    if ! [[ -d "$os" ]]; then
        continue
    fi
    echo $os
    dirname=$(basename $os)
    device="${dirname%*os}"
    simulator="simulator/${device}simulator"
    output="products/${device}"
    mkdir -p "$output/"
    for f in ${os}/*; do
        name=$(basename $f)
        product="$output/$name"
        if ! [[ -e "$simulator/$name" ]]; then
            continue
        fi
        if [[ -d "$f" ]]; then
            # 文件夹，例如 .framework
            filename="${name%.*}"
            if ! [[ -d "$product" ]]; then
                cp -r "$f" "$product"
            fi
            set -x && lipo -create "$f/$filename" "$simulator/$name/$filename" -output "$product/$filename"
        elif [[ -f "$f" ]]; then
            # 文件，例如 .a
            set -x && lipo -create "$f" "$simulator/$name" -output "$product"
        fi
    done
done
