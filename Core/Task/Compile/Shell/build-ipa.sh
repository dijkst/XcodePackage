#!/bin/sh

#  build-ipa.sh
#  Package
#
#  Created by Whirlwind on 15/5/6.
#  Copyright (c) 2015年 taobao. All rights reserved.
#
#  Usage:
#   ./build.sh ProjectPath Scheme Configuration
#

PROJECT_PATH=$1
SCHEME=$2
CONFIGURATION=$3
XCCONFIG=$4


exe() {
    echo "> $@"
    "$@"

    if [[ $? != 0 ]]; then
        exit 1
    fi
}

CONFIG_FILE="$(dirname $0)/build-ipa.xcconfig"

cd "$(dirname "$PROJECT_PATH")"

if [ `basename "$PROJECT_PATH"` == *.xcworkspace ]; then
    args="-workspace"
else
    args="-project"
fi


# archive
xcodebuild $args "$PROJECT_PATH" -configuration $CONFIGURATION -hideShellScriptEnvironment ARCHS="armv7 arm64" STRIP_INSTALLED_PRODUCT=NO SKIP_INSTALL=NO DSTROOT= INSTALL_PATH="$(pwd)/build/iphoneos" -xcconfig "$CONFIG_FILE"  $XCCONFIG -scheme "$SCHEME" -sdk iphoneos archive

#set -o pipefail && xcodebuild $args "$PROJECT_PATH" -configuration $CONFIGURATION -hideShellScriptEnvironment ARCHS="armv7 arm64" STRIP_INSTALLED_PRODUCT=NO -xcconfig "$CONFIG_FILE" -scheme "$SCHEME" -sdk iphoneos -archivePath "$(pwd)/build/iphoneos/archive.xcarchive"  archive | bundle exec xcpretty
if [ "$?" != "0" ]; then
    exit 1
fi



# Export the archive to an ipa
#xcodebuild \
#-exportArchive \
#-archivePath "$(pwd)/build/iphoneos/archive.xcarchive" \
#-exportPath "$(pwd)/build/iphoneos"
cd build/iphoneos
for app in *.app
do
    filename="${app%.*}"
    exe xcrun -sdk iphoneos PackageApplication -v "${app}" -o "${filename}.ipa"
# --sign \"iPhone Distribution: My Company Pte Ltd (XCDEFV)"
done

