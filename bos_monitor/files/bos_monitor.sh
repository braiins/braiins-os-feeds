#!/bin/sh

# opkg list-upgradable | awk '/firmware/ {print $3 " -> " $5}' > /tmp/bos_upgrade

if [ $# -eq 0 ]; then
	# run i-notify daemon
	exec inotifyd "$0" /var/lock/:d
fi

# user space agent
# $1. actual event(s)
# $2. file (or directory) name
# $3. name of subfile (if any), in case of watching a directory

OPKG_CONF_PATH="/etc/opkg.conf"

BOS_FIRMWARE_NAME="bos_firmware"
BOS_UPGRADE_PATH="/tmp/bos_upgrade"

case "$3" in
opkg.lock)
	opkg_lists=$(awk '/lists_dir/ {print $3}' /etc/opkg.conf)
	bos_firmware_path="${opkg_lists}/${BOS_FIRMWARE_NAME}"
	if [ -f "$bos_firmware_path" \
		 -a "(" ! -f "$BOS_UPGRADE_PATH" -o "$BOS_UPGRADE_PATH" -ot "$bos_firmware_path" ")" ]; then
		opkg list-upgradable | awk '/firmware/ {print $3 " -> " $5}' > "$BOS_UPGRADE_PATH"
	fi
	;;
*)
	;;
esac
