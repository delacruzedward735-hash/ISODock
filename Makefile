SHELL := /bin/bash
OUT ?= $(CURDIR)/out

.PHONY: help prepare-upstream apply-upstream verify boot-image deb source-archive release clean gui-smoke

help:
	@printf '%s\n' \
	  'IsoDock build targets:' \
	  '  make prepare-upstream  Fetch pinned Ventoy source and apply IsoDock changes' \
	  '  make verify            Validate runtime, metadata, theme and scripts' \
	  '  make boot-image        Rebuild the embedded VTOYEFI boot image' \
	  '  make deb               Build out/isodock_1.0.0-6_amd64.deb' \
	  '  make source-archive    Build complete corresponding-source archive' \
	  '  make release           Build binary + source release artifacts' \
	  '  make gui-smoke         Non-destructive GTK launch under Xvfb'

prepare-upstream:
	./scripts/fetch-upstream.sh

apply-upstream: prepare-upstream
	./scripts/apply-upstream-overrides.sh

verify:
	./tests/verify-source.sh
	./tests/test-mount-space-regression.sh

boot-image: apply-upstream
	./scripts/rebuild-boot-image.sh

deb: verify
	mkdir -p "$(OUT)"
	./packaging/build-deb.sh "$(OUT)/isodock_1.0.0-6_amd64.deb"

source-archive: apply-upstream
	mkdir -p "$(OUT)"
	./scripts/build-source-archive.sh "$(OUT)"

gui-smoke:
	ISODOCK_GUI_SMOKE=1 ./tests/verify-source.sh

release: deb source-archive
	./scripts/build-release.sh "$(OUT)"

clean:
	rm -rf "$(OUT)" .cache/upstream .cache/source-stage
