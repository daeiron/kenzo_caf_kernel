#!/sbin/sh
cd /tmp/
/sbin/busybox dd if=/dev/block/bootdevice/by-name/boot of=/tmp/boot.img
./unpackbootimg -i /tmp/boot.img
./mkbootimg --kernel /tmp/Image --ramdisk /tmp/boot.img-ramdisk.gz --cmdline "console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 earlyprintk"  --base 0x80000000 --pagesize 2048 --ramdisk_offset 0x02000000 --tags_offset 0x01e00000 --dt /tmp/dt.img -o /tmp/new_boot.img
/sbin/busybox dd if=/tmp/new_boot.img of=/dev/block/bootdevice/by-name/boot
