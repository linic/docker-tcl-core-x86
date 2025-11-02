# Build the patched files in the previous docker image and build a new image from scratch using those.
ARG IMAGE_VERSION
ARG TCL_ARCHITECTURE
ARG TCL_MAJOR_VERSION
ARG TCL_RELEASE_TYPE
# Build the patched files
FROM linichotmailca/tcl-core-x86:latest AS tcl_resource
ARG IMAGE_VERSION
ARG TCL_ARCHITECTURE
ARG TCL_MAJOR_VERSION
ARG TCL_RELEASE_TYPE

COPY --chown=tc:staff data/rootfs.patch /home/tc/
COPY tools/patch-tcl-for-docker.sh /usr/bin/
RUN patch-tcl-for-docker.sh $TCL_MAJOR_VERSION $TCL_ARCHITECTURE $TCL_RELEASE_TYPE $IMAGE_VERSION

# Build the new image using rootfs-$IMAGE_VERSION.tar.xz.
FROM scratch AS final
ARG IMAGE_VERSION
ARG TCL_ARCHITECTURE
ARG TCL_MAJOR_VERSION
ARG TCL_RELEASE_TYPE

COPY --from=tcl_resource /home/tc/root/ /

RUN NORTC=1 NOZSWAP=1 /etc/init.d/tc-config

USER tc
CMD ["/bin/sh"]

