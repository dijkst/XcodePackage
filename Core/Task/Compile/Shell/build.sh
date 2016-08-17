#!/bin/sh

#  build.sh
#  Package
#
#  Created by Whirlwind on 15/5/6.
#  Copyright (c) 2015年 taobao. All rights reserved.
#
#  Usage:
#   ./build.sh ProjectPath Scheme Configuration XcconfigSettings
#

PROJECT_PATH=$1
SCHEME=$2
CONFIGURATION=$3
XCCONFIG=$4

CONFIG_FILE="$(dirname $0)/build.xcconfig"
cd "$(dirname "$PROJECT_PATH")"

if [ `basename "$PROJECT_PATH"` == *.xcworkspace ]; then
    args="-workspace"
else
    args="-project"
fi

# build
set -o pipefail && xcodebuild $args "$PROJECT_PATH" -configuration $CONFIGURATION -hideShellScriptEnvironment ARCHS="i386 x86_64" CONFIGURATION_BUILD_DIR="$(pwd)/build/iphonesimulator" -xcconfig "$CONFIG_FILE" $XCCONFIG -scheme "$SCHEME" -sdk iphonesimulator build | bundle exec xcpretty
if [ "$?" != "0" ]; then
    exit 1
fi

# archive
set -o pipefail && xcodebuild $args "$PROJECT_PATH" -configuration $CONFIGURATION -hideShellScriptEnvironment ARCHS="armv7 arm64" STRIP_INSTALLED_PRODUCT=NO SKIP_INSTALL=NO DSTROOT= INSTALL_PATH="$(pwd)/build/iphoneos" -xcconfig "$CONFIG_FILE" $XCCONFIG -scheme "$SCHEME" -sdk iphoneos archive | bundle exec xcpretty
if [ "$?" != "0" ]; then
    exit 1
fi
