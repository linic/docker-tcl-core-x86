# docker-tcl-core-x86

Forked from [innovarew/docker-tinycore](https://github.com/innovarew/docker-tinycore/tree/main)
[Docker](https://www.docker.com) from scratch image of [Tinycore Linux](http://www.tinycorelinux.net) Core x86 version.
I was able to generate 2 images using the method almost unchanged
[linichotmailca/tcl-core-x86:14.x-x86](https://hub.docker.com/layers/linichotmailca/tcl-core-x86/14.x-x86/images/sha256-91db888ce3030f8d481cfc645b8166412ef5a74ff7c16fdbc9fa55df431737a0?context=repo)
[linichotmailca/tcl-core-x86:15.x-x86](https://hub.docker.com/layers/linichotmailca/tcl-core-x86/15.x-x86/images/sha256-eb68d3fa1ea004cd18cf7c7b0be9b86860d6293392c4c7da0208592593cab53e)

# Starting with 16.0beta1.x-x86

## rootfs.patch
There's a single [rootfs.patch](./rootfs.patch). It's used to patch the [rootfs.gz](http://repo.tinycorelinux.net/16.x/x86/release_candidates/distribution_files/).
I generated a new one by copying the `tce-load` script from `rootfs.gz` from 16.0beta1. I found that one line didn't apply anymore so the patch was giving out an error.
It changes `tce-load` so that it `unsquashfs` files to `/mnt/test` and then to `/`. I used `diff -u resource/tce-load-16.0beta1 resource/tce-load-16.0beta1.patched > data/rootfs.patch`

## patch-tcl-for-docker.sh
This script replaces the previous script which was [scripts/tc-docker](https://github.com/innovarew/docker-tinycore/blob/main/scripts/tc-docker).
`tc-docker` would use the `Core-current.iso` and remove the `.ko.gz` files which are
modules files (drivers which the kernel can load to make hardware like sound cards work). [patch-tcl-for-docker.sh](./tools/patch-tcl-for-docker.sh) uses
[rootfs.gz](http://repo.tinycorelinux.net/16.x/x86/release_candidates/distribution_files/) which does not have the module files. It's not feature equivalent
with `tc-docker`.

## Makefile
The new [Makefile](./Makefile) has more variables and allows to build images of alpha and beta releases. The difference is that pre-release versions will
have their [rootfs.gz](http://repo.tinycorelinux.net/16.x/x86/release_candidates/distribution_files/) in the `release_candidates` folder instead of the
`release` folder.

## Dockerfile
The [Dockerfile](./Dockerfile) uses the previous `tcl-core-x86` image has a resource to build the new image. For example, `16.x-x86` is built using
`15.x-x86`.

# Last build warnings
Just in case I need this in the future:
```
#8 0.187 sh: missing ]
#8 0.187 sh: missing ]
[...]
#8 8.604 Connecting to tinycorelinux.net (128.127.66.77:80)
#8 8.870 wget: server returned error: HTTP/1.1 404 Not Found
#8 8.940 Connecting to tinycorelinux.net (128.127.66.77:80)
#8 9.206 saving to 'libzstd.tcz'
#8 9.862 libzstd.tcz           58% |******************              |  176k  0:00:00 ETA
#8 10.19 libzstd.tcz          100% |********************************|  304k  0:00:00 ETA
#8 10.19 'libzstd.tcz' saved
[...]
#8 10.57 Connecting to tinycorelinux.net (128.127.66.77:80)
#8 10.82 wget: server returned error: HTTP/1.1 404 Not Found
#8 10.90 Connecting to tinycorelinux.net (128.127.66.77:80)
#8 11.13 saving to 'liblz4.tcz'
#8 11.36 liblz4.tcz           100% |********************************| 61440  0:00:00 ETA
#8 11.36 'liblz4.tcz' saved
[...]
#8 6.147 Connecting to tinycorelinux.net (128.127.66.77:80)
#8 6.376 wget: server returned error: HTTP/1.1 404 Not Found
#8 6.448 Connecting to tinycorelinux.net (128.127.66.77:80)
#8 6.681 saving to 'liblzma.tcz'
[...]
#8 7.414 Connecting to tinycorelinux.net (128.127.66.77:80)
#8 7.642 wget: server returned error: HTTP/1.1 404 Not Found
#8 7.714 Connecting to tinycorelinux.net (128.127.66.77:80)
#8 7.949 saving to 'lzo.tcz'
[...]
#8 8.604 Connecting to tinycorelinux.net (128.127.66.77:80)
#8 8.870 wget: server returned error: HTTP/1.1 404 Not Found
#8 8.940 Connecting to tinycorelinux.net (128.127.66.77:80)
#8 9.206 saving to 'libzstd.tcz'
[...]
#8 10.57 Connecting to tinycorelinux.net (128.127.66.77:80)
#8 10.82 wget: server returned error: HTTP/1.1 404 Not Found
#8 10.90 Connecting to tinycorelinux.net (128.127.66.77:80)
#8 11.13 saving to 'liblz4.tcz'
[...]
#10 [final 2/2] RUN NORTC=1 NOZSWAP=1 /etc/init.d/tc-config
#10 0.183 Booting Core 16.0beta1 
#10 0.183 Running Linux Kernel 5.10.0-34-amd64.
#10 0.183 Checking boot options... Done.
#10 0.184 Starting udev daemon for hotplug support... Done.
#10 0.287 Skipping compressed swap in ram as requested from the boot command line.
#10 0.287 Scanning hard disk partitions to create /etc/fstab 
#10 0.293 Setting Language to C Done.
#10 0.294 Skipping rtc as requested from the boot command line.
#10 0.294 hostname: sethostname: Operation not permitted
#10 0.295 ifconfig: SIOCSIFADDR: Operation not permitted
#10 0.296 route: SIOCADDRT: Operation not permitted
#10 0.327 Possible swap partition(s) enabled.
#10 0.331 Loading extensions... Done.
#10 0.432 Setting keymap to usloadkmap: can't open console
#10 0.433  Done.
#10 0.447 Setting hostname to box hostname: sethostname: Operation not permitted
#10 0.449 rm: can't remove '/etc/hosts': Device or resource busy
#10 0.449 /usr/bin/sethostname: line 15: can't create /etc/hosts: Read-only file system
#10 0.449 Done.
#10 DONE 0.5s
[...]
 1 warning found (use docker --debug to expand):
 - InvalidDefaultArgInFrom: Default value for ARG linichotmailca/tcl-core-x86:$PREVIOUS_DOCKER_TCL_VERSION results in empty or invalid base image name (line 8)
```
None of these prevent the build from completing and the image from starting.

# Historical
## 14.x-x86 and 15.x-x86 where generated this way.

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
8. [rootfs-14.x-x86.tar.xz](https://github.com/linic/docker-tcl-core-x86/blob/9dcce198e2c94b638092a57d048540a72ae0444a/data/rootfs-14.x-x86.tar.xz)
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

