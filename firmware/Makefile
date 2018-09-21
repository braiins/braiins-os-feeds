include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=firmware
PKG_MAINTAINER:=Libor Vasicek <libor.vasicek@braiins.cz>

# set firmware version
PKG_RELEASE:=$(call qstrip,$(CONFIG_FIRMWARE_VERSION))

MINER_FEEDS_SERVER:=https://feeds.braiins-os.org/$(SUBTARGET)
MINER_FEEDS_CONFIG:=/etc/opkg/minerfeeds.conf

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
	echo "src/gz miner_firmware $(MINER_FEEDS_SERVER)" > $(1)$(MINER_FEEDS_CONFIG)
endef

define Package/firmware/preinst
#!/bin/sh

# if run within buildroot exit
[ -n "$${IPKG_INSTROOT}" ] && exit 0

MINER_FEEDS="$(MINER_FEEDS_CONFIG)"
FIRMWARE_NAME="$(PKG_NAME)_$(VERSION)_$(PKGARCH).tar"

# parse server address from opkg configuration file
feeds_server=$$(awk '/miner_firmware/ {print $$3}' "$${MINER_FEEDS}")

echo "Running system upgrade..."
wget -O "/tmp/sysupgrade.tar" "$${feeds_server}/$${FIRMWARE_NAME}" || exit 1
sysupgrade "/tmp/sysupgrade.tar" || exit 1

# the package is not actually installed
# wait to suppress error printing
sleep 10
exit 2
endef

define Package/firmware/postrm
#!/bin/sh

# if this script is run then simple package remove has been called
echo "Processing factory reset..."
fw_setenv factory_reset yes
reboot
endef

$(eval $(call BuildPackage,firmware))
