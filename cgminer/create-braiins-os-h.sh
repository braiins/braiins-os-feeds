#!/bin/sh
SUBTARGET="$1"
VERSION="$2"
CVERSION=$(echo "$VERSION" | sed 's/^\(....\)-\(..\)-\(..\)-\([0-9]\+\)-\(.*\)/\1\2\3-\4_\5/')

cat<<_END_
#define BOS_FIRMWARE_SUBTARGET "$SUBTARGET"
#define BOS_FIRMWARE_VERSION "$VERSION"
#define BOS_FIRMWARE_VERSION_COMPRESSED "$CVERSION"
_END_
