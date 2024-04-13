#!/usr/bin/bash
set -e

build_binutils ()
{
	mkdir -p "$BUILDDIR/$BINUTILS"
	cd "$BUILDDIR/$BINUTILS"

	$SRCDIR/$BINUTILS/configure \
		--prefix=$PREFIX \
		--target=$TARGET \
		--with-cpu=$TARGET_CPU \
		--disable-multilib \
		--disable-nls

	make configure-host
	make -j"$(nproc)" LDFLAGS="-all-static"
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
		--enable-static \
		--disable-multilib \
		--disable-libgcj \
		--disable-libstdcxx \
		--disable-gcov \
		--without-headers \
		--without-included-gettext \
		--disable-testsuite

	make configure-host

	make -j"$(nproc)" all-gcc LDFLAGS="-static"
	make install-strip-gcc

	make -j"$(nproc)" all-target-libgcc
	make install-target-libgcc

	make -j"$(nproc)"
	make install-strip
}

_binu_ver=2.40
_gcc_ver=13.2.0
_newlib_ver=4.4.0.20231231

TARGET=m68k-elf
TARGET_CPU=m68000

BASEDIR=$PWD
BINUTILS=binutils-${_binu_ver}
GCC=gcc-${_gcc_ver}
NEWLIB=newlib-${_newlib_ver}

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
fi

PREFIX="$INSTALLDIR/$TARGET"
export PATH=$PREFIX/bin:$PATH
build_binutils
build_gcc

cd "$PREFIX/bin"
strings * | grep  ".\\.dll" | sort | uniq | xargs which 2> /dev/null | grep "/mingw" | xargs -I _ cp _ .
strings * | grep  ".\\.dll" | sort | uniq | xargs which 2> /dev/null | grep "/mingw" | xargs -I _ cp _ .

rm -rf "$INSTALLDIR/$TARGET/share"

cd "$INSTALLDIR"
tar cfz ${BASEDIR}/mingw32.tgz ./$TARGET

