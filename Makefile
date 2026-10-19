ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:8.4:8.4

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GestureX
GestureX_FILES = Tweak.xm
GestureX_FRAMEWORKS = UIKit
GestureX_PRIVATE_FRAMEWORKS = SpringBoard

include $(THEOS_MAKE_PATH)/tweak.mk
