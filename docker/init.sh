#!/bin/bash

if ! getent passwd $DOCKDEV_USER_NAME > /dev/null
  then
    echo "Creating user $DOCKDEV_USER_NAME:$DOCKDEV_GROUP_NAME"
    groupadd --gid $DOCKDEV_GROUP_ID -r $DOCKDEV_GROUP_NAME
    useradd --system --uid=$DOCKDEV_USER_ID --gid=$DOCKDEV_GROUP_ID \
        --home-dir /home --password $DOCKDEV_USER_NAME $DOCKDEV_USER_NAME
    usermod -a -G sudo $DOCKDEV_USER_NAME
    chown -R $DOCKDEV_USER_NAME:$DOCKDEV_GROUP_NAME /home
  fi
set -x
echo "TEMPLATECONF=$REEFTAS_ROOT/platform/yocto/meta-reeftas/conf/ \
      source ${REEFTAS_ROOT}/platform/yocto/poky/oe-init-build-env ${REEFTAS_OUT} &&
      bitbake reeftas-image" > /tmp/build.sh

sudo -u $DOCKDEV_USER_NAME bash -C "/tmp/build.sh"
if [ $? -ne 0 ]; then
	echo "ReefTAS yocto build failed!!!!!"
	exit 1
fi

sudo -u $DOCKDEV_USER_NAME mkdir  ${REEFTAS_OUT}/tmp/sdcard_image

sudo OETMP=${REEFTAS_OUT}/tmp MACHINE="raspberrypi3"\
     -u $DOCKDEV_USER_NAME bash \
     -C ${REEFTAS_ROOT}/platform/yocto/meta-reeftas/scripts/create_sdcard_images.sh \
      ${REEFTAS_OUT}/tmp/sdcard_image/reeftas.img  4
if [ $? -ne 0 ]; then
	exit 1
fi

