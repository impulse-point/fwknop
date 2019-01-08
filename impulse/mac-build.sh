#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR=$(dirname $DIR)
BUILD_DIR=$(dirname $DIR)/build

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
pushd $BUILD_DIR

OUT_DIR_MAC=mac
OUT_DIR_IOS=ios
mkdir -p $OUT_DIR_MAC
mkdir -p $OUT_DIR_IOS

OPTS="-I../lib -I../common -I/usr/include/machine -include ../iphone/Classes/config.h -include sys/_types.h -dynamiclib"
SOURCES="`find ../{lib,common,.swig} -name '*.c' | grep -v fko_utests.c`"
OUTPUT=libfko.dylib

echo -e "Found source files:\n$SOURCES"

echo "Building $OUT_DIR_MAC/$OUTPUT"
clang -target x86_64-apple-darwin $OPTS $SOURCES -o $OUT_DIR_MAC/$OUTPUT

echo "Building $OUT_DIR_IOS/$OUTPUT.simulator"
clang -target x86_64-apple-darwin -miphoneos-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk $OPTS $SOURCES -o $OUT_DIR_IOS/$OUTPUT.simulator
TPUT.simulator

echo "Building $OUT_DIR_IOS/$OUTPUT.ios.armv7"
clang -target armv7-apple-darwin -miphoneos-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk $OPTS $SOURCES -o $OUT_DIR_IOS/$OUTPUT.ios.armv7

echo "Building $OUT_DIR_IOS/$OUTPUT.ios.armv7s"
clang -target armv7s-apple-darwin -miphoneos-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk $OPTS $SOURCES -o $OUT_DIR_IOS/$OUTPUT.ios.armv7s

echo "Building $OUT_DIR_IOS/$OUTPUT.ios.arm64"
clang -target arm64-apple-darwin -miphoneos-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk $OPTS $SOURCES -o $OUT_DIR_IOS/$OUTPUT.ios.arm64

echo "Listing outputs"
file $OUT_DIR_IOS/$OUTPUT.*

echo "Combining all outputs into $OUT_DIR_IOS/$OUTPUT"
lipo $OUT_DIR_IOS/$OUTPUT.* -output $OUT_DIR_IOS/$OUTPUT -create

popd