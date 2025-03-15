# Build the patched files in the previous docker image and build a new image from scratch using those.
ARG DOCKER_TCL_VERSION
ARG PREVIOUS_DOCKER_TCL_VERSION
ARG TCL_ARCHITECTURE
ARG TCL_MAJOR_VERSION
ARG TCL_RELEASE_TYPE
# Build the patched files
FROM linichotmailca/tcl-core-x86:$PREVIOUS_DOCKER_TCL_VERSION AS tcl_resource
ARG DOCKER_TCL_VERSION
ARG PREVIOUS_DOCKER_TCL_VERSION
ARG TCL_ARCHITECTURE
ARG TCL_MAJOR_VERSION
ARG TCL_RELEASE_TYPE

COPY --chown=tc:staff data/rootfs.patch /home/tc/
COPY tools/patch-tcl-for-docker.sh /usr/bin/
RUN patch-tcl-for-docker.sh $TCL_MAJOR_VERSION $TCL_ARCHITECTURE $TCL_RELEASE_TYPE $DOCKER_TCL_VERSION

# Build the new image using rootfs-$DOCKER_TCL_VERSION.tar.xz .
FROM scratch AS final
ARG DOCKER_TCL_VERSION
ARG PREVIOUS_DOCKER_TCL_VERSION
ARG TCL_ARCHITECTURE
ARG TCL_MAJOR_VERSION
ARG TCL_RELEASE_TYPE

COPY --from=tcl_resource /home/tc/root/ /

RUN NORTC=1 NOZSWAP=1 /etc/init.d/tc-config

USER tc
CMD ["/bin/sh"]

