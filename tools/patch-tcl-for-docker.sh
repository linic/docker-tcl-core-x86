#!/bin/sh

###################################################################################################
# tce_install comes from https://github.com/innovarew/docker-tinycore/blob/main/scripts/tc-docker #
# patch-tcl-for-docker.sh is greatly inspire from innovarew's tc-docker. Which is under GPL-2.0   #
# For the original code I wrote below:                                                            #
# Copyright (C) 2025  linic@hotmail.ca Subject to GPL-3.0 license.                                #
# https://github.com/linic/docker-tcl-core-x86                                                    #
###################################################################################################

##################################################################
# Generate a rootfs-DOCKER_TCL_VERSION.tar.xz.
#
# Since and Core-current.iso is vmlinuz + core.gz
# and core.gz is rootfs.gz + modules.gz,
# and modules.gz are not needed to have a working tcl docker,
# image, this script uses rootfs.gz directly. This makes it
# possible to have beta releases of tcl versions since
# Core-current.iso only exists after the alpha and beta testing
# are complete.
#
# The script takes the following parameters:
# - major version number of tinycore linux. Example: 16
# - architecture: either x86 or x86_64
# - "release_candidates" or "release" depending on whether a beta
#   version is going to be used for generating the image or a
#   release
# - DOCKER_TCL_VERSION, something like 16.0beta1.x-x86 see
#   Makefile for more details.
##################################################################

