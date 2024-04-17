#!/usr/bin/bash

#set -e

build_gdb ()
{
	mkdir -p "$BUILDDIR/$GDB"
	cd "$BUILDDIR/$GDB"


	$SRCDIR/$GDB/configure \
		--prefix=$PREFIX \
		--target=$TARGET \
		--with-cpu=$TARGET_CPU \
		--host=$HOST \
		--build=$BUILD \
		--with-static-standard-libraries

		make -j"$(nproc)"
		make install-strip
}

build_binutils ()
{
	mkdir -p "$BUILDDIR/$BINUTILS"
	cd "$BUILDDIR/$BINUTILS"

	$SRCDIR/$BINUTILS/configure \
		--prefix=$PREFIX \
		--target=$TARGET \
		--with-cpu=$TARGET_CPU \
		--host=$HOST \
		--build=$BUILD \
		--disable-multilib \
		--disable-nls

	make -j"$(nproc)"
	make install-strip
}

build_gcc ()
{
	mkdir -p "$BUILDDIR/$GCC"
	cd "$BUILDDIR/$GCC"

	export CPPFLAGS="-I$BUILDDIR/$BINUTILS/zlib -L$BUILDDIR/$BINUTILS/zlib"
	../../src/$GCC/configure \
		--prefix=$PREFIX \
		--target=$TARGET \
		--with-cpu=$TARGET_CPU \
		--host=$HOST \
		--build=$BUILD \
		--enable-languages=c \
		--enable-lto \
		--with-newlib \
		--without-libgloss \
		--disable-threads \
		--disable-libmudflap \
		--disable-libgomp \
		--disable-nls \
		--disable-werror \
		--disable-libssp \
		--disable-shared \
		--disable-multilib \
		--disable-libgcj \
		--disable-libstdcxx \
		--disable-gcov \
		--without-headers \
		--without-included-gettext \
		--disable-testsuite

	make -j"$(nproc)" all-gcc
	make install-strip-gcc

	make -j"$(nproc)" all-target-libgcc
	make install-target-libgcc

	make -j"$(nproc)"
	make install-strip
}

build_newlib ()
{
	echo "Building newlib"
	mkdir -p "$BUILDDIR/$NEWLIB"
	cd "$BUILDDIR/$NEWLIB"

	CFLAGS_FOR_TARGET="-Os -g -ffunction-sections -fdata-sections -fomit-frame-pointer -ffast-math"
	$SRCDIR/$NEWLIB/configure \
	--prefix=$INSTALLDIR/$TARGET \
	--target=$TARGET \
	--with-cpu=$TARGET_CPU \
	--enable-languages="c" \
	--disable-newlib-supplied-syscalls \
	--disable-multilib \
	--disable-nls

	make -j"$(nproc)"
	make install
	CFLAGS_FOR_TARGET=""

}

_binu_ver=2.40
_gcc_ver=13.2.0
_newlib_ver=4.4.0.20231231
_gdb_ver=14.2

TARGET=m68k-elf
TARGET_CPU=m68000

BASEDIR=$PWD
BINUTILS=binutils-${_binu_ver}
GCC=gcc-${_gcc_ver}
NEWLIB=newlib-${_newlib_ver}
GDB=gdb-${_gdb_ver}

SRCDIR="$BASEDIR/src"
BUILDDIR="$BASEDIR/build"
INSTALLDIR="$BASEDIR/install"

mkdir -p "$SRCDIR"
mkdir -p "$BUILDDIR"
mkdir -p "$INSTALLDIR"

cd "$SRCDIR"
if ! [ -d "$SRCDIR/$BINUTILS" ]; then
	wget --no-check-certificate https://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.gz -O - | tar -xz
fi
if ! [ -d "$SRCDIR/$GCC" ]; then
	wget --no-check-certificate https://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.gz  -O - | tar -xz
	cd $SRCDIR/$GCC
	./contrib/download_prerequisites
	cd "$SRCDIR"
fi
if ! [ -d "$SRCDIR/$NEWLIB" ]; then
	wget --no-check-certificate ftp://sourceware.org/pub/newlib/${NEWLIB}.tar.gz -O - | tar -xz
fi
if ! [ -d "$SRCDIR/$GDB" ]; then
	wget --no-check-certificate https://ftp.gnu.org/gnu/gdb/${GDB}.tar.gz -O - | tar -xz
fi

# Setup links for mpfr and gmp for building gdb
ln -s $SRCDIR/$GCC/mpfr-4.1.0 $SRCDIR/$GDB/mpfr
ln -s $SRCDIR/$GCC/gmp-6.2.1 $SRCDIR/$GDB/gmp

BUILD=`$SRCDIR/$BINUTILS/config.guess`

which ${TARGET}-gcc
if [ $? -ne 0 ]; then
	echo "Building native cross-compiler to help with build"
	# Build native compilers to help with the cross compile for mingw32
	HOST=$BUILD
	PREFIX="$INSTALLDIR/$HOST/$TARGET"
	export PATH=$PREFIX/bin:$PATH
	build_binutils
	build_gcc
	build_gdb
	rm -rf "$INSTALLDIR/$BUILD/$TARGET/share"
	cd "$INSTALLDIR"
	tar cfz ${BASEDIR}/$BUILD.tgz ./$BUILD
fi

# Remove native builds and start the mingw32 cross-compile
rm -rf "$BUILDDIR/$GCC"
rm -rf "$BUILDDIR/$BINUTILS"
rm -rf "$BUILDDIR/$GDB"

HOST=i686-w64-mingw32
PREFIX="$INSTALLDIR/$HOST/$TARGET"
build_binutils
build_gcc
build_gdb

rm -rf "$INSTALLDIR/$HOST/$TARGET/share"

# Setup path to pickup DLL files
export PATH=/usr/lib/gcc/$HOST/10-win32:$PATH
cd "$PREFIX/bin"
strings * | grep  ".*\\.dll" | sort | uniq | xargs which 2> /dev/null | grep "mingw" | xargs -I _ cp _ .

cd "$INSTALLDIR"
zip -r ${BASEDIR}/$HOST.zip ./$HOST

# For github actions
if [ "$GITHUB_ENV" != "" ]; then
	echo "MINGW_FILE=$HOST" >> "$GITHUB_ENV"
	echo "UBUNTU_FILE=$BUILD" >> "$GITHUB_ENV"
fi
