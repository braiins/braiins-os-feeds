include $(TOPDIR)/rules.mk

PKG_NAME:=cgminer_monitor
PKG_RELEASE:=1

PKG_MAINTAINER:=Libor Vasicek <libor.vasicek@braiins.cz>

include $(INCLUDE_DIR)/package.mk

define Package/cgminer_monitor
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Monitor for CGMiner
  DEPENDS:=+cgminer +lua +lua-cjson +luasocket
endef

define Package/cgminer_monitor/description
 Monitors CGMiner statistics provided by standard RPC API and records
 history of samples. Measured data can be obtained in JSON format
 through local TCP port.
endef

define Build/Compile
endef

define Package/cgminer_monitor/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/cgminer_monitor.lua $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/cgminer_monitor.init $(1)/etc/init.d/cgminer_monitor
endef

$(eval $(call BuildPackage,cgminer_monitor))
