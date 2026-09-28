Common Container Hardening
This directory contains security requirements and reusable hardening
logic that applies to multiple container image families.
Common hardening includes:
Non-root execution
Least privilege
Minimal packages
Secure filesystem permissions
No secrets in images
Reduced Linux capabilities
Runtime security requirements
Common hardening should be reusable across different base operating
systems and application runtimes.
Operating-system-specific hardening belongs in the corresponding
directory, for example:
`hardening/debian/`
`hardening/ubuntu/`
`hardening/alpine/`
Application-specific configuration belongs with the individual image.
Example:
```text
hardening/common/
    Common container security

hardening/debian/
    Debian-specific hardening

images/python/
    Python-specific configuration
```