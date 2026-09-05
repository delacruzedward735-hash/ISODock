# IsoDock downstream modifications

IsoDock 1.0.0-6 is based on Ventoy 1.1.17 and keeps the upstream disk/boot engine recognizable and attributable.

Pinned upstream commit:

```text
7cbdc5cf69935bcf1f085ae67f40e70ea7e74bae
```

## Downstream changes

### Linux desktop integration

- Rebranded the native GTK window title and visible package/device labels to IsoDock.
- Replaced the GTK window icon with IsoDock artwork via reproducible `window_icon_data.c` generation.
- Added Debian package, launcher, desktop entry, AppStream metadata, icons, logs/config paths, and diagnostics.

### USB unmount robustness

- Changed the Linux unmount path to operate on the block-device source (for example `/dev/sdc1`) instead of relying on an escaped mountpoint pathname from `/proc/mounts`.
- Added a regression check for labels/mountpoints containing spaces.

### Boot interface

- Added the IsoDock GRUB/VTOYEFI background and selection/scrollbar assets.
- Changed visible version text to identify `IsoDock 1.0.0` while retaining the Ventoy engine version.
- Kept the real engine hotkeys and dynamic image listing.

### Runtime template cleanup

- Removed sample custom-menu and unattended-install examples from the production plugin template.
- Added runtime SHA-256 manifests and source-derived checks.

## Reproduction

Run:

```bash
make prepare-upstream
```

The application of these changes is implemented by `scripts/apply-upstream-overrides.sh` using committed downstream assets and deterministic patch/application scripts.
