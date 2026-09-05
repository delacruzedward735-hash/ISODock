# Upstream source

IsoDock 1.0.0-6 is based on the Ventoy **1.1.17** source line.

Pinned upstream commit:

```text
7cbdc5cf69935bcf1f085ae67f40e70ea7e74bae
```

Official upstream repository:

```text
https://github.com/ventoy/Ventoy
```

## Fetching the exact upstream tree

Run:

```bash
make prepare-upstream
```

The source is placed under:

```text
.cache/upstream/Ventoy
```

The script verifies that `HEAD` is the commit pinned in `VERSION`, then applies the IsoDock downstream source changes.

## What IsoDock changes

The downstream layer includes:

- native GUI branding and icon resource;
- English/global visible product strings that distinguish IsoDock from Ventoy;
- robust unmount-by-source handling for USB mountpoints containing spaces;
- IsoDock GRUB/VTOYEFI theme assets;
- removal of sample/demo plugin configuration from the shipped runtime template;
- Debian/Linux packaging and diagnostics.

See `MODIFICATIONS.md` for the maintained change list.
