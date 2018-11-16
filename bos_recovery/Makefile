include $(TOPDIR)/rules.mk

PKG_NAME:=bos_recovery
PKG_RELEASE:=1

PKG_MAINTAINER:=Libor Vasicek <libor.vasicek@braiins.cz>

include $(INCLUDE_DIR)/package.mk

define Package/bos_recovery
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Utilities for system recovery mode
endef

define Package/bos_recovery/description
 Do some action depending on the U-Boot environment variables.
 It is used e.g. for factory reset.
endef

define Build/Compile
endef

define Package/bos_recovery/install
	$(INSTALL_DIR) $(1)/etc/
	$(CP) ./files/bos_mode $(1)/etc/

	$(INSTALL_DIR) $(1)/etc/profile.d/
	$(INSTALL_BIN) ./files/bos_recovery.profile $(1)/etc/profile.d/bos_recovery.sh

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/bos_recovery.sh $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/bos_recovery.init $(1)/etc/init.d/bos_recovery
endef

$(eval $(call BuildPackage,bos_recovery))
