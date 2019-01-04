#!/bin/sh

echo "Schedule times for opkg update:"

offset=$(($RANDOM % 240))

while [ $offset -lt 1440 ]; do
	(at now + $offset minutes 2>&1 | sed -n '/job/s/job [[:digit:]]\+ at //p') <<-END
		opkg update 2>&1 | logger -t opkg
	END
	offset=$(($RANDOM % 120 + $offset + 480))
done
