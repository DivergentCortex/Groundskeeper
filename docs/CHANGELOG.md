# Changelog

## [2026.11.23.1] - 2026-11-23

- Initial standalone release, extracted from the Dowser module.
- Prunes stale plugin cache versions by rule, keeps anything a running process or agent seat depends on, and reports low free disk space.
- Preview by default. Deleting needs -Remove and honors -WhatIf and -Confirm.
