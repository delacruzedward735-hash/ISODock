# IsoDock downstream modifications

IsoDock retains Ventoy as the boot and disk-writing engine. Downstream changes are intentionally narrow and auditable.

1. **Native GTK branding** — window title, visible labels, translated display strings and application icon are branded IsoDock while internal compatibility identifiers remain unchanged.
2. **Boot menu theme** — `INSTALL/grub/grub.cfg`, the Ventoy theme and VTOYEFI image carry IsoDock branding. The background contains no fake ISO entries; the real engine populates the list.
3. **Boot choice cleanup** — no sample `My Custom Menu`, fake aliases or unattended-install demos are enabled in the production plugin template.
4. **USB automount robustness** — `INSTALL/tool/ventoy_lib.sh` unmounts by block-device source, not escaped mountpoint text, then waits for udev and retries once. This addresses paths such as `/media/user/ZORIN\040OS\04018`.
5. **Linux packaging** — FHS layout, per-user settings/logs, AppStream metadata, runtime integrity checks, `.deb` scripts and upgrade metadata.
6. **Release tooling** — source verification, FAT image read-back validation, Secure Boot payload check, package build automation and CI.

The Ventoy engine version remains 1.1.17 and is explicitly disclosed in diagnostics and licensing documentation.
