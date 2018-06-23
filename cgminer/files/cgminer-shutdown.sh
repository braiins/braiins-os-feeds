#!/bin/sh

gpio_write() {
	local p=/sys/class/gpio/gpio$1/value 
	if [ -f "$p" ]; then 
		echo $2 > $p
		return 0
	else
		return 1
	fi
}

chain=0
echo "RESET=0"
for pin in 855 857 859 861 863 865; do
	let chain=chain+1
	if  gpio_write $pin 0; then
		echo "chain $chain present"
	else
		echo "chain $chain not present"
	fi
done
sleep 1
echo "START_EN=0"
for pin in 854 856 858 860 862 864; do
	gpio_write $pin 0
done
sleep 1
echo "POWER=0"
for pin in 872 873 874 875 876 877; do
	gpio_write $pin 0 && sleep 1
done
echo "LED=1"
for pin in 881 882 883 884 885 886; do
	gpio_write $pin 1
done
