#!/usr/bin/env sh

set -e

if [ ! -L "/sys/class/gpio/gpio943" ]; then
	echo 943 > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio943/direction
	echo 944 > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio944/direction
	echo 945 > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio945/direction
	echo 953 > /sys/class/gpio/export
	echo in > /sys/class/gpio/gpio953/direction
	echo 957 > /sys/class/gpio/export
	echo in > /sys/class/gpio/gpio957/direction
fi

bmminer --fixed-freq --no-pre-heat --api-listen --default-config /etc/bmminer.conf
