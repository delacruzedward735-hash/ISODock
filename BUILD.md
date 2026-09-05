# Building IsoDock

IsoDock supports a lightweight package build from the committed runtime template and a full source-composition flow using the pinned Ventoy upstream source.

## Dependencies

Debian/Ubuntu/Zorin example:

```bash
sudo apt update
sudo apt install -y \
  git gcc make xz-utils rsync dpkg-dev \
  libgtk-3-0 util-linux fdisk parted dosfstools udev policykit-1
```

Optional GUI smoke testing requires `xvfb`.

## Verify committed source/runtime

```bash
make verify
```

## Build `.deb`

```bash
make deb
```

Output:

```text
out/isodock_1.0.0-6_amd64.deb
```

## Fetch exact upstream source

```bash
make prepare-upstream
```

This checks out the commit pinned in `VERSION` under `.cache/upstream/Ventoy` and applies the IsoDock source changes.

## Rebuild boot image

```bash
make boot-image
make verify
```

## Build complete corresponding-source archive

```bash
make source-archive
```

## Build release artifacts

```bash
make release
```
