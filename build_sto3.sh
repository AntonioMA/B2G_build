#!/bin/bash

source ./.config

if [ -f ./.userconfig ]
then
  source ./.userconfig
fi

export GP=${GECKO_PATH:-./gecko}
export CUR_DIR=`pwd`

# We have to apply 3 patches. Quick and dirty...
export BUILD_PATCH='build.patch|./build'
export SYSTEM_CORE_PATCH='system_core.patch|./system/core'
export GECKO_PATCH="./recover_store_gecko.patch|$GP"

if [ $DEVICE_NAME = flame -o $DEVICE_NAME = flame-kk ]
then
  # We want adb root!
  PATCHES="$BUILD_PATCH $SYSTEM_CORE_PATCH $GECKO_PATCH"
  # And UX guys like their font to be present for some reason
  mkdir -p out/target/product/flame/system/fonts/
  cp backup-flame/system/fonts/Fira*OT*.otf out/target/product/flame/system/fonts/
else
  # Only the store
  PATCHES="$GECKO_PATCH"
fi

function abort() {
   echo Error: $1
   echo 'Aborting!'
   exit 1
}

function checkIfApply() {

  for i in $1
  do
    PATCH=$CUR_DIR/`echo $i|cut -d'|' -f1`
    DIR=`echo $i|cut -d'|' -f2`
    pushd $DIR || abort "Directory $DIR does not exist"
    if [ -d .git ]
    then
      git apply --check $PATCH || abort "Patch $PATCH does not apply on $DIR"
    else
      echo "****.git does not exist on $DIR! ***"
      echo "**** Going to assume it's Mercurial and skip it ****"
      echo "Please press enter to continue or CTR+C to abort"
    read
    fi
    popd
  done
}

function revert() {
  echo "Reverting changes for $PATCHES"
  for i in $1
  do
    DIR=`echo $i|cut -d'|' -f2`
    pushd $DIR || abort "Er WTH, this should not happen! $DIR does not exist!"
    if [ -d .git ]
    then
      git reset --hard HEAD^
    else
      echo "***** .git does not exist on $DIR! ****"
      echo "*****  Skipping it happily!        ****"
    fi
    popd
  done
}


function apply() {
  for i in $1
  do
    PATCH=$CUR_DIR/`echo $i|cut -d'|' -f1`
    DIR=`echo $i|cut -d'|' -f2`
    pushd $DIR || abort "Er WTH, this should not happen! $DIR does not exist!"
    if [ -d .git ]
    then
      git apply --index $PATCH || abort "Error applying $PATCH on $DIR. This should NOT happen"
      git commit -a -m "Don't push"|| abort "Error commiting on $DIR. This should NOT happen"
    else
      echo "***** .git does not exist on $DIR! ****"
      echo "*****  Skipping it happily!        ****"
    fi
    popd
  done
}



export GECKO_DIR=$GP
export PATH=$PATH:.

checkIfApply "$PATCHES"

# Ok, at this point everything should be good with life so let's apply the patches...

apply "$PATCHES"

trap "revert \"$PATCHES\"" INT QUIT
./build.sh $*
ERR_CODE=$?

revert "$PATCHES"
exit $ERR_CODE
