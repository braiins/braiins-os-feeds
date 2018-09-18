include $(TOPDIR)/rules.mk

PKG_NAME:=miner_upgrade
PKG_RELEASE:=1

PKG_MAINTAINER:=Libor Vasicek <libor.vasicek@braiins.cz>

include $(INCLUDE_DIR)/package.mk

define Package/miner_upgrade
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Stage 2 miner firmware upgrade
endef

define Package/miner_upgrade/description
 Finish miner upgrade used for conversion from different firmware to this one.
endef

define Build/Compile
endef

define Package/miner_upgrade/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/miner_upgrade.sh $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/miner_upgrade.init $(1)/etc/init.d/miner_upgrade
endef

$(eval $(call BuildPackage,miner_upgrade))
