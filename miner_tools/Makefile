include $(TOPDIR)/rules.mk

PKG_NAME:=miner_tools
PKG_RELEASE:=1

PKG_MAINTAINER:=Libor Vasicek <libor.vasicek@braiins.cz>

include $(INCLUDE_DIR)/package.mk

define Package/miner_tools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Utilities for managing miner
endef

define Package/miner_tools/description
 Add miner script which is used for miner namagement.
 It can do factory reset, boot to recovery mode or turn on miner's LEDs.
endef

define Build/Compile
endef

define Package/miner_tools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/miner $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,miner_tools))
