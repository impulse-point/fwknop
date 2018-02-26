This is a fork of (https://github.com/mrash/fwknop).

The purpose of this fork is to provide additional build scripts and configuration files required to produce redistributable library files for various platforms. It also contain project files to build a C# wrapper around this library.

----

The following are my notes from figuring this process out. The actual build steps are on our local bamboo cluster, but these notes represent my experiments figuring out how to configure that. It is left as future work to clean this up for public consumption.

Windows:

```
# working under Visual Studio 2017 (presumably requires 2015 tools installed)
# requires git bash and swig
# TODO move patch file somewhere other than my virtualbox shared folder mount (which is apparently E:)
# TODO move libfko.i file somewhere

# git bash
# cd work dir
git clone https://github.com/impulse-point/fwknop.git

# cmd
vcvarsall.bat x64
# cd work dir after vcvarsall moves you

# cmd
devenv fwknop\win32\libfko.vcproj /upgrade

# git bash
mkdir fwknop/.swig
pushd fwknop/.swig
swig -csharp -I../lib -I../win32 -outcurrentdir ../impulse/libfko.i
popd

# git bash
patch fwknop/win32/libfko.vcxproj fwknop/impulse/libfko.vcxproj.patch

# cmd
# https://stackoverflow.com/a/33386141/9290998
# v140 = Visual Studio 2015
# configurations: Release, Release-static, Release-full-static
msbuild fwknop\win32\libfko.vcxproj /p:Platform=Win32 /p:Configuration=Release /p:PlatformToolset=v140
msbuild fwknop\win32\libfko.vcxproj /p:Platform=x64 /p:Configuration=Release /p:PlatformToolset=v140

# output is at
# fwknop/win32/Release/Win32/libfko.dll
# fwknop/win32/Release/x64/libfko.dll

# cmd
cd fwknop\impulse\Fwknop
dotnet restore /p:Platform="Any CPU"
msbuild Fwknop.sln /t:Fwknop:rebuild /p:Platform="Any CPU" /p:Configuration=Release
msbuild Fwknop.sln /t:FwknopDotNetStandard:rebuild /p:Platform="Any CPU" /p:Configuration=Release

# output is at
# fwknop/impulse/Fwknop/Fwknop/bin/Release/Fwknop.dll
# fwknop/impulse/Fwknop/Fwknop/bin/Release/Fwknop.pdb

# bash
mkdir -p fwknop/.build/sources
mkdir -p fwknop/.build/win/{x86,x64}
mkdir -p fwknop/.build/mac
mkdir -p fwknop/.build/csharp/{classic,standard}
cp fwknop/.swig/*.cs fwknop/.build/sources/
cp fwknop/win32/Release/Win32/libfko.dll fwknop/.build/win/x86/
cp fwknop/win32/Release/x64/libfko.dll fwknop/.build/win/x64/
cp <MAC DYLIB> fwknop/.build/mac/
cp fwknop/impulse/Fwknop/Fwknop/bin/Release/Fwknop.{dll,pdb} fwknop/.build/csharp/classic
cp fwknop/impulse/Fwknop/FwknopDotNetStandard/bin/Release/netstandard2.0/Fwknop.{dll,pdb} fwknop/.build/csharp/standard

# cmd
nuget pack fwknop\impulse\Fwknop.nuspec
nuget push Fwknop.9.9.9.nupkg -Source Artifactory
```

Mac:

```
had to install extra command line tools?
xcode-select --install

git clone https://github.com/impulse-point/fwknop.git

rm -rf build
mkdir build
pushd build
OPTS="-I../fwknop/lib -I../fwknop/common -I/usr/include/machine -include ../fwknop/iphone/Classes/config.h -dynamiclib"
SOURCES="`find ../fwknop/{lib,common} -name '*.c' | grep -v fko_utests.c`"
OUTPUT=libfko.dylib
SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk
SDK_DIR="$SDKROOT"
clang -target x86_64-apple-darwin $OPTS $SOURCES -o $OUTPUT.x86_64
clang -target i386-apple-darwin $OPTS $SOURCES -o $OUTPUT.i386
# theoretically, but won't compile for device, and untested anyway
# clang -target x86_64-apple-darwin -miphoneos-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk $OPTS $SOURCES -o $OUTPUT.simulator
# clang -target arm64-apple-darwin -miphoneos-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk $OPTS $SOURCES -o $OUTPUT.ios
lipo $OUTPUT.* -output $OUTPUT -create
popd
```