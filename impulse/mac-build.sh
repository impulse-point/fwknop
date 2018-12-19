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
clang -target x86_64-apple-darwin $OPTS $SOURCES -o $OUT_DIR_MAC/$OUTPUT.x86_64

echo "Building $OUT_DIR_IOS/$OUTPUT.simulator"
clang -target x86_64-apple-darwin -miphoneos-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk $OPTS $SOURCES -o $OUT_DIR_IOS/$OUTPUT.simulator

echo "Building $OUT_DIR_IOS/$OUTPUT.ios"
clang -target arm64-apple-darwin -miphoneos-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk $OPTS $SOURCES -o $OUT_DIR_IOS/$OUTPUT.ios

echo "Combining $OUT_DIR_IOS/$OUTPUT.simulator and $OUT_DIR_IOS/$OUTPUT.ios into $OUT_DIR_IOS/$OUTPUT"
lipo $OUT_DIR_IOS/$OUTPUT.* -output $OUT_DIR_IOS/$OUTPUT -create

popd