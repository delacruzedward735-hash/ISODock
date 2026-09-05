# Source distribution policy

IsoDock is distributed under GPL-compatible terms and includes GPL-licensed upstream components. Binary releases must be accompanied by a practical path to the corresponding source.

## Repository source

This repository stores:

- all IsoDock downstream source and scripts;
- deterministic downstream patch/application scripts;
- boot-theme / icon assets;
- packaging and build logic;
- runtime checksums and third-party notices;
- the exact upstream commit identifier.

The full upstream tree is intentionally not duplicated in normal Git history. `make prepare-upstream` fetches the pinned source from the official Ventoy repository and applies the downstream changes deterministically.

## Source release archives

When publishing an IsoDock binary release, maintainers should also run:

```bash
make source-archive
```

and publish the resulting archive beside the binary. The source archive includes the pinned upstream source tree plus the IsoDock downstream files needed to rebuild the release.

Maintainers should keep source archives available for as long as the corresponding binary release is offered.
