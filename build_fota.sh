#!/bin/bash

source ./.config
source ./.userconfig
export VARIANT=user
export MOZILLA_OFFICIAL=1

export DEVICE=$PRODUCT_NAME
export `grep MOZ_APP_VERSION ${GECKO_PATH}/b2g/confvars.sh`


case $1 in
  fota)
        TYPE=fota
        ./build_sto3.sh gecko-update-fota
        SRC_FILE=`pwd`/out/target/product/${DEVICE}/fota-${DEVICE}-update.mar
        ;;
    *) TYPE=ota
        ./build_sto3.sh gecko-update-full
        SRC_FILE=${GECKO_OBJDIR}/dist/b2g-update/b2g-${DEVICE}-gecko-update.mar
        ;;
esac

export `grep BuildID out/target/product/flame/system/b2g/platform.ini`

echo "APP VERSION: ${MOZ_APP_VERSION}"
echo "Build ID: ${BuildID}"


FILE_OTA="${TYPE}-${DEVICE}-update.mar"
URL=`grep app.update.url gaia/profile/user.js | grep -v "//pref" | cut -d\" -f 4 | sed -e "s/update.xml/${FILE_OTA}/g"`

cp ${SRC_FILE} /var/www/ota/${FILE_OTA}

export ANDROID_TOOLCHAIN=`pwd`/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.7/bin

./tools/update-tools/build-update-xml.py -v 99.${MOZ_APP_VERSION} -V 99.${MOZ_APP_VERSION} -o /var/www/ota/update.xml -i ${BuildID} -u ${URL} /var/www/ota/${FILE_OTA}

