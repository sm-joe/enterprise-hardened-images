# Debian Hardening

This directory contains Debian-specific hardening logic for the
enterprise hardened container image platform.

Debian-specific hardening belongs here instead of
`hardening/common/`.

Examples include:

- Debian package management
- APT configuration
- APT cache cleanup
- Debian-specific filesystem permissions
- Debian-specific user and group configuration
- Debian-specific package removal

## Boundary

Common security requirements belong in:

```text
hardening/common/
```

Debian-specific implementation belongs here:

```text
hardening/debian/
```

Application-specific configuration belongs with the image itself:

```text
images/
```

## Target Runtime Identity

The initial Debian hardened base will use:

```text
UID: 10001
GID: 10001
```

The image should run as this non-root identity by default.

## Package Principle

The final image should contain only packages required for its intended
runtime purpose.

Build-time dependencies should not remain in the final production
image when they can be removed through multi-stage builds or other
appropriate techniques.

## APT Cleanup

APT package indexes and temporary package data should not remain in
the final production image unless explicitly required.

Installation and cleanup should be performed in a controlled manner
to avoid leaving unnecessary data in image layers.

## Testing

Debian hardening will be validated through automated tests.

Tests will verify controls such as:

- Non-root user
- Required UID/GID
- Package footprint
- Unnecessary package removal
- APT cache cleanup
- Filesystem permissions
- Setuid/setgid handling
- Runtime compatibility

The actual Dockerfile implementation will be added in a later step.
