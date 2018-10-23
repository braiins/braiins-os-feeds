include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=cgminer
PKG_VERSION:=4.10.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Libor Vasicek <libor.vasicek@braiins.cz>

ifeq ($(strip $(CONFIG_EXTERNAL_CGMINER_TREE)),"")
	PKG_SOURCE_PROTO:=git
	PKG_SOURCE_URL:=git@gitlab.bo:x/cgminer.git
	PKG_SOURCE_VERSION:=braiins-old-spi
else
	PKG_SOURCE_VERSION:=local
    USE_SOURCE_DIR:=$(call qstrip,$(CONFIG_EXTERNAL_CGMINER_TREE))
endif

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)
#PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.xz
#PKG_MIRROR_HASH:=c6d4f3a6d936dbf9ee5e96f5e843f1127c2867455250100288dc477f646db001
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk

define Package/cgminer
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=ASIC and FPGA Miner for Bitcoin
  URL:=http://ck.kolivas.org/apps/cgminer
  DEPENDS:=+libcurl +zlib
endef

define Package/cgminer/description
 Multi-threaded multi-pool FPGA and ASIC miner for bitcoin.
endef

define Package/cgminer/config
	source "$(SOURCE)/Config.in"
endef

define Package/cgminer/conffiles
/etc/cgminer.conf
endef

define INSTALL_INIT
	$(INSTALL_BIN) $(1) $(3)
	sed -n '/# insert/,$$$$!p' $(1) >$(3)
	cat $(2) >>$(3)
	sed -n '1,/# insert/!p' $(1) >>$(3)
endef

ifeq ($(SUBTARGET),am1-s9)

define Build/Configure
	( cd $(PKG_BUILD_DIR); ./setminertype S9 )
	echo "#define BOS_FIRMWARE_VERSION \"$(SUBTARGET)_$(CONFIG_FIRMWARE_VERSION)\"" > "$(PKG_BUILD_DIR)/braiins-os.h"
endef

define Build/Compile
	+$(MAKE) CROSS_PREFIX=$(TARGET_CROSS) -C $(PKG_BUILD_DIR)
endef

define Package/cgminer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bmminer $(1)/usr/bin/cgminer
	$(INSTALL_BIN) ./files/cgminer_config_migrate.lua $(1)/usr/bin/cgminer_config_migrate

	$(INSTALL_DIR) $(1)/etc/bmminer
	$(INSTALL_BIN) ./files/am/hash_s8_app.txt $(1)/etc/bmminer/
	$(INSTALL_BIN) ./files/am/dsPIC33EP16GS202_app.txt $(1)/etc/bmminer/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(call INSTALL_INIT,./files/cgminer.init,./files/cgminer-am.init,$(1)/etc/init.d/cgminer)
endef

else

CPGEN_CONFIGURE:= \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -Os -g -ggdb" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	./configure \
	--prefix="/usr" \
	--enable-bitmine_A5 \
	--without-curses \
	--host="$(GNU_TARGET_NAME)" \
	--build="$(GNU_HOST_NAME)"

define Build/Configure
	( cd $(PKG_BUILD_DIR); sed -i "s/#define CHIP_A[0-9]/#define CHIP_A5/g" "$(PKG_BUILD_DIR)/miner.h" )
	echo "#define BOS_FIRMWARE_VERSION \"$(SUBTARGET)_$(CONFIG_FIRMWARE_VERSION)\"" > "$(PKG_BUILD_DIR)/braiins-os.h"
	( cd $(PKG_BUILD_DIR); ./autogen.sh )
	( cd $(PKG_BUILD_DIR); $(CPGEN_CONFIGURE) )
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)
	+$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		install
endef

define Package/cgminer/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cgminer $(1)/usr/bin/cgminer
	$(INSTALL_BIN) ./files/cgminer-shutdown.sh $(1)/usr/bin/cgminer-shutdown.sh

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(call INSTALL_INIT,./files/cgminer.init,./files/cgminer-dm.init,$(1)/etc/init.d/cgminer)
endef

endif

$(eval $(call BuildPackage,cgminer))
