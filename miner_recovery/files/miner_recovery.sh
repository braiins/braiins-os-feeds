#!/bin/sh

# redirect STDOUT and STDERR to /dev/kmsg
exec 1<&- 2<&- 1>/dev/kmsg 2>&1

RECOVERY_MTD=/dev/mtd6
FIMRWARE_MTD=/dev/mtd7

FACTORY_OFFSET=0x800000
FACTORY_SIZE=0xC00000

FPGA_OFFSET=0x1400000
FPGA_SIZE=0x100000

SD_DIR=/mnt

SD_FACTORY_BIN_PATH=$SD_DIR/factory.bin
SD_SYSTEM_BIT_PATH=$SD_DIR/system.bit

FACTORY_BIN_PATH=/tmp/factory.bin
SYSTEM_BIT_PATH=/tmp/system.bit

mtd_write() {
	mtd -e "$2" write "$1" "$2"
}

echo "Miner is in the recovery mode!"

# try to set LEDs to signal recovery mode
echo timer > "/sys/class/leds/Green LED/trigger"
echo nand-disk > "/sys/class/leds/Red LED/trigger"

# prevent NAND corruption when U-Boot env cannot be read
if [ -n "$(fw_printenv 2>&1 >/dev/null)" ]; then
	echo "Do not use 'fw_setenv' to prevent NAND corruption!"
	exit 1
fi

FACTORY_RESET=$(fw_printenv -n factory_reset 2>/dev/null)
SD_IMAGES=$(fw_printenv -n sd_images 2>/dev/null)

# immediately exit when error occurs
set -e

if [ x${FACTORY_RESET} == x"yes" ]; then
	echo "Resetting to factory settings..."

	if [ x${SD_IMAGES} == x"yes" ]; then
		echo "recovery: using SD images for factory reset"

		# mount SD
		mount /dev/mmcblk0p1 ${SD_DIR}

		# copy factory image to temp
		cp "$SD_FACTORY_BIN_PATH" "$FACTORY_BIN_PATH"

		# compress bitstream for FPGA
		gzip -c "$SD_SYSTEM_BIT_PATH" > "$SYSTEM_BIT_PATH"

		umount ${SD_DIR}
	else
		# get uncompressed factory image
		nanddump -s ${FACTORY_OFFSET} -l ${FACTORY_SIZE} ${RECOVERY_MTD} \
		| gunzip \
		> "$FACTORY_BIN_PATH"

		# get bitstream for FPGA
		nanddump -s ${FPGA_OFFSET} -l ${FPGA_SIZE} ${RECOVERY_MTD} \
		> "$SYSTEM_BIT_PATH"
	fi

	# write the same FPGA bitstream to both MTD partitions
	mtd_write "$SYSTEM_BIT_PATH" fpga1
	mtd_write "$SYSTEM_BIT_PATH" fpga2

	# erase all firmware partition
	mtd erase firmware1
	mtd erase firmware2

	ubiformat ${FIMRWARE_MTD} -f "$FACTORY_BIN_PATH"

	# remove factory reset mode from U-Boot env
	fw_setenv factory_reset

	sync
	echo "recovery: factory reset has been successful!"

	# reboot system
	echo "Restarting system..."
	reboot
fi
