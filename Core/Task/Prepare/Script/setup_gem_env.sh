#!/bin/sh

#  setup_gem_env.sh
#  Package
#
#  Created by Whirlwind on 16/5/3.
#  Copyright © 2016年 taobao. All rights reserved.

exe() {
    echo "> $@"
    "$@"

    if [[ $? != 0 ]]; then
        exit 1
    fi
}

BUNDLEDIR="$(dirname "$BUNDLE_GEMFILE")"
GEMENVDIR="./GemEnv"

mkdir -p "$BUNDLEDIR"
exe rsync -av "$GEMENVDIR"/ "$BUNDLEDIR"

check=$(bundle check)
if [[ $? != 0 ]]; then
    exe bundle install --local
fi

exe bundle clean
