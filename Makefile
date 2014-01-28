###############################################################################
# This makefile requires bash
###############################################################################

# Set bash shell for all OSs except MS Windows
ifndef COMSPEC
SHELL := /bin/bash
endif

WHEREAMI := $(dir $(lastword $(MAKEFILE_LIST)))

# Decide on a verbosity level based on the V= parameter
export AT := @

ifndef V
    export V0 :=
    export V1 := $(AT)
else ifeq ($(V), 0)
    export V0 := $(AT)
    export V1 := $(AT)
else ifeq ($(V), 1)
endif

# Make sure we know a few things about the architecture before including
# the tools.mk to ensure that we download/install the right tools.
UNAME := $(shell uname)
ARCH := $(shell uname -m)

# define tools
GIT ?= git
REMOVE ?= rm -f
MKDIR ?= mkdir -p
TAR ?= tar
COPY ?= cp

# Test if quotes are needed for the echo-command
result = ${shell echo "test"}
ifeq (${result}, test)
    quote := '
# This line is just to clear out the single quote above '
else
    quote :=
endif

# Add a board designator to the terse message text
ifeq ($(ENABLE_MSG_EXTRA),yes)
    MSG_EXTRA := [$(shell printf '%-3s' $(BUILD_PREFIX))|$(shell printf '%-14s' $(BOARD_NAME))]
else
    MSG_EXTRA :=
endif

MSG_VERSION            = ${quote} VERSION     $(MSG_EXTRA)${quote}
MSG_CLEAN              = ${quote} CLEAN       $(MSG_EXTRA)${quote}
MSG_COPY               = ${quote} COPY        $(MSG_EXTRA)${quote}
MSG_TAR                = ${quote} TAR         $(MSG_EXTRA)${quote}

toprel = $(subst $(realpath $(ROOT_DIR))/,,$(abspath $(1)))

# incoming parameters
PRODUCT_NAME ?= unnamed
PRODUCT_FILES ?= 
PROGRAMMER ?= openocd
BUILD_DIR ?= $(ROOT_DIR)/build


GIT_DATE := $(shell $(GIT) log -n1 --no-color --format=format:%ci HEAD)

# try to get remote tracking branch
GIT_BRANCH ?= $(shell git rev-parse --symbolic-full-name --abbrev-ref @{u} 2> /dev/null)

# if that failed, get local branch
ifeq ($(GIT_BRANCH),@{u})
    GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
endif

# check if we are dirty
ifneq ($(shell git diff HEAD),)
    GIT_BRANCH := $(join $(GIT_BRANCH),-dirty)
endif

GIT_COMMIT := $(shell $(GIT) rev-parse --verify --short=10 HEAD)

PACKAGE_DATE := $(shell date -u -d "$(GIT_DATE)" +%Y%m%d_%H%M%S)
PACKAGE_BRANCH := $(subst _,-,$(subst /,-,$(GIT_BRANCH)))
PACKAGE_COMMIT := $(GIT_COMMIT)
PACKAGE_NAME := $(PRODUCT_NAME)_$(PACKAGE_BRANCH)_$(PACKAGE_DATE)_$(PACKAGE_COMMIT)
PACKAGE_FILES := $(wildcard $(PRODUCT_FILES))
PACKAGE_DIR := $(BUILD_DIR)$(PACKAGE_NAME)/

ALL_OUTFILES := $(addprefix $(PACKAGE_DIR),$(notdir $(PACKAGE_FILES))) $(PACKAGE_DIR)/version.txt

.PHONY: all
all: $(BUILD_DIR)$(PACKAGE_NAME).tar.bz2

$(BUILD_DIR)$(PACKAGE_NAME).tar.bz2: $(ALL_OUTFILES) FORCE | $(PACKAGE_DIR)
	$(V1) $(COPY) -r $(WHEREAMI)$(PROGRAMMER)/* $(PACKAGE_DIR)
	$(V1) $(COPY) -r $(WHEREAMI)tools $(PACKAGE_DIR)
	@echo $(MSG_TAR) $(call toprel, $@)
	$(V1) cd $(BUILD_DIR) && $(TAR) -cpjf $(PACKAGE_NAME).tar.bz2 $(PACKAGE_NAME)

.PHONY: clean
clean:
	@echo $(MSG_CLEAN) $(call toprel, $(PACKAGE_DIR))
	$(V1) [ ! -d "$(PACKAGE)" ] || $(REMOVE) -r $(PACKAGE_DIR)
	@echo $(MSG_CLEAN) $(call toprel, $(BUILD_DIR)$(PACKAGE_NAME).tar.bz2)
	$(V1) [ ! -f "$(BUILD_DIR)$(PACKAGE_NAME).tar.bz2" ] || $(REMOVE) -r $(BUILD_DIR)$(PACKAGE_NAME).tar.bz2

$(PACKAGE_DIR):
	$(V1) $(MKDIR) $@

# pseudo target to force execution
FORCE:

# copy: template to copy PACKAGE_FILES to package dir
define COPY_TEMPLATE
$(2)$(notdir $(1)) : $(1) FORCE | $(2)
	@echo $(MSG_COPY) $$(call toprel, $$<)
	$(V1) $(COPY) $$< $(2)$(notdir $(1))
endef

# Expand the copy rules
$(foreach file, $(PACKAGE_FILES), $(eval $(call COPY_TEMPLATE,$(file),$(PACKAGE_DIR))))

$(PACKAGE_DIR)/version.txt: | $(PACKAGE_DIR)
	@echo $(MSG_VERSION) $(call toprel, $@)
	$(V1) echo $(PACKAGE_NAME) > $@

