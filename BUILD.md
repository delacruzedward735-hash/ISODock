# Building IsoDock

## Fast package build

The release package is reproducible offline from the shipped runtime template:

```bash
make verify
make deb
```

This creates `out/isodock_1.0.0-6_amd64.deb`.

## Rebuild the IsoDock boot theme

`IsoDock/scripts/rebuild-boot-image.sh` recompiles a small FAT16 helper against Ventoy's bundled `fat_io_lib`, updates the real VTOYEFI image, reads every modified file back, validates the Ventoy engine version and Secure Boot payload, then recompresses it with an XZ CRC32 check.

```bash
make boot-image
```

This path does not need loop devices or privileged filesystem mounts.

## Rebuild native GTK GUI from source

The full modified upstream source is included under `Ventoy/`. Native GUI changes are in `Ventoy/LinuxGUI/Ventoy2Disk/`. Building that layer requires the upstream LinuxGUI toolchain and GTK3 development headers.

The validated runtime binary is included under `IsoDock/runtime-template/` so Debian packaging does not depend on network downloads or a full cross-toolchain.

## Release archive

```bash
make release
```

This produces the `.deb`, checksums and the complete corresponding source archive under `out/`.
