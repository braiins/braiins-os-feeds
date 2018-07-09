#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

PKG_NAME:=u-boot
PKG_VERSION:=2016.03

ifeq ($(strip $(CONFIG_EXTERNAL_UBOOT_TREE)),"")
	PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
	PKG_SOURCE_URL:= \
		http://mirror2.openwrt.org/sources \
		ftp://ftp.denx.de/pub/u-boot
else
	PKG_SOURCE_VERSION:=local
    USE_SOURCE_DIR:=$(call qstrip,$(CONFIG_EXTERNAL_UBOOT_TREE))
endif

PKG_HASH:=e49337262ecac44dbdeac140f2c6ebd1eba345e0162b0464172e7f05583ed7bb

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0 GPL-2.0+
PKG_LICENSE_FILES:=Licenses/README

include $(INCLUDE_DIR)/package.mk

define uboot/Default
	TITLE:=
	CONFIG:=
	IMAGE:=
endef

define uboot/dm1-g9-sd
	TITLE:=U-Boot $(PKG_VERSION) for DragonMint T1/G9 Miner Control Board (SD)
	CONFIG:=dm1_g9_sd
endef
UBOOTS += dm1-g9-sd

define uboot/dm1-g19-sd
	TITLE:=U-Boot $(PKG_VERSION) for DragonMint T1/G19 Miner Control Board (SD)
	CONFIG:=dm1_g19_sd
endef
UBOOTS += dm1-g19-sd

define uboot/am1-s9-sd
	TITLE:=U-Boot $(PKG_VERSION) for AntMiner S9 Miner Control Board (SD)
	CONFIG:=am1_s9_sd
endef
UBOOTS += am1-s9-sd

define uboot/dm1-g9
	TITLE:=U-Boot $(PKG_VERSION) for DragonMint T1/G9 Miner Control Board
	CONFIG:=dm1_g9
endef
UBOOTS += dm1-g9

define uboot/dm1-g19
	TITLE:=U-Boot $(PKG_VERSION) for DragonMint T1/G19 Miner Control Board
	CONFIG:=dm1_g19
endef
UBOOTS += dm1-g19

define uboot/am1-s9
	TITLE:=U-Boot $(PKG_VERSION) for AntMiner S9 Miner Control Board
	CONFIG:=am1_s9
endef
UBOOTS += am1-s9

define Package/uboot-zynq-dm1-g9-sd/config
	source "$(SOURCE)/Config.in"
endef

define Package/uboot/template
define Package/uboot-zynq-$(1)
	SECTION:=boot
	CATEGORY:=Boot Loaders
	DEPENDS:=@TARGET_zynq_$(subst -,_,$(subst -sd,,$(1)))
	TITLE:=$(2)
	URL:=http://www.denx.de/wiki/U-Boot
	VARIANT:=$(1)
	MAINTAINER:=Libor Vasicek <libor.vasicek@braiins.cz>
endef
endef

define BuildUBootPackage
	$(eval $(uboot/Default))
	$(eval $(uboot/$(1)))
	$(call Package/uboot/template,$(1),$(TITLE))
endef

ifdef BUILD_VARIANT
$(eval $(call uboot/$(BUILD_VARIANT)))
UBOOT_CONFIG:=$(if $(CONFIG),$(CONFIG),$(BUILD_VARIANT))
UBOOT_IMAGE:=$(if $(IMAGE),$(IMAGE),openwrt-$(BOARD)-$(BUILD_VARIANT)-u-boot.bin)
endif

define Build/Configure
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		$(BOARD)_$(UBOOT_CONFIG)_config DTC=$(LINUX_DIR)/scripts/dtc/dtc
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE=$(TARGET_CROSS)
endef

define Package/uboot/install/default
	$(INSTALL_DIR) $(BIN_DIR)/uboot-$(BOARD)-$(1)

	$(CP) $(PKG_BUILD_DIR)/spl/boot.bin \
		$(BIN_DIR)/uboot-$(BOARD)-$(1)
	$(CP) $(PKG_BUILD_DIR)/u-boot.img \
		$(BIN_DIR)/uboot-$(BOARD)-$(1)
endef

define Package/uboot/install/template
define Package/uboot-zynq-$(1)/install
	$(call Package/uboot/install/default,$(2))
endef
endef

$(foreach u,$(UBOOTS), \
	$(eval $(call Package/uboot/install/template,$(u),$(u))) \
)

$(foreach u,$(UBOOTS), \
	$(eval $(call BuildUBootPackage,$(u))) \
	$(eval $(call BuildPackage,uboot-zynq-$(u))) \
)
