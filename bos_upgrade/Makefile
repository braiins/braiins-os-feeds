include $(TOPDIR)/rules.mk

PKG_NAME:=bos_upgrade
PKG_RELEASE:=1

PKG_MAINTAINER:=Libor Vasicek <libor.vasicek@braiins.cz>

include $(INCLUDE_DIR)/package.mk

define Package/bos_upgrade
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Utilities for system upgrade (stage 2)
endef

define Package/bos_upgrade/description
 Finish firmware upgrade used for conversion from different firmware to this one.
endef

define Build/Compile
endef

define Package/bos_upgrade/install
	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_BIN) ./files/bos_mode $(1)/etc/

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/bos_upgrade.sh $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/bos_upgrade.init $(1)/etc/init.d/bos_upgrade
endef

$(eval $(call BuildPackage,bos_upgrade))
