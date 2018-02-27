#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR=$(dirname $DIR)
BUILD_DIR=$(dirname $DIR)/build

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
pushd $BUILD_DIR

OPTS="-I../lib -I../common -I/usr/include/machine -include ../iphone/Classes/config.h -include sys/_types.h -dynamiclib"
SOURCES="`find ../{lib,common} -name '*.c' | grep -v fko_utests.c`"
OUTPUT=libfko.dylib

echo -e "Found source files:\n$SOURCES"

echo "Building $OUTPUT.x86_64"
clang -target x86_64-apple-darwin $OPTS $SOURCES -o $OUTPUT.x86_64

echo "Building $OUTPUT.i386"
clang -target i386-apple-darwin $OPTS $SOURCES -o $OUTPUT.i386

# theoretically, but won't compile for device, and untested anyway
# clang -target x86_64-apple-darwin -miphoneos-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk $OPTS $SOURCES -o $OUTPUT.simulator
# clang -target arm64-apple-darwin -miphoneos-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk $OPTS $SOURCES -o $OUTPUT.ios

echo "Combining output into fat library: $OUTPUT"
lipo $OUTPUT.* -output $OUTPUT -create

popd