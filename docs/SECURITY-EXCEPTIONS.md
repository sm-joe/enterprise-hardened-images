# Security Exceptions

This document defines how security-control exceptions are handled for
the enterprise hardened container image platform.

## Purpose

Security controls are mandatory by default.

An exception may be created only when a control cannot technically be
satisfied for a documented reason.

An exception is not a permanent bypass.

## When an Exception Is Allowed

An exception may be considered when:

- A runtime requires a control that conflicts with the baseline.
- An upstream dependency prevents compliance.
- A documented technical limitation exists.
- A temporary migration requires additional time.

Exceptions must not be used simply to make a failing CI pipeline pass.

## Required Information

Every exception must document:

- Control ID
- Affected image
- Reason
- Compensating control
- Owner
- Approver
- Creation date
- Expiry or review date

## Example

```yaml
exception:
  control_id: CTRL-007
  image: example-runtime
  reason: "The application requires a writable runtime cache."
  compensating_control: "The cache is mounted as an ephemeral writable volume."
  owner: platform-security
  approved_by: security-review
  created: "2026-09-28"
  expires: "2026-12-28"
```

## Rules

1. Exceptions must reference an existing security control.
2. Exceptions must have an identified owner.
3. Exceptions must have an approval.
4. Exceptions must have an expiry or review date.
5. Compensating controls must be documented.
6. Expired exceptions must not remain active.
7. Permanent exceptions require explicit security review.
8. Exceptions must not weaken unrelated security controls.

## CI Behavior

Required controls fail CI unless:

- A valid exception exists.
- The exception has not expired.
- The exception contains all required information.

The exception mechanism must never silently convert a security failure
into a successful build.

## Review

Exceptions should be reviewed before their expiry date.

When the underlying technical limitation is resolved, the exception
must be removed and the affected security control restored.
