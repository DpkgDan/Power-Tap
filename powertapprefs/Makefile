ARCHS = armv7 arm64
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include theos/makefiles/common.mk

BUNDLE_NAME = PowerTapPrefs
PowerTapPrefs_FILES = PowerTapPrefs.mm
PowerTapPrefs_INSTALL_PATH = /Library/PreferenceBundles
PowerTapPrefs_FRAMEWORKS = UIKit
PowerTapPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PowerTapPrefs.plist$(ECHO_END)
