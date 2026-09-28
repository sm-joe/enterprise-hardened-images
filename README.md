# Enterprise Hardened Container Images

Enterprise-grade hardened container image platform.

## Goals

- CIS-aligned container hardening
- Minimal and reproducible images
- Non-root execution
- Least privilege
- SBOM and provenance
- Vulnerability and secret scanning
- Cryptographic image signing
- Multi-architecture builds
- Automated upstream rebuilds
- Kubernetes admission enforcement

## Status

Phase 1 / Foundation.

No runtime image is included yet. The first implementation target is the hardened Debian foundation image.

## Planned image families

- Debian hardened base
- Python
- Node.js
- Java
- Nginx
- Go
- .NET
- PHP
- Ruby
- Angular build/runtime
- Apache HTTPD

## Security terminology

This project uses "CIS-aligned" or "CIS L1-aligned" language unless a particular artifact has been independently assessed/certified. It does not claim CIS certification.

## Repository structure

```text
.github/workflows/     CI workflows
docs/                  architecture and security documentation
hardening/             reusable hardening logic
images/                container image definitions
metadata/              image contracts and catalog metadata
policies/              security/admission policies
scripts/               local/CI helper scripts
tests/                 security and runtime tests
```

## First milestone

The first milestone establishes the platform contracts and CI foundation. Runtime images are added only after the foundation is validated.
