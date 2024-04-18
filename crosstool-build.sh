#!/usr/bin/bash
BASEDIR=$PWD
HOST=i686-w64-mingw32
TARGET=m68k-elf

cd crosstool-ng
./bootstrap && ./configure --enable-local
make
export PATH=$PWD:$PATH
cd ..

CT_EXPERIMENTAL=y
CT_ALLOW_BUILD_AS_ROOT=y
CT_ALLOW_BUILD_AS_ROOT_SURE=y

ct-ng $TARGET
ct-ng build

ct-ng $HOST,$TARGET
ct-ng build

cd ~/x-tools
echo "Creating $BASEDIR/m68k-elf.tgz" 
tar cvfz $BASEDIR/$TARGET.tgz $TARGET


# Setup path to pickup DLL files
#export PATH=/usr/lib/gcc/$HOST/10-win32:$PATH
#cd ~/x-tools/HOST-$HOST/$TARGET/bin
#strings * | grep  ".*\\.dll" | sort | uniq | xargs which 2> /dev/null | grep "mingw" | xargs -I _ cp _ .
#strings * | grep  ".*\\.dll" | sort | uniq | xargs which 2> /dev/null | grep "mingw" | xargs -I _ cp _ .

cd ~/x-tools/HOST-$HOST
echo "Creating $BASEDIR/$HOST.zip" 
zip -ry $BASEDIR/$HOST.zip $TARGET

cd $BASEDIR

# For github actions
if [ "$GITHUB_ENV" != "" ]; then
	echo "MINGW_FILE=$HOST.zip" >> "$GITHUB_ENV"
	echo "UBUNTU_FILE=$TARGET.tgz" >> "$GITHUB_ENV"
fi
