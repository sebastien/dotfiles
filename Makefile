PROFILE=base
DEPS=base/config/bash/sync-history.sh
SOURCES=$(shell find $(PROFILE) -type f)
ACTIVE=$(filter $(PROFILE)/%,$(SOURCES) $(DEPS))
PRODUCT=$(ACTIVE:$(PROFILE)/%=$(HOME)/.%)
NOW:=$(shell date +"%Y-%m-%dT%H:%M:%S")

# TODO: Should detect if there is a change between the current version and the
# installed version.
install: $(PRODUCT)
	$(info Profile installed)

$(HOME)/.%: $(PROFILE)/%
	@if [ -f "$@" ] || [ -d "$@" ]; then mv "./backup/$(NOW)/$*"; fi
	@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	@ln -sfr $< "$@"
	$(info Installed $< as $@)

base/config/bash/sync-history.sh:
	curl -o "$@" "https://gist.githubusercontent.com/jan-warchol/89f5a748f7e8a2c9e91c9bc1b358d3ec/raw/79221bce28d1ca70daeba3e079e0bbe6fafd89b0/sync-history.sh"

# EOF
