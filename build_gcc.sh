#!/usr/bin/bash

build_binutils ()
{
	mkdir -p "$BUILDDIR/$BINUTILS"
	cd "$BUILDDIR/$BINUTILS"

	$SRCDIR/$BINUTILS/configure \
		--prefix=$PREFIX \
		--target=$TARGET \
		--disable-multilib \
		--with-cpu=$TARGET_CPU \
		--disable-nls \
		--host=$HOST \
		--build=$BUILD

	make -j"$(nproc)"
	make install-strip
}

build_gcc ()
{
	cd $SRCDIR/$GCC
	./contrib/download_prerequisites

	mkdir -p "$BUILDDIR/$GCC"
	cd "$BUILDDIR/$GCC"

	export CPPFLAGS="-I$BUILDDIR/$BINUTILS/zlib -L$BUILDDIR/$BINUTILS/zlib"
	../../src/$GCC/configure \
		--prefix=$PREFIX \
		--target=$TARGET \
		--enable-languages=c \
		--enable-lto \
		--with-cpu=$TARGET_CPU \
		--without-newlib \
		--with-libgloss \
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
		--host=$HOST \
		--build=$BUILD \
		--disable-testsuite

	make -j"$(nproc)" all-gcc
	make install-strip-gcc

	make -j"$(nproc)" all-target-libgcc
	make install-target-libgcc
}

_binu_ver=2.40
_gcc_ver=13.2.0

TARGET=m68k-elf
TARGET_CPU=m68000

BASEDIR=$PWD
BINUTILS=binutils-${_binu_ver}
GCC=gcc-${_gcc_ver}

SRCDIR="$BASEDIR/src"
BUILDDIR="$BASEDIR/build"
INSTALLDIR="$BASEDIR/install"

mkdir -p "$SRCDIR"
mkdir -p "$BUILDDIR"
mkdir -p "$INSTALLDIR"

cd "$SRCDIR"
if ! [ -d "$SRCDIR/$BINUTILS" ]; then
	wget http://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.gz -O - | tar -xz
fi
if ! [ -d "$SRCDIR/$GCC" ]; then
	wget http://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.gz  -O - | tar -xz
fi

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
fi

# Remove native builds and start the mingw32 cross-compile
rm -rf "$BUILDDIR/$GCC"
rm -rf "$BUILDDIR/$BINUTILS"

HOST=i686-w64-mingw32
PREFIX="$INSTALLDIR/$HOST/$TARGET"
build_binutils
build_gcc

rm -rf "$INSTALLDIR/$HOST/$TARGET/share"
rm -rf "$INSTALLDIR/$BUILD/$TARGET/share"

cd "$INSTALLDIR"
tar cfz ${BASEDIR}/mingw32.tgz ./$HOST
tar cfz ${BASEDIR}/ubuntu.tgz ./$BUILD
