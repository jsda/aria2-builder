# Aria2 Builder

Aria2 static builds for GNU/Linux

## Downloads

![Aria2 Build](https://github.com/jsda/aria2-builder/workflows/Aria2%20Build/badge.svg?branch=master)

## 永久下载链接，每月自动更新
* [Aria2 amd64]
https://github.com/jsda/aria2-builder/raw/amd64/aria2-amd64.zip
* [Aria2 arm64]
https://github.com/jsda/aria2-builder/raw/arm64/aria2-arm64.zip
* [Aria2 armhf]
https://github.com/jsda/aria2-builder/raw/armhf/aria2-armhf.zip
* [Aria2 i386]
https://github.com/jsda/aria2-builder/raw/i386/aria2-i386.zip
* [Aria2 win64]
https://github.com/jsda/aria2-builder/raw/win64/aria2-win64.zip

### Manual installation
```shell
wget https://github.com/P3TERX/aria2-builder/releases/download/[version]/aria2-[version]-static-linux-[arch].tar.gz
tar zxvf aria2-[version]-static-linux-[arch].tar.gz
sudo mv aria2c /usr/local/bin
```

### Uninstall
```shell
sudo rm -f /usr/local/bin/aria2c
```

## Building

### with script

Download script, execute script.
> **TIPS:** In today's containerization of everything, this is not recommended.
```shell
git clone https://github.com/P3TERX/aria2-builder
cd aria2-builder
bash aria2-gnu-linux-build.sh
```

### with docker

> **TIPS:** Docker minimum version 19.03, you can also use [buildx](https://github.com/docker/buildx).

Build Aria2 for current architecture platforms.
```shell
DOCKER_BUILDKIT=1 docker build \
    -o type=local,dest=. \
    git://github.com/P3TERX/aria2-builder
```

**`dest`** can define the output directory. If there are no changes, two archive files will be generated in the current directory after the work is completed.
```
$ ls -l
-rw-r--r-- 1 p3terx p3terx 3744106 Jan 17 20:24 aria2-1.35.0-static-linux-amd64.tar.gz
-rw-r--r-- 1 p3terx p3terx 2931344 Jan 17 20:24 aria2-1.35.0-static-linux-amd64.tar.xz
```

Cross build Aria2 for other platforms, e.g.:
```
DOCKER_BUILDKIT=1 docker build \
    --build-arg BUILDER_IMAGE=ubuntu:14.04 \
    --build-arg BUILD_SCRIPT=aria2-gnu-linux-cross-build-armhf.sh \
    -o type=local,dest=. \
    git://github.com/P3TERX/aria2-builder
```
> **`BUILDER_IMAGE`** variable defines the system image used for the build. In general, platforms other than `armhf` don't require it.  
> **`BUILD_SCRIPT`** variable defines the script used for the cross build.

## External links

### Aria2

* [Aria2 homepage](https://aria2.github.io/)
* [Aria2 documentation](https://aria2.github.io/manual/en/html/)
* [Aria2 source code (Github)](https://github.com/aria2/aria2)

### Used external libraries

* [zlib](http://www.zlib.net/)
* [Expat](https://libexpat.github.io/)
* [c-ares](http://c-ares.haxx.se/)
* [SQLite](http://www.sqlite.org/)
* [OpenSSL](http://www.openssl.org/)
* [libssh2](http://www.libssh2.org/)

### Credits

* [q3aql/aria2-static-builds](https://github.com/q3aql/aria2-static-builds)

## Licence

[![GPLv3](https://www.gnu.org/graphics/gplv3-127x51.png)](https://github.com/P3TERX/aria2-builder/blob/master/LICENSE)

