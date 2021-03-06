#!/bin/sh

# redirect STDOUT and STDERR to /dev/kmsg
exec 1<&- 2<&- 1>/dev/kmsg 2>&1

set -e

FIRMWARE_DIR="/tmp/firmware"
UPGRADE_SCRIPT="./stage2.sh"

echo "Start braiins/LEDE firmware upgrade process..."

# try to set LEDs to signal recovery mode
echo timer > "/sys/class/leds/Green LED/trigger"
echo nand-disk > "/sys/class/leds/Red LED/trigger"

FIRMWARE_OFFSET=$(fw_printenv -n stage2_off 2> /dev/null)
FIRMWARE_SIZE=$(fw_printenv -n stage2_size 2> /dev/null)
FIRMWARE_MTD=/dev/mtd$(fw_printenv -n stage2_mtd 2> /dev/null)

# get stage2 firmware images from NAND
mkdir -p "$FIRMWARE_DIR"
cd "$FIRMWARE_DIR"

nanddump -s ${FIRMWARE_OFFSET} -l ${FIRMWARE_SIZE} ${FIRMWARE_MTD} \
| tar zx

# rather check error in script
set +e

if /bin/sh "$UPGRADE_SCRIPT" ; then
	echo "Upgrade has been successful!"

	# reboot system
	echo "Restarting system..."
	sync
	reboot
else
    echo "Upgrade failed"
fi
