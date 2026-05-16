ifeq ($(DEVKITPRO),)
  $(error DEVKITPRO is not set. Install devkitPro and restart your terminal.)
endif
DEVKITARM ?= $(DEVKITPRO)/devkitARM

PREFIX    := $(DEVKITARM)/bin/arm-none-eabi-
CC        := $(PREFIX)gcc
STRIP     := $(PREFIX)strip
TOOL_3DSX := $(DEVKITPRO)/tools/bin/3dsxtool
NIM       ?= nim
NIMLIB    ?= $(shell dirname $(shell which $(NIM)))/../lib

TARGET    := nim-3ds-homebrew
BUILD     := build
NIMCACHE  := nimcache
SRC_NIM   := src/demo.nim

ARCH      := -march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft
CFLAGS    := -g -Wall -O2 -mword-relocations -fomit-frame-pointer \
             -ffunction-sections $(ARCH) -D__3DS__ -D_3DS \
             -I$(DEVKITPRO)/libctru/include -I$(NIMLIB)
LDFLAGS   := -specs=$(DEVKITARM)/arm-none-eabi/lib/3dsx.specs -g $(ARCH) \
             -Wl,-Map,$(BUILD)/$(TARGET).map
LIBS      := -L$(DEVKITPRO)/libctru/lib -lctru -lm

.PHONY: all clean nim-compile

all: $(TARGET).3dsx

nim-compile:
	$(NIM) c -d:nintendo3ds $(SRC_NIM)

# Compile all Nim-generated C files and link in one step.
# $(shell find ...) expands at recipe execution time (after nim-compile runs),
# so it correctly picks up the C files Nim just generated.
$(TARGET).elf: nim-compile
	@mkdir -p $(BUILD)
	$(CC) $(CFLAGS) $(LDFLAGS) \
		$(shell find $(NIMCACHE) -name "*.c") \
		$(LIBS) -o $@
	$(STRIP) -x $@

$(TARGET).3dsx: $(TARGET).elf
	$(TOOL_3DSX) $< $@

clean:
	rm -rf $(BUILD) $(NIMCACHE) $(TARGET).elf $(TARGET).3dsx
