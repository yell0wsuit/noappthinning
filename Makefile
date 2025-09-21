include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NoAppThinning

NoAppThinning_FILES = Tweak.xm
NoAppThinning_ARCHS = arm64 arm64e
NoAppThinning_LIBRARIES = MobileGestalt
NoAppThinning_LDFLAGS = -Wl,-segalign,4000
NoAppThinning_CFLAGS += -Wno-deprecated-module-dot-map

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 AppStore"
