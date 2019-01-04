#!/bin/sh

FW_TRANSITION=$(cat /tmp/bos_upgrade 2>/dev/null)

if [ -n "$FW_TRANSITION" ]; then
cat << EOF
=== FIRMWARE UPGRADE! ============================
${FW_TRANSITION}
Run the following command to upgrade device:
opkg install firmware
--------------------------------------------------
EOF
fi
