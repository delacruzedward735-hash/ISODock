IsoDock 1.0.0-2
================
Bootable USB Manager for Linux
Powered by the Ventoy 1.1.17 open-source engine.

What changed in this release
----------------------------
- Keeps the working native GTK3 GUI and Ventoy disk-writing backend.
- Keeps the IsoDock application/window branding.
- Installs the selected IsoDock icon at standard desktop icon sizes.
- Integrates the IsoDock-branded 32 MiB GRUB/EFI boot-menu payload.
- Keeps the proven 512-byte BIOS boot sector byte-compatible.
- Adds a diagnostic check for the IsoDock boot-menu marker.

Install
-------
  sudo apt install ./isodock_1.0.0-2_amd64.deb

Check
-----
  isodock --version
  isodock --doctor

Launch
------
  isodock

Expected application version: 1.0.0
Engine version: Ventoy 1.1.17

Important
---------
Installing a multiboot manager changes the selected USB disk. Back up important
files and verify the target disk before confirming Install.

The package is statically/package tested, including the exact native GUI launch
under a virtual X desktop. A real USB/firmware boot test is still required on
physical hardware.

Licensing
---------
IsoDock is an independent rebrand/packaging layer powered by the Ventoy
open-source engine. Upstream license notices and internal compatibility names
are retained where required. IsoDock is not affiliated with or endorsed by the
official Ventoy project.
