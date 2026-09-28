# Hardening Framework

This directory contains reusable hardening logic shared by image families.

Rules will be separated into:

- common/
- debian/
- ubuntu/
- alpine/

Hardening must be explicit, testable, and documented.

Do not copy/paste security logic into every runtime image. Common controls belong here; runtime-specific exceptions must be documented beside the affected image.
