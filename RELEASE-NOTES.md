# IsoDock 1.0.0-6 Complete Source / Production Candidate

Engine: Ventoy 1.1.17  
Architecture: amd64 / x86_64

## Main changes

- Final approved silver/blue IsoDock boot visual integrated into the real VTOYEFI image.
- Background contains no fake ISO names; the engine renders the actual USB image list dynamically.
- Real blue gradient selected-row asset embedded in the boot image.
- Real blue scrollbar assets embedded in the boot image.
- Boot menu geometry refined to align with the approved mockup while staying firmware-safe.
- Real engine hotkey tip remains dynamic/localized: L Language, F1 Help, F2 Browse, F3 List/Tree, F4 Localboot, F5 Tools, F6 Menu.
- Complete read-back tests verify the embedded background, theme, selection bar, scrollbars and grub.cfg.
- Secure Boot payload, BIOS/UEFI engine files, native GTK3 writer and USB automount-space fix are retained.
- Complete corresponding source, Debian packaging, diagnostics, CI and license notices are included.

## Hardware release gate

Before calling the release hardware-certified stable, test the exact `.deb` on disposable USB media for:

- MBR installation and update.
- GPT installation and update.
- UEFI boot.
- Secure Boot enrollment/boot path where supported by the target firmware.
- Legacy BIOS boot if hardware is available.
- Linux ISO and Windows ISO boot.
- USB labels containing spaces.
- Update without deleting existing ISO files.
- At least one 1024x768-style firmware display and one widescreen firmware display.
