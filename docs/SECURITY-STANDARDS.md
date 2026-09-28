# Security Standards

## Container baseline

Every production image should target:

- non-root execution
- no unnecessary privilege escalation
- no embedded credentials/secrets
- minimal packages
- minimal capabilities
- minimal writable filesystem
- deterministic versioning
- vulnerability scanning
- SBOM
- provenance
- cryptographic signing

## CIS alignment

The project maps applicable image/environment controls to CIS benchmarks. CIS Docker Benchmark controls are not automatically equivalent to controls inside a Dockerfile; applicability must be documented.

The current CIS Docker Benchmark release should be verified before each standards refresh.

## Supply chain

BuildKit will provide SBOM and provenance attestations. Production images will be signed with Cosign/Sigstore.

## CI permissions

GitHub Actions workflows should default to least privilege. OIDC permissions are granted only to jobs that actually require external identity federation or signing.