main()
{
  if [ ! $# -eq 4 ]; then
    echo "Please provide a version number, an architecture and a "\
      "release type. For example, patch-tcl-for-docker.sh 16 "\
      "x86 release_candidates 16.0beta1.x-x86"
    exit 5
  fi

  TCL_MAJOR_VERSION=$1
  # Check that the version number is really a number.
  non_digits=$(echo "$N" | sed 's/[0-9]//g')
  if [ -n "$non_digits" ]; then
    echo "$TCL_MAJOR_VERSION is not a number. Please try again "\
      "with a number as the first parameter. For example, "\
      "patch-tcl-for-docker.sh 16 release_candidates."
    exit 1
  fi
  TCL_VERSION=$TCL_MAJOR_VERSION.x

  # Check the architecture type.
  TCL_ARCHITECTURE=$2
  TCL_64=""
  if [ $TCL_ARCHITECTURE != "x86" && $TCL_ARCHITECTURE != "x86_64" ]; then
    echo "Only x86 or x86_64 are supported for now."
    exit 2
  fi
  if [ $TCL_ARCHITECTURE == "x86_64" ]; then
    echo "Attempting to build a 64 bit version of the image. "\
      "Remove this message once it will have been run once successfully."
    TCL_64="64"
  fi

  # Check the release type.
  TCL_RELEASE_TYPE=$3
  if [ $TCL_RELEASE_TYPE != "release" && $TCL_RELEASE_TYPE != "release_candidates"  ]; then
    echo "$TCL_RELEASE_TYPE is not supported. Please enter 'release' or "\
      "'release_candidates'. For example, patch-tcl-for-docker.sh 16 release_candidates."
    exit 3
  fi

  # Check the DOCKER_TCL_VERSION.
  DOCKER_TCL_VERSION=$4
  if [ -z $DOCKER_TCL_VERSION ]; then
    echo "DOCKER_TCL_VERSION is missing. Enter something like 16.x-x86."
    exit 4
  fi

  # Set variables to download required files.
  TCL_URL=http://tinycorelinux.net/$TCL_VERSION/$TCL_ARCHITECTURE
  ROOTFS_FILE=rootfs$TCL_64.gz
  ROOTFS_MD5_FILE=rootfs$TCL_64.gz.md5.txt
  DISTRIBUTION_FILES_URL=$TCL_URL/$TCL_RELEASE_TYPE/distribution_files
  TCZ_URL=$TCL_URL/tcz

  # Directory where the patch and the patched files will be.
  # If data is ever changed for something else, the rootfs.patch
  # will have to be modified.
  HOME_TC=/home/tc
  ROOT_DIRECTORY=$HOME_TC/root
  TCL_DIRECTORY=$HOME_TC/tiny_core_linux

  # Ensure directories exist.
  mkdir -p $TCL_DIRECTORY
  mkdir -p $ROOT_DIRECTORY
  # Generating the tar file which will be used by the final docker image.
  DOCKER_TCL_ROOTFS_TAR="$HOME_TC/rootfs-$DOCKER_TCL_VERSION.tar.gz"
  DOCKER_TCL_ROOTFS_PATCH="$HOME_TC/rootfs.patch"
  pwd
  if [ ! -e $DOCKER_TCL_ROOTFS_PATCH ]; then
    echo "$DOCKER_TCL_ROOTFS_PATCH is missing."
    exit 30
  fi

  echo "Downloading $DISTRIBUTION_FILES_URL/$ROOTFS_FILE..."
  cd $TCL_DIRECTORY
  wget $DISTRIBUTION_FILES_URL/$ROOTFS_FILE
  wget $DISTRIBUTION_FILES_URL/$ROOTFS_MD5_FILE
  if md5sum -c $ROOTFS_MD5_FILE; then
    echo "$ROOTFS_FILE succeeded."
  else
    echo "$ROOTFS_FILE failed!"
    exit 10
  fi

  # Extract the rootfs.gz
  cd $ROOT_DIRECTORY
  zcat $TCL_DIRECTORY/$ROOTFS_FILE | sudo cpio -i -H newc -d
  if [ ! -e usr/bin/tce-load ]; then
    echo "$ROOT_DIRECTORY/usr/bin/tce-load is missing!"
    exit 40
  fi
  # Apply rootfs.patch
  # Display the whole file for debugging the patch.
  echo "--tce-load_start--"
  cat usr/bin/tce-load
  echo "--tce-load_end--"
  echo "--patch_start--"
  if sudo patch -p2 < $DOCKER_TCL_ROOTFS_PATCH; then
    echo "patched tce-load successfully."
  else
    echo "failed to patch tce-load."
    exit 50
  fi
  echo "--patch_end--"

  # Get squashfs-tools.tcz in the $ROOT_DIRECTORY
  # Need by data/rootfs.patch which modifies tce-load to unsquashfs the .tcz
  # since mount binds are not available inside docker.
  tce_install squashfs-tools.tcz $ROOT_DIRECTORY

  # Generate the rootfs-DOCKER-TCL-VERSION.tar.xz file.
  ls $HOME_TC
  ls .
  pwd
  ls -la $(dirname $DOCKER_TCL_ROOTFS_TAR)
  echo "--tar_start--"
  sudo tar cvzf $DOCKER_TCL_ROOTFS_TAR .
  echo "--tar_end--"
}

# All credits for tce_install go to innovarew and where this function came from.
# https://github.com/innovarew/docker-tinycore/blob/main/scripts/tc-docker
# usage: tce_install squashfs-tools.tcz /
tce_install()
{
	# Change here - linic@hotmail.ca
  if [ ! $# -eq 2 ]; then
	  echo ".tcz name required as the first parameter and the root path of the TCL being modified are "\
			"required. For example: tce_install liblzma.tcz /home/tc/root/."
	 	exit 20
	fi

  local app=$1
  local root=$2

	# Change here - linic@hotmail.ca
  if [ -e "$root/usr/local/tce.installed/${app%.tcz}" ]; then
    echo "$app already installed in $root"
  fi

	# Another small change to cd $TCE_DIR - linic@hotmail.ca
	(
  	cd $TCL_DIRECTORY

    if wget "$TCZ_URL/$app.dep"; then
      for dep in $(cat "$app.dep")
        do
          tce_install $dep $root
        done
    fi

    wget "$TCZ_URL/$app"
    wget "$TCZ_URL/$app.md5.txt"
	  # Removed the check for the .md5.txt file - linic@hotmail.ca
    if md5sum -c "$app.md5.txt"; then
      echo "$app validated successfully."
    else
      echo "$app validation failed!"
      exit 20
    fi


    if [ -n "$UNSQUASHFS" ]; then
      sudo unsquashfs -n -d "$root" -f "$app" >/dev/null

      # Create a file in tce.installed to keep track of what's already installed.
      sudo mkdir -p "$root/usr/local/tce.installed/"
      sudo touch "$root/usr/local/tce.installed/${app%.tcz}"
    fi

    # update libs
    if [ -w /etc/ld.so.cache ]; then
      sudo ldconfig
    fi
	)
}

main "$@"

