# Build an image for the latest version of tinycore linux using the previous version image.
TCL_MAJOR_VERSION=17
TCL_MINOR_VERSION=0
TCL_ARCHITECTURE=x86
# Only set RELEASE_CANDIDATE_VERSION to something if generating an image for an alpha or beta.
# Set it to an empty string if you're building a fully released version.
# Check the tinycore forum to know how they call it.
# Current latest:
#   https://forum.tinycorelinux.net/index.php/topic,27982.0.html
#   v17.0beta1
RELEASE_CANDIDATE_VERSION=beta1
IMAGE_X_VERSION=${TCL_MAJOR_VERSION}.x-${TCL_ARCHITECTURE}
IMAGE_VERSION=${TCL_MAJOR_VERSION}.$(TCL_MINOR_VERSION)${RELEASE_CANDIDATE_VERSION}-${TCL_ARCHITECTURE}
# TODO: switch to release instead of release_candidates once 17.0 is released.
TCL_RELEASE_TYPE=release_candidates

.PHONY: all build run push tag-stable

all: build run

build:
	sudo docker build --progress=plain --no-cache \
		--build-arg IMAGE_VERSION=${IMAGE_VERSION} \
		--build-arg TCL_ARCHITECTURE=${TCL_ARCHITECTURE} \
		--build-arg TCL_MAJOR_VERSION=${TCL_MAJOR_VERSION} \
		--build-arg TCL_RELEASE_TYPE=${TCL_RELEASE_TYPE} \
		-t linichotmailca/tcl-core-x86:${IMAGE_VERSION} \
		-t linichotmailca/tcl-core-x86:${IMAGE_X_VERSION} \
		-t linichotmailca/tcl-core-x86:latest .

# TODO: confirm this is working on the next run.
tag-stable:
ifeq ($(TCL_RELEASE_TYPE),release)
	sudo docker image tag linichotmailca/tcl-core-x86:latest linichotmailca/tcl-core-x86:stable
endif

run:
	sudo docker run -it linichotmailca/tcl-core-x86:latest /bin/sh

push:
	sudo docker push linichotmailca/tcl-core-x86:${IMAGE_VERSION}
	sudo docker push linichotmailca/tcl-core-x86:${IMAGE_X_VERSION}
	sudo docker push linichotmailca/tcl-core-x86:latest
	sudo docker push linichotmailca/tcl-core-x86:stable
