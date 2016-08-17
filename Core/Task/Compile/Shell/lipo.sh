#!/bin/sh

#  lipo.sh
#  Package
#
#  Created by Whirlwind on 16/3/14.
#  Copyright © 2016年 taobao. All rights reserved.
#
#  Usage:
#   ./lipo.sh "xxx.framework" "yyy.a"
#

iphoneos="iphoneos"
iphonesimulator="iphonesimulator"
output="lipo"

# 合并framework
for name; do
    if [[ -d "$iphoneos/$name" ]]; then
        # 文件夹，例如 .framework
        filename="${name%.*}"
        if ! [[ -d "$output/$name" ]]; then
            cp -r "$iphoneos/$name" "$output/$name"
        fi
        set -x && lipo -create "$iphoneos/$name/$filename" "$iphonesimulator/$name/$filename" -output "$output/$name/$filename"
    elif [[ -f "$iphoneos/$name" ]]; then
        # 文件，例如 .a
        set -x && lipo -create "$iphoneos/$name" "$iphonesimulator/$name" -output "$output/$name"
    fi
done
