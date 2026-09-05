# Contributing to IsoDock

Thanks for helping improve IsoDock.

IsoDock is a downstream Linux project built around the Ventoy open-source engine. The most important engineering rule is to keep disk-writing and boot changes small, reviewable, and testable.

## Before opening a pull request

1. Fork the repository and create a focused branch.
2. Keep unrelated formatting or mass-renaming out of functional changes.
3. Run:

```bash
make verify
make deb
```

4. If you changed boot-theme or upstream-derived behavior, also run:

```bash
make boot-image
make verify
```

5. For destructive write-path changes, test only on disposable USB media and document exactly what was tested.

## Coding / scripting conventions

- Shell scripts use `#!/usr/bin/env bash` and `set -euo pipefail` where appropriate.
- Quote paths and device variables.
- Never weaken the system-disk or mounted-device safety checks for convenience.
- Preserve upstream copyright/license headers in derived files.
- Add an SPDX identifier to new downstream-only source files when practical: `SPDX-License-Identifier: GPL-3.0-or-later`.
- Do not commit build outputs (`out/`, `.deb`, logs, temporary upstream checkout).

## Upstream-derived changes

If a change modifies Ventoy-derived source:

- document it in `MODIFICATIONS.md`;
- update the deterministic application scripts or assets that reproduce the change;
- retain the original license notices;
- explain why the divergence from upstream is necessary.

## Pull request checklist

- [ ] `make verify` passes
- [ ] `make deb` passes
- [ ] No generated build artifacts were committed accidentally
- [ ] License/attribution remains intact
- [ ] Safety impact is documented
- [ ] Physical USB testing is described when relevant
