## Summary

<!-- Describe what this pull request changes and why. -->

## Affected Areas

- [ ] Dockerfile / image
- [ ] Hardening
- [ ] Security control
- [ ] Tests
- [ ] CI/CD
- [ ] Release
- [ ] Lifecycle automation
- [ ] Documentation
- [ ] Other

## Image Families

- [ ] Debian
- [ ] Python
- [ ] Node.js
- [ ] Java
- [ ] Nginx
- [ ] Not applicable

## Security Impact

<!-- Describe any security impact. Include affected CTRL-xxx controls when applicable. -->

## Testing

<!-- List the tests and validation performed. -->

- [ ] Container tests
- [ ] CIS/security tests
- [ ] Runtime security tests
- [ ] Integration tests
- [ ] Vulnerability scanning
- [ ] Dockerfile linting
- [ ] Static analysis
- [ ] SBOM/provenance verification
- [ ] Signature verification
- [ ] Not applicable

## Security Controls

<!-- List affected controls, for example CTRL-010, CTRL-020. -->

## Documentation

- [ ] Documentation updated where required
- [ ] Security control matrix updated where required
- [ ] Control map updated where required
- [ ] No documentation changes required

## Security Checklist

- [ ] No secrets or credentials are included.
- [ ] No unnecessary runtime packages were introduced.
- [ ] No unnecessary network/debug tools were introduced.
- [ ] Images remain non-root.
- [ ] Existing security controls are preserved.
- [ ] Existing security tests have not been weakened or disabled.
- [ ] Explicit image/base release versions are used.
- [ ] Security exceptions are documented where applicable.
- [ ] This change does not modify the frozen `security-baseline-v1` tag.

## Additional Notes

<!-- Add relevant implementation details, risks, limitations, or follow-up work. -->