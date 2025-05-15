# Development Packages:
# * Required: h8300 binutils

# Using $(abspath x) here so that symlinks are NOT replaced
MAKEFILE_PATH  := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR   := $(abspath $(dir $(MAKEFILE_PATH)))
MAKEFILE_NAME  := $(notdir $(MAKEFILE_PATH))

TARGET_ARCH = h8300-lego-coff

CROSSTOOLPREFIX ?= h8300-hitachi-coff-
CROSSTOOLSUFFIX ?= -3

CROSSAS ?= $(CROSSTOOLPREFIX)as$(CROSSTOOLSUFFIX)
CROSSLD ?= $(CROSSTOOLPREFIX)ld$(CROSSTOOLSUFFIX)
CROSSOBJCOPY ?= $(CROSSTOOLPREFIX)objcopy$(CROSSTOOLSUFFIX)

SRC_DIR = src
BUILD_DIR ?= build
OBJ_DIR = $(BUILD_DIR)

BASENAME = foss-rom
OUTPUT_TYPES ?= coff bin srec ld
OUTPUT_FILES = $(OUTPUT_TYPES:%=$(BASENAME).%)
OUTPUT_FILE_PATHS = $(OUTPUT_FILES:%=$(BUILD_DIR)/%)

# Installation Path Configuration
DESTDIR ?=
prefix ?= /opt/stow/foss-rcx-rom
pkgtargetkerneldir ?= ${prefix}/${TARGET_ARCH}/boot


all: $(OUTPUT_FILE_PATHS)

clean:
	rm -f -r $(BUILD_DIR)

realclean: clean

install: $(OUTPUT_FILE_PATHS)
	test -d $(DESTDIR)$(pkgtargetkerneldir) || mkdir -p $(DESTDIR)$(pkgtargetkerneldir)
	install -v --mode=644 $(OUTPUT_FILE_PATHS) "$(DESTDIR)$(pkgtargetkerneldir)"

uninstall:
	cd "$(DESTDIR)$(pkgtargetkerneldir) && rm -f $(OUTPUT_FILES)


$(BUILD_DIR)/%.ld: $(SRC_DIR)/%.ld
	test -d $(BUILD_DIR) || mkdir -p $(BUILD_DIR)
	test -d $(OBJ_DIR) || mkdir -p $(OBJ_DIR)
	cp $< $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s $(SRC_DIR)/%-lcd.s  $(BUILD_DIR)/%.ld
	$(CROSSAS) -I $(SRC_DIR) -o $@ $<

$(BUILD_DIR)/%.coff: $(OBJ_DIR)/%.o $(SRC_DIR)/%.ld
	$(CROSSLD) -T $(word 2,$^) -relax -nostdlib $< -o $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.coff
	$(CROSSOBJCOPY) -I coff-h8300 -O binary $< $@

$(BUILD_DIR)/%.srec: $(BUILD_DIR)/%.coff
	$(CROSSOBJCOPY) -I coff-h8300 -O srec $< $@


#  Cancel default rules
.SUFFIXES:

include $(MAKEFILE_DIR)/Makefile.utility
