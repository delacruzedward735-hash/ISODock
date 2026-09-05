# IsoDock 1.0.0-6 Release Notes

IsoDock 1.0.0-6 is the first source tree prepared specifically for public open-source collaboration.

## Highlights

- Native GTK3 Linux installer/updater interface.
- Ventoy engine 1.1.17 pinned to upstream commit `7cbdc5cf69935bcf1f085ae67f40e70ea7e74bae`.
- Final IsoDock boot-theme assets with dynamic ISO listing.
- BIOS/UEFI payloads and retained upstream Secure Boot files.
- USB automount handling fixed for mountpoint labels containing spaces.
- `isodock --doctor` runtime/boot-integrity diagnostics.
- Debian `.deb` build tooling.
- Public-source governance files and CI.
- Complete-source archive target that bundles the pinned upstream tree for binary-release compliance.

## Important safety note

IsoDock performs destructive block-device operations during installation. Validate the selected USB device carefully and use disposable media for testing.

## Hardware QA

Automated source/runtime/package checks are not a substitute for physical firmware testing. Before presenting a build as hardware-certified stable, test the exact release artifact across the scenarios in `PHYSICAL-QA-CHECKLIST.md`.
