# Changelog

## IsoDock 1.0.0-6 — open-source release candidate

- Finalized IsoDock boot-theme shell, blue selection bar, and scrollbar assets.
- Verified the boot background by extracting it back from the shipped VTOYEFI image.
- Kept the real dynamic ISO/image list and upstream boot shortcuts.
- Added source/runtime integrity checks and the Zorin-style mountpoint regression test.
- Corrected repository build paths for the flattened GitHub source layout.
- Added a pinned upstream-source workflow for Ventoy 1.1.17 commit `7cbdc5cf69935bcf1f085ae67f40e70ea7e74bae`.
- Added deterministic downstream override tooling and GTK icon-source generation.
- Added GPL license, notices, upstream/source policy, contribution guide, code of conduct, support policy, issue templates, PR template, and CI.
- Updated Debian package/build metadata consistently to revision `1.0.0-6`.

## IsoDock 1.0.0-4 — consolidated source

- Consolidated downstream source, runtime, branding, packaging, and tests.
- Rebuilt the VTOYEFI theme around IsoDock branding while preserving Ventoy boot behavior.
- Removed sample/demo plugin configuration from the shipped runtime template.
- Added VTOYEFI parser and Secure Boot payload checks.
- Added offline FAT image modification tooling.

## IsoDock 1.0.0-3

- Moved packaged runtime under `/usr/lib/isodock`.
- Added per-user configuration/log storage.
- Added runtime SHA-256 integrity manifest and AppStream metadata.
