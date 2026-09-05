# Security Policy

IsoDock writes boot structures and partitions to block devices, so security and target-device safety are release-critical.

## Supported version

Security fixes are currently targeted at the latest IsoDock 1.0.x release line.

## Reporting a vulnerability

Please do **not** publish an exploit, destructive proof-of-concept, private device data, credentials, or security-sensitive logs in a public issue.

Use the private contact route at:

https://codedev-by-edward.myportfoliohub.online/contact

Include:

- affected IsoDock version;
- Linux distribution and architecture;
- impact and prerequisites;
- minimal reproduction steps;
- whether the behavior also exists in upstream Ventoy;
- a proposed fix, if available.

## Destructive-device bugs

If a bug could write to the wrong disk, bypass a target check, or corrupt data, treat it as security-sensitive until reviewed. Reproduce only on disposable test media or virtual block devices.
