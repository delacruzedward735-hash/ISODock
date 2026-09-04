# IsoDock Security Notes

- Disk writes require administrator authorization through Ventoy's native
  PolicyKit/pkexec privilege flow.
- The package does not install a setuid helper.
- The engine runtime is package-owned under `/usr/lib/isodock`.
- User preferences and logs are stored outside the package runtime under the
  XDG config/cache directories.
- `isodock --doctor` validates required commands, image sizes, XZ integrity,
  GUI dependencies, branding markers, and a SHA-256 manifest of the shipped
  runtime.
- The mount handling patch unmounts selected USB partitions by block-device
  source rather than escaped `/proc/mounts` paths, fixing labels containing
  spaces and reducing the risk of writing to a still-mounted target.

## Trust boundary
IsoDock performs intentionally destructive block-device operations. Never run
an untrusted build as administrator. Verify release checksums before install.
