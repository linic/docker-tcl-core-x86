# Set tinycore release
TCL_RELEASE="15.x"
TCL_ARCHITECTURE="x86"
TC_URL=http://tinycorelinux.net/$TCL_RELEASE/$TCL_ARCHITECTURE/
TC_VER=$TCL_RELEASE-$TCL_ARCHITECTURE

all: rootfs build run

rootfs:
	scripts/tc-docker tce_rootfs_init
build:
	docker build --build-arg TC_VER=${TC_VER} -t tcl-core-x86:${TC_VER} -t tcl-core-x86:latest .
run:
	docker run -it tcl-core-x86:latest /bin/sh
