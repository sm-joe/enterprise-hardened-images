# Architecture

```text
Hardened OS foundation
        |
        +--> Python
        +--> Node.js
        +--> Java
        +--> Nginx
        +--> Go
        +--> .NET
        +--> PHP
        +--> Ruby
        |
        v
BuildKit
        |
        +--> vulnerability scan
        +--> security tests
        +--> SBOM
        +--> provenance
        |
        v
Cosign/Sigstore
        |
        v
Enterprise registry
        |
        v
Kubernetes/ECS
        |
        v
Admission/runtime policy
```

The base layer is intentionally separated from runtime layers so that common hardening is centralized and independently testable.
