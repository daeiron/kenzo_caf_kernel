#!/bin/bash

# User defined variables (only edit this part)
TOOLCHAIN=/home/thomas/android/toolchains/aarch64-linux-android-4.9
MYDEFCONFIG=kenzo_defconfig
THREADS=5

# Step 1 - Set ARCH and CROSS_COMPILE
export ARCH=arm64
export CROSS_COMPILE=$TOOLCHAIN/bin/aarch64-linux-android-
# Step 2 - Make defconfig
make $MYDEFCONFIG
# Step 3 - Make kernel
make -j$THREADS
# Step 4 - Copy and rename kernel image to staging
cp arch/arm64/boot/Image.gz build/staging/kernel
# Step 4 - Create dt.img and move to staging
scripts/dtbTool -v -s 2048 -o build/staging/dt.img -p scripts/dtc/ arch/arm/boot/dts/
# Step 5 - Build the boot image
build/boot_tools/mkboot build/staging build/out/boot.img
# Step 6 - Find, strip and copy modules
rm -rf build/out/system/
mkdir -p build/out/system/lib/modules/pronto
find . -path ./build -prune -o -name '*.ko' -print | xargs cp -t build/out/system/lib/modules/
$TOOLCHAIN/bin/aarch64-linux-android-strip --strip-unneeded build/out/system/lib/modules/*.ko
mv build/out/system/lib/modules/wlan.ko build/out/system/lib/modules/pronto/pronto_wlan.ko
ln -s /system/lib/modules/pronto/pronto_wlan.ko build/out/system/lib/modules/wlan.ko
# Step 7 - Zip it up to build/dist
cd build/out
zip -yr ../../build/dist/kenzo_kernel_`date +%d-%m-%Y`.zip .
