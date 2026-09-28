# Security Tests

Tests will be divided into:

- `cis/` — CIS-aligned control validation
- `container/` — image configuration checks
- `runtime/` — behavior/security-context checks
- `integration/` — application-level validation

A test should produce machine-readable output suitable for CI/SARIF where the tool supports it.
