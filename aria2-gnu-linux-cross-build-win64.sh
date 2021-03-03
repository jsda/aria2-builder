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
OUTPUT_DIR="$HOME/output"
PREFIX="$BUILD_DIR/aria2-cross-build-libs-$HOST"
ARIA2_PREFIX="/usr/local"
export CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export LD_LIBRARY_PATH="$PREFIX/lib"
export CC="$HOST-gcc"
export CXX="$HOST-g++"
export STRIP="$HOST-strip"
export RANLIB="$HOST-ranlib"
export AR="$HOST-ar"
export LD="$HOST-ld"

## DEPENDENCES ##
source $SCRIPT_DIR/dependences

DEBIAN_INSTALL() {
    $SUDO apt-get update
    $SUDO apt-get -y install build-essential libgnutls28-dev nettle-dev libgmp-dev \
    libssh2-1-dev libc-ares-dev libxml2-dev zlib1g-dev libsqlite3-dev pkg-config \
    libcppunit-dev autoconf automake autotools-dev autopoint libtool git gcc g++ \
    quilt openssl libgcrypt-dev libssl-dev gcc-mingw-w64 g++-mingw-w64 zip
}

FEDORA_INSTALL() {
    $SUDO dnf install -y make gcc gcc-c++ kernel-devel libgcrypt-devel git curl ca-certificates bzip2 xz findutils \
        libxml2-devel cppunit autoconf automake gettext-devel libtool pkg-config dpkg
}

ARCH_INSTALL() {
    $SUDO pacman -Syu --noconfirm base-devel git dpkg
}

TOOLCHAIN() {
    if [ -x "$(command -v apt-get)" ]; then
        DEBIAN_INSTALL
    elif [ -x "$(command -v dnf)" ]; then
        FEDORA_INSTALL
    elif [ -x "$(command -v pacman)" ]; then
        ARCH_INSTALL
    else
        echo -e "This operating system is not supported !"
        exit 1
    fi
}

ZLIB_BUILD() {
    mkdir -p $BUILD_DIR/zlib && cd $BUILD_DIR/zlib
    curl -Ls -o - "$ZLIB" | tar zxvf - --strip-components=1
    ./configure \
        --prefix=$PREFIX \
        --static
    make install -j$(nproc)
}

EXPAT_BUILD() {
    mkdir -p $BUILD_DIR/expat && cd $BUILD_DIR/expat
    curl -Ls -o - "$EXPAT" | tar jxvf - --strip-components=1
    ./configure \
        --prefix=$PREFIX \
        --host=$HOST \
        --enable-static \
        --enable-shared
    make install -j$(nproc)
}

C_ARES_BUILD() {
    mkdir -p $BUILD_DIR/c-ares && cd $BUILD_DIR/c-ares
    curl -Ls -o - "$C_ARES" | tar zxvf - --strip-components=1
    ./configure \
        --prefix=$PREFIX \
        --host=$HOST \
        --enable-static \
        --disable-shared
    make install -i
}

OPENSSL_BUILD() {
    mkdir -p $BUILD_DIR/openssl && cd $BUILD_DIR/openssl
    curl -Ls -o - "$OPENSSL" | tar zxvf - --strip-components=1
    ./Configure \
        --prefix=$PREFIX \
        --openssldir=ssl \
        $OPENSSL_ARCH \
        no-asm \
        shared
    make install -i
}

SQLITE3_BUILD() {
    mkdir -p $BUILD_DIR/sqlite3 && cd $BUILD_DIR/sqlite3
    curl -Ls -o - "$SQLITE3" | tar zxvf - --strip-components=1
    ./configure \
        --prefix=$PREFIX \
        --host=$HOST \
        --enable-static \
        --enable-shared
    make install -j$(nproc)
}

LIBSSH2_BUILD() {
    mkdir -p $BUILD_DIR/libssh2 && cd $BUILD_DIR/libssh2
    curl -Ls -o - "$LIBSSH2" | tar zxvf - --strip-components=1
    rm -rf $PREFIX/lib/pkgconfig/libssh2.pc
    ./configure \
        --prefix=$PREFIX \
        --host=$HOST \
        --enable-static \
        --disable-shared
        CPPFLAGS="-I$PREFIX/include" \
        LDFLAGS="-L$PREFIX/lib"
    make install -j$(nproc)
}

ARIA2_SOURCE() {
    [ -e $BUILD_DIR/aria2 ] && {
        cd $BUILD_DIR/aria2
        git reset --hard origin || git reset --hard
        git pull
    } || {
        git clone https://github.com/aria2/aria2 $BUILD_DIR/aria2
        cd $BUILD_DIR/aria2
    }
    autoreconf -i
    $ARIA2_VER=master
}

ARIA2_RELEASE() {
    [ -e "$ARIA2_VER" ] ||
        ARIA2_VER=$(curl -fsSL https://api.github.com/repos/aria2/aria2/releases | grep -o '"tag_name": ".*"' | head -n 1 | sed 's/"//g;s/v//g' | sed 's/tag_name: //g')
    mkdir -p $BUILD_DIR/aria2 && cd $BUILD_DIR/aria2
    ARIA2_VER=${ARIA2_VER#*-}
    curl -Ls -o - "https://github.com/aria2/aria2/releases/download/release-${ARIA2_VER}/aria2-${ARIA2_VER}.tar.xz" |
        tar Jxvf - --strip-components=1
}

ARIA2_BUILD() {
    ARIA2_RELEASE || ARIA2_SOURCE
    ./configure \
        --host=$HOST \
        --prefix=$PREFIX \
        --without-included-gettext \
        --disable-nls \
        --with-libcares \
        --without-gnutls \
        --without-wintls \
        --with-openssl \
        --with-sqlite3 \
        --without-libxml2 \
        --with-libexpat \
        --with-libz \
        --without-libgmp \
        --with-libssh2 \
        --without-libgcrypt \
        --without-libnettle \
#        --without-jemalloc \
        --with-cppunit-prefix=$PREFIX \
        ARIA2_STATIC=yes \
        --disable-shared \
        CPPFLAGS="-I$PREFIX/include" \
        LDFLAGS="-L$PREFIX/lib" \
        PKG_CONFIG="/usr/bin/pkg-config" \
        PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
    make
}

ARIA2_PACKAGE() {
    ARIA2_VER=$(curl --silent "https://api.github.com/repos/aria2/aria2/releases/latest" | grep '"tag_name":' | sed -E 's/.*"release-([^"]+)".*/\1/')
    dpkgARCH=64bit
    cd $BUILD_DIR/aria2/src
    strip aria2c.exe
    mkdir -p $OUTPUT_DIR
    cp aria2c.exe $OUTPUT_DIR
}

CLEANUP_SRC() {
    cd $BUILD_DIR
    rm -rf \
        zlib \
        expat \
        c-ares \
        openssl \
        sqlite3 \
        libssh2 \
        aria2
}

CLEANUP_LIB() {
    rm -rf $PREFIX
}

CLEANUP_ALL() {
    CLEANUP_SRC
    CLEANUP_LIB
}

## BUILD ##
TOOLCHAIN
ZLIB_BUILD
EXPAT_BUILD
C_ARES_BUILD
OPENSSL_BUILD
SQLITE3_BUILD
LIBSSH2_BUILD
ARIA2_BUILD
ARIA2_PACKAGE
CLEANUP_ALL

echo "finished!"
