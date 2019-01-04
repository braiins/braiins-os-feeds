include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=firmware
PKG_MAINTAINER:=Libor Vasicek <libor.vasicek@braiins.cz>

# set firmware version
PKG_RELEASE:=$(call qstrip,$(CONFIG_FIRMWARE_VERSION))

BOS_FEEDS_SERVER:=https://feeds.braiins-os.org/$(SUBTARGET)
BOS_FEEDS_CONFIG:=/etc/opkg/bosfeeds.conf

include $(INCLUDE_DIR)/package.mk

define Package/firmware
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Current Firmware
endef

define Package/firmware/description
 Meta package for automated firmware upgrades.
endef

define Package/firmware/config
	source "$(SOURCE)/Config.in"
endef

define Build/Compile
endef

define Package/firmware/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/fw_info.json $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/opkg
	echo "src/gz bos_firmware $(BOS_FEEDS_SERVER)" > $(1)$(BOS_FEEDS_CONFIG)
endef

define Package/firmware/preinst
#!/bin/sh

# if run within buildroot exit
[ -n "$${IPKG_INSTROOT}" ] && exit 0

PACKAGES_NAME="Packages"
PACKAGES_PATH="/tmp/$${PACKAGES_NAME}"
SYSUPGRADE_PATH="/tmp/sysupgrade.tar"
BOS_FEEDS="$(BOS_FEEDS_CONFIG)"
FIRMWARE_NAME="$(PKG_NAME)_$(VERSION)_$(PKGARCH).tar"
FIRMWARE_REQUIRE="$(call qstrip,$(CONFIG_FIRMWARE_REQUIRE))"

# parse server address from opkg configuration file
feeds_server=$$(awk '/bos_firmware/ {print $$3}' "$${BOS_FEEDS}")

current_fw_version() {
	if ! cat /etc/bos_version 2>/dev/null; then
		awk '/Package: /{p=$$2} /Version: /{v=$$2} \
			 /Status: /{if (p == "firmware" && $$NF == "installed") print v}' \
			'/usr/lib/opkg/status'
	fi
}

required_fw_version() {
	result=$$(awk '/Package: /{p=$$2} /Version: /{v=$$2} /Require: /{r=$$2} \
		/Filename: /{if (p == "firmware" && v == "'$$2'") print $$2" "r}' "$$1")
	eval $$3=$${result% *}
	eval $$4=$${result#* }
}

get_firmware_name() {
	local fw_version=$$(current_fw_version)
	local require=$${FIRMWARE_REQUIRE}
	local filename=$${FIRMWARE_NAME}
	if [ ! "$${fw_version}" "<" "$${require}" ]; then
		eval $$1=$${filename}
		return 0
	fi

	echo "Downloading package list..."
	wget -O "$${PACKAGES_PATH}.gz" "$${feeds_server}/$${PACKAGES_NAME}.gz" || return 1
	gzip -df "$${PACKAGES_PATH}.gz" || return 1
	wget -O "$${PACKAGES_PATH}.sig" "$${feeds_server}/$${PACKAGES_NAME}.sig" || return 1
	echo "Checking signature..."
	usign -V -m "$${PACKAGES_PATH}" -P "/etc/opkg/keys" || return 1

	while [ "$${fw_version}" "<" "$${require}" ]; do
		required_fw_version "$${PACKAGES_PATH}" $${require} filename require
		[ -n "$${filename}" ] || return 1
	done
	echo "Using previous firmware to satisfy requirements!"
	eval $$1="$${filename%.ipk}.tar"
}

if get_firmware_name firmware_name; then
	echo "Running system upgrade..."
	wget -O "$${SYSUPGRADE_PATH}" "$${feeds_server}/$${firmware_name}"
	sysupgrade "$${SYSUPGRADE_PATH}"
else
	echo "Firmware version '$${FIRMWARE_REQUIRE}' is required before upgrading to this version."
	echo "Cannot find required firmware on server!"
	exit 1
fi

# the package is not actually installed
# wait to suppress error printing
sleep 10
exit 2
endef

define Package/firmware/postrm
#!/bin/sh

# if this script is run then simple package remove has been called
echo "Processing factory reset..."
miner factory_reset
endef

$(eval $(call BuildPackage,firmware))
