include $(TOPDIR)/rules.mk

PKG_NAME:=miner_recovery
PKG_RELEASE:=1

PKG_MAINTAINER:=Libor Vasicek <libor.vasicek@braiins.cz>

include $(INCLUDE_DIR)/package.mk

define Package/miner_recovery
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Daemon for controlling miner recovery process
endef

define Package/miner_recovery/description
 Do some action depending on the U-Boot environment variables.
 It is used e.g. for factory reset.
endef

define Build/Compile
endef

define Package/miner_recovery/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/miner_recovery.sh $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/miner_recovery.init $(1)/etc/init.d/miner_recovery
endef

$(eval $(call BuildPackage,miner_recovery))
