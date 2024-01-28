# Set tinycore release
TC_URL=http://tinycorelinux.net/14.x/x86/
TC_VER=$(shell echo "${TC_URL}" | awk -F/ '{print $$4"-"$$5}')

all: rootfs build run

rootfs:
	scripts/tc-docker tce_rootfs_init
build:
	docker build --build-arg TC_VER=${TC_VER} -t tcl-core-x86:${TC_VER} -t tcl-core-x86:latest .
run:
	docker run -it tcl-core-x86:latest /bin/sh
