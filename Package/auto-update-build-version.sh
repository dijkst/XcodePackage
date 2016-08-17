#!/bin/sh

#   auto-update-build-version.sh
#
#   自动修改 Build 号为当前时间
#
#   将 当前时间/Git提交时间 格式化为 年月日时分 的格式，保存到输出的 Info.plist 中，不修改项目的 Build 配置。
#
#   使用方法：
#       1. 将该脚本加入项目的某个目录下，不需要添加到 Xcode。
#       2. 在 Xcode 的对应项目 target -> Build Phases，添加一个 Shell 到最后：
#           "${SRCROOT}/脚本相对路径"
#

INFOPLISTPATH="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

if [ $1 == "GIT" ]; then
#   Apple Git 不支持日期格式化！！
#    DATE=$(git show -s --format=%cd --date=format:"%y%m%d%H%M" HEAD)
    DATE=`date -jf "%Y-%m-%d %H:%M:%S %z" "$(git show -s --format=%ci HEAD)" +%y%m%d%H%M`
else
    DATE=`date +%y%m%d%H%M`
fi

defaults write "${INFOPLISTPATH}" CFBundleVersion "$DATE"
