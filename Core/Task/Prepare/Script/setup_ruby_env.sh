#!/bin/sh

#  setup_ruby_env.sh
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

UPDATEGEM=""
UPDATEBUNDLER=""

while [[ $# > 1 ]]
do
    key="$1"

    case $key in
        -gem)
            UPDATEGEM=$2
            shift # past argument
        ;;
        -bundler)
            UPDATEBUNDLER=$2
            shift # past argument
        ;;
        *)
            # unknown option
        ;;
    esac
    shift # past argument or value
done

binPath=""
if [[ `id -u` -eq 0 ]] ; then
    binPath="-n /usr/local/bin"
fi

RubyEnv="$(pwd)/RubyEnv"

if [[ $UPDATEGEM != "" ]]; then
    cache=/Library/Caches/com.taobao.Package
    rm -rf $cache
    mkdir -p $cache
    exe cd "$RubyEnv"
    exe unzip -q "./rubygems-$UPDATEGEM.zip" -d $cache
    exe cd "$cache/rubygems-$UPDATEGEM"
    exe ruby setup.rb --no-document ri,rdoc --previous-version=$UPDATEGEM
    rm -rf $cache
fi

if [[ $UPDATEBUNDLER != "" ]]; then
    exe cd "$RubyEnv"
    exe gem install -l "./bundler-$UPDATEBUNDLER.gem" --no-document $binPath
    exe gem clean bundler
fi
