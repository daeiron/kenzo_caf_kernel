#!/bin/bash

# User defined variables (only edit this part)
TOOLCHAIN=/home/thomas/android/toolchains/aarch64-linux-android-4.9-kernel
MYDEFCONFIG=cyanogenmod_kenzo_defconfig
THREADS=6

#Create dirs
mkdir -p build/staging/system/lib/modules/
mkdir -p build/staging/kernel
mkdir -p build/dist

# Step 1 - Set ARCH and CROSS_COMPILE
export ARCH=arm64
export CROSS_COMPILE=$TOOLCHAIN/bin/aarch64-linux-android-

if [ "$1" == "clean" ]; then
	make clean
fi
if [ "$1" == "cleanall" ]; then
	rm -rf build/dist/*
	rm -rf build/staging/system/lib/modules/*
	rm -rf build/staging/kernel/*
	make clean
fi

# Step 2 - Make defconfig
make $MYDEFCONFIG
# Step 3 - Make kernel
make -j$THREADS
# Step 4 - Copy and rename kernel image to staging
cp arch/arm64/boot/Image build/staging/kernel/Image
# Step 4 - Create dt.img and move to staging
scripts/dtbTool -v -2 -s 2048 -o build/staging/kernel/dt.img -p scripts/dtc/ arch/arm/boot/dts/
# Step 5 - Copy wlan.ko and strip it
$TOOLCHAIN/bin/aarch64-linux-android-strip --strip-unneeded drivers/staging/prima/wlan.ko
cp drivers/staging/prima/wlan.ko build/staging/system/lib/modules/wlan.ko
# Step 6 - Zip it up to build/dist
cd build/staging
zip -yr ../../build/dist/kenzo_kernel_`date +%d-%m-%Y`.zip .
