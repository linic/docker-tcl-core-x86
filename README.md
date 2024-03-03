# docker-tcl-core-x86

Forked from [innovarew/docker-tinycore](https://github.com/innovarew/docker-tinycore/tree/main)
[Docker](https://www.docker.com) from scratch image of [Tinycore Linux](http://www.tinycorelinux.net) Core x86 version.
I was able to generate 1 image [linichotmailca/tcl-core-x86:14.x-x86](https://hub.docker.com/layers/linichotmailca/tcl-core-x86/14.x-x86/images/sha256-91db888ce3030f8d481cfc645b8166412ef5a74ff7c16fdbc9fa55df431737a0?context=repo)

# How did I get there?

1. I forked from [innovarew/docker-tinycore](https://github.com/innovarew/docker-tinycore/tree/main)
2. I removed all the data files.
3. I read the scripts/tc-docker; replaced the x86_64 to x86; replaced `corepure64.gz` to `core.gz`; added some contants; and some more modifications (see the `git log`)
4. Re-added the [rootfs-14.x-x86_64.patch](https://github.com/innovarew/docker-tinycore/blob/main/data/rootfs-14.x-x86_64.patch) as `rootfs-14.x-x86.patch`
5. I didn't feel like running `make rootfs` as `sudo` so I `sudo docker pull ubuntu`, `sudo docker image list`, `sudo docker run --name ubuntu-tcl-builder --interactive --entrypoint bash <replace-with-your-image-id>`
6. Then, in the ubuntu container:
```
apt update
apt dist-upgrade
apt install git
apt install squashfs-tools
apt install build-essential
git clone https://github.com/linic/docker-tcl-core-x86.git
apt install vim
apt install p7zip-full p7zip-rar
apt install wget
apt install cpio
make rootfs
cd data
sha512sum rootfs-14.x-x86.tar.xz
```
7. Then, on the host, 
```
git clone https://github.com/linic/docker-tcl-core-x86.git
cd docker-tcl-core-x86/data
sudo docker cp ubuntu-tcl-builder:/root/docker-tcl-core-x86/data/rootfs-14.x-x86.tar.xz .
sha512sum rootfs-14.x-x86.tar.xz  # just to make sure the file was good
```
8. [rootfs-14.x-x86.tar.xz](https://github.com/linic/docker-tcl-core-x86/blob/main/data/rootfs-14.x-x86.tar.xz)
9. Back on the host, 
```
sudo docker build --build-arg TC_VER="14.x-x86" -t tcl-core-x86:14.x-x86 -t tcl-core-x86:latest .
sudo docker image list
sudo docker run --name tcl-core-x86-test --interactive <replace-with-your-image-id> /bin/sh 
cat /etc/os-release 
NAME=TinyCore
VERSION="14.0"
ID=tinycore
VERSION_ID=14.0
PRETTY_NAME="TinyCoreLinux 14.0"
ANSI_COLOR="0;34"
CPE_NAME="cpe:/o:tinycore:tinycore_linux:14.0"
HOME_URL="http://tinycorelinux.net/"
SUPPORT_URL="http://forum.tinycorelinux.net/"
BUG_REPORT_URL="http://forum.tinycorelinux.net/
```
10. [linichotmailca/tcl-core-x86:14.x-x86](https://hub.docker.com/layers/linichotmailca/tcl-core-x86/14.x-x86/images/sha256-91db888ce3030f8d481cfc645b8166412ef5a74ff7c16fdbc9fa55df431737a0?context=repo)

# Thanks to [@innovarew](https://github.com/innovarew)! You're awesome!

# TODO

More testing to see how I can leverage this container more in my side projects.

