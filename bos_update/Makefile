include $(TOPDIR)/rules.mk

PKG_NAME:=bos_update
PKG_RELEASE:=1

PKG_MAINTAINER:=Libor Vasicek <libor.vasicek@braiins.cz>

include $(INCLUDE_DIR)/package.mk

define Package/bos_update
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Automatic check for latest updates
  DEPENDS:=+at +@BUSYBOX_CONFIG_ASH_RANDOM_SUPPORT
endef

define Package/bos_update/description
 Periodically calls opkg update to get latest packages.
endef

define Build/Compile
endef

define Package/bos_update/install
	$(INSTALL_DIR) $(1)/etc/crontabs

	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/bos_update.sh $(1)/usr/sbin/
endef

define Package/bos_update/preinst
#!/bin/sh

echo "0 0 * * * /usr/sbin/bos_update.sh 2>&1 | logger -t update" >> $${IPKG_INSTROOT}/etc/crontabs/root
endef

define Package/bos_update/postrm
#!/bin/sh

sed -i '/usr/sbin/bos_update.sh/d' /etc/crontabs/root
/etc/init.d/cron restart
endef

$(eval $(call BuildPackage,bos_update))
