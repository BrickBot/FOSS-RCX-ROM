## ======================================================================================================== ##
## IMPORTANT NOTE: This Makefile setup is designed to work both standalone and integrated with brickOS-bibo ##
##   - Makefile:     For building stand-alone                                                               ##
##   - Makefile.sub: For building as part of brickOS-bibo                                                   ##
## ======================================================================================================== ##

# Development Packages:
# * Required: h8300 binutils

# Using $(abspath x) here so that symlinks are NOT replaced
MAKEFILE_PATH  := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR   := $(abspath $(dir $(MAKEFILE_PATH)))
MAKEFILE_NAME  := $(notdir $(MAKEFILE_PATH))

TARGET_ARCH = h8300-lego-coff

CROSSTOOLPREFIX ?= h8300-hitachi-coff-
CROSSTOOLSUFFIX ?=

CROSSAS ?= $(CROSSTOOLPREFIX)as$(CROSSTOOLSUFFIX)
CROSSLD ?= $(CROSSTOOLPREFIX)ld$(CROSSTOOLSUFFIX)
CROSSOBJCOPY ?= $(CROSSTOOLPREFIX)objcopy$(CROSSTOOLSUFFIX)

ROM_BASESUBDIR = .

# Installation Path Configuration
DESTDIR ?=
prefix ?= /opt/stow/foss-rcx-rom
pkgtargetkerneldir ?= ${prefix}/${TARGET_ARCH}/boot


all: rom

clean: rom-clean

realclean: rom-realclean

install: rom-install

uninstall: rom-uninstall


include $(MAKEFILE_DIR)/Makefile.sub


$(ROM_FILES_BASE).bin: $(ROM_FILES_BASE).coff
	$(CROSSOBJCOPY) -I coff-h8300 -O binary $< $@

$(ROM_FILES_BASE).srec: $(ROM_FILES_BASE).coff
	$(CROSSOBJCOPY) -I coff-h8300 -O srec $< $@


#  Cancel default rules
.SUFFIXES:

include $(MAKEFILE_DIR)/Makefile.utility
