#!/usr/bin/env bash
#===========================================================
# https://github.com/P3TERX/aria2-builder
# File name: aria2-gnu-linux-cross-build-win64.sh
# Description: Build aria2 on the target architecture
# System Required: Debian & Ubuntu & Fedora & Arch Linux
# Lisence: GPLv3
# Version: 1.1
# Author: P3TERX
# Blog: https://p3terx.com (chinese)
#===========================================================

set -e
[ $EUID != 0 ] && SUDO=sudo
$SUDO echo
SCRIPT_DIR=$(dirname $(readlink -f $0))

## CONFIG ##
ARCH="mingw64"
HOST="x86_64-w64-mingw32"
OPENSSL_ARCH="mingw64"
BUILD_DIR="/tmp"
ARIA2_CODE_DIR="$BUILD_DIR/aria2"
OUTPUT_DIR="$HOME/output"
PREFIX="$BUILD_DIR/aria2-cross-build-libs-$ARCH"
ARIA2_PREFIX="$HOME/aria2-local"
export CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export LD_LIBRARY_PATH="$PREFIX/lib"
export CFLAGS+=" -flto -O3"
export CC="$HOST-gcc"
export CXX="$HOST-g++"
export STRIP="$HOST-strip"
export RANLIB="$HOST-ranlib"
export AR="$HOST-ar"
export LD="$HOST-ld"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export PKG_CONFIG="/usr/bin/pkg-config"

## DEPENDENCES ##
source $SCRIPT_DIR/dependences

DEBIAN_INSTALL() {
    $SUDO apt-get update
    $SUDO apt-get -yqq install \
		make binutils autoconf automake autotools-dev libtool \
		patch ca-certificates \
		libgnutls28-dev nettle-dev libgmp-dev libxml2-dev gcc g++ quilt libgcrypt-dev libssl-dev docbook2x gawk \
		pkg-config git curl dpkg-dev gcc-mingw-w64 g++-mingw-w64 \
		autopoint libcppunit-dev libxml2-dev libgcrypt20-dev lzip \
		python3-docutils
}

## BUILD ##
source $SCRIPT_DIR/snippet/cross-build-win

## ARIA2 COEDE ##
source $SCRIPT_DIR/snippet/aria2-code

## ARIA2 BIN ##
source $SCRIPT_DIR/snippet/aria2-bin

## CLEAN ##
source $SCRIPT_DIR/snippet/clean

ARIA2_BUILD-win() {
    ARIA2_CODE_GET
    ./configure \
        --host=$HOST \
        --prefix=$$PREFIX \
        --without-included-gettext \
        --disable-nls \
        --with-libcares \
        --without-gnutls \
        --without-openssl \
        --with-sqlite3 \
        --without-libxml2 \
        --with-libexpat \
        --with-libz \
        --without-libgmp \
        --with-libssh2 \
        --without-libgcrypt \
        --without-libnettle \
        --with-cppunit-prefix=$PREFIX \
        ARIA2_STATIC=yes \
     make -j$(nproc)
}

ARIA2_PACKAGE-win() {
    dpkgARCH=64bit
    cd $BUILD_DIR/aria2/src
    $STRIP aria2c.exe
    mkdir -p $OUTPUT_DIR
    mv aria2c.exe $OUTPUT_DIR
}

DEBIAN_INSTALL
#OPENSSL_BUILD
#ln -s $PREFIX/lib64 $PREFIX/lib
GMP_BUILD
ZLIB_BUILD
EXPAT_BUILD
C_ARES_BUILD
SQLITE3_BUILD
LIBSSH2_BUILD
#JEMALLOC_BUILD
ARIA2_BUILD-win
#ARIA2_BIN
ARIA2_PACKAGE-win
#ARIA2_INSTALL
CLEANUP_ALL

echo "finished!"
