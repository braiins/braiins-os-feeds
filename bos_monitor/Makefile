include $(TOPDIR)/rules.mk

PKG_NAME:=bos_monitor
PKG_RELEASE:=1

PKG_MAINTAINER:=Libor Vasicek <libor.vasicek@braiins.cz>

include $(INCLUDE_DIR)/package.mk

define Package/bos_monitor
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Utilities for monitoring braiins OS
  DEPENDS:=+@BUSYBOX_CONFIG_INOTIFYD
endef

define Package/bos_monitor/description
 Periodically checks for new firmware updates and print notification.
endef

define Build/Compile
endef

define Package/bos_monitor/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/bos_monitor.sh $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/bos_monitor.init $(1)/etc/init.d/bos_monitor

	$(INSTALL_DIR) $(1)/etc/profile.d/
	$(INSTALL_BIN) ./files/bos_monitor.profile $(1)/etc/profile.d/bos_monitor.sh
endef

$(eval $(call BuildPackage,bos_monitor))
