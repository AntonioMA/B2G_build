#!/bin/bash

if [ -f ./config_fota ]
then
  source ./config_fota
else
  DEST_DIR=/var/www/ota
fi

source ./.config
source ./.userconfig
export VARIANT MOZILLA_OFFICIAL

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

cp ${SRC_FILE} ${DEST_DIR}/${FILE_OTA}

export ANDROID_TOOLCHAIN=`pwd`/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.7/bin

./tools/update-tools/build-update-xml.py -v ${MOZ_APP_VERSION} -V ${MOZ_APP_VERSION} -o ${DEST_DIR}/update.xml -i ${BuildID} -u ${URL} ${DEST_DIR}/${FILE_OTA}

