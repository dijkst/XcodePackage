#!/bin/bash

set -x

P12_PATH=$1
P12_PASS=$2

# 创建专属钥匙串
security create-keychain -p "$CODESIGN_KEYCHAIN_PASSWORD" "$CODESIGN_KEYCHAIN" 1>/dev/null 2>&1

# 设置钥匙串搜索优先级
security list-keychains -d user -s "$CODESIGN_KEYCHAIN" login.keychain 1>/dev/null 2>&1

# 解锁钥匙串
security unlock-keychain -p "$CODESIGN_KEYCHAIN_PASSWORD" "$CODESIGN_KEYCHAIN"

# 导入 P12 文件到钥匙串
security import "$P12_PATH" -k "$CODESIGN_KEYCHAIN" -P "$P12_PASS" -T /usr/bin/codesign 1>/dev/null

# 设置超时时长
#security set-keychain-settings -lut 7200 "$KEYCHAIN"

# 防止签名弹出“允许访问钥匙串”对话框
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$CODESIGN_KEYCHAIN_PASSWORD" "$CODESIGN_KEYCHAIN" 1>/dev/null 2>&1

# 获取 P12 SHA1 指纹码
openssl pkcs12 -in "$P12_PATH" -passin pass:$P12_PASS -nodes 2>/dev/null| openssl x509 -noout -fingerprint 2>/dev/null
