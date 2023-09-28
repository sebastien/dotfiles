PROFILE=base
DEPS_BASH:=sync-history.sh preexec.sh
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

$(HOME)/.%: $(PROFILE)/%
	@if [ -f "$@" ] || [ -d "$@" ]; then mv "$@" "$(call mkdir-parent,$(BASE)backup/$(NOW)/$*)"; fi
	@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	@ln -sfr $< "$@"
	$(info Installed $< as $@)

$(HOME)/.local/bin/%: bin/%
	@if [ -f "$@" ] || [ -d "$@" ]; then mv "$@" "$(call mkdir-parent,$(BASE)backup/$(NOW)/$*)"; fi
	@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	@ln -sfr $< "$@"
	$(info Installed script $< as $@)

base/config/bash/sync-history.sh:
	curl -o "$@" "https://gist.githubusercontent.com/jan-warchol/89f5a748f7e8a2c9e91c9bc1b358d3ec/raw/79221bce28d1ca70daeba3e079e0bbe6fafd89b0/sync-history.sh"

base/config/bash/preexec.sh:
	curl -o "$@" "https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh"

print-%:
	$(info $*=$(subst $(SPACE),$(NEWLINE),$($*)))
# EOF
