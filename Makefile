PROFILE=base
SOURCES=$(shell find $(PROFILE) -type f -or -type l)
ACTIVE=$(filter $(PROFILE)/%,$(SOURCES) $(DEPS_BASH:%=base/config/bash/%))
SCRIPTS=$(wildcard bin/*)
PRODUCT=$(ACTIVE:$(PROFILE)/%=$(HOME)/.%) $(TOOLS:%=deps/bin/%) $(SCRIPTS:%=$(HOME)/.local/%)
NOW:=$(shell date +"%Y-%m-%dT%H:%M:%S")
BASE:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TOOLS:=
SPACE:=$(NULL) $(NULL)
define NEWLINE
$(if 1,
,)
endef
EOL:=$(NEWLINE)

mkdir-parent=$(shell if [ ! -d "$(dir $(1))" ]; then mkdir -p "$(dir $(1))"; fi; echo "$(1)")

# TODO: Should detect if there is a change between the current version and the
# installed version.
install: $(PRODUCT)
	$(info Profile installed)

uninstall:
	@for ITEM in $(PRODUCT); do
		if [ -L "$$ITEM" ]; then
			unlink "$$ITEM"
		fi
	done

$(HOME)/.%: $(PROFILE)/% .FORCE
	@if [ -f "$@" ] || [ -d "$@" ]; then mv "$@" "$(call mkdir-parent,$(BASE)backup/$(NOW)/$*)"; fi
	@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	@ln -sfr $< "$@"
	$(info Installed $< as $@)

$(HOME)/.local/bin/%: bin/% .FORCE
	@if [ -f "$@" ] || [ -d "$@" ]; then mv "$@" "$(call mkdir-parent,$(BASE)backup/$(NOW)/$*)"; fi
	@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	@ln -sfr $< "$@"
	$(info Installed script $< as $@)

print-%:
	$(info $*=$(subst $(SPACE),$(NEWLINE),$($*)))

.FORCE:
.ONESHELL:
# EOF
