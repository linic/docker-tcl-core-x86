# Build an image for the latest version of tinycore linux using the previous version image.
TCL_MAJOR_VERSION=16
TCL_ARCHITECTURE=x86
# Only set RELEASE_CANDIDATE_VERSION to something if generating an image for an alpha or beta.
# Set it to an empty string if you're building a fully released version.
# Check the tinycore forum to know how they call it.
# Example: https://forum.tinycorelinux.net/index.php/topic,27550
# which calls it Core v16.0beta1
#RELEASE_CANDIDATE_VERSION=.0beta1
# 2025-04-05 - Commented out RELEASE_CANDIDATE because 16.0 is official. See https://forum.tinycorelinux.net/index.php/topic,27578
DOCKER_TCL_VERSION=${TCL_MAJOR_VERSION}${RELEASE_CANDIDATE_VERSION}.x-${TCL_ARCHITECTURE}
PREVIOUS_DOCKER_TCL_VERSION=$(shell echo $$(($(TCL_MAJOR_VERSION) - 1))).x-${TCL_ARCHITECTURE}
TCL_RELEASE_TYPE=release

all: build run

build:
	echo PREVIOUS_DOCKER_TCL_VERSION=${PREVIOUS_DOCKER_TCL_VERSION} && sudo docker build --progress=plain --no-cache \
		--build-arg DOCKER_TCL_VERSION=${DOCKER_TCL_VERSION} \
		--build-arg PREVIOUS_DOCKER_TCL_VERSION=${PREVIOUS_DOCKER_TCL_VERSION} \
		--build-arg TCL_ARCHITECTURE=${TCL_ARCHITECTURE} \
		--build-arg TCL_MAJOR_VERSION=${TCL_MAJOR_VERSION} \
		--build-arg TCL_RELEASE_TYPE=${TCL_RELEASE_TYPE} \
		-t linichotmailca/tcl-core-x86:${DOCKER_TCL_VERSION} \
		-t linichotmailca/tcl-core-x86:latest .
run:
	sudo docker run -it tcl-core-x86:latest /bin/sh
