PROFILE=base
DEPS_BASH:=sync-history.sh preexec.sh atuin.sh
SOURCES=$(shell find $(PROFILE) -type f)
ACTIVE=$(filter $(PROFILE)/%,$(SOURCES) $(DEPS_BASH:%=base/config/bash/%))
PRODUCT=$(ACTIVE:$(PROFILE)/%=$(HOME)/.%) $(TOOLS:%=deps/bin/%)
NOW:=$(shell date +"%Y-%m-%dT%H:%M:%S")
BASE:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TOOLS:=atuin

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

base/config/bash/sync-history.sh:
	curl -o "$@" "https://gist.githubusercontent.com/jan-warchol/89f5a748f7e8a2c9e91c9bc1b358d3ec/raw/79221bce28d1ca70daeba3e079e0bbe6fafd89b0/sync-history.sh"

base/config/bash/preexec.sh:
	curl -o "$@" "https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh"

base/config/bash/atuin.sh: deps/bin/atuin
	echo 'eval "$$(atuin init bash)"' > "$@"

deps/bin/atuin:
	@echo $(call mkdir-parent,$@)
	@if [ ! "$$(which atuin 2> /dev/null)" ]; then cargo install atuin; fi
	@which atuin && ln -sfr $$(which atuin) "$@"; true


# EOF
