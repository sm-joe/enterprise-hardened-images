# Contributing

Thank you for contributing to Enterprise Hardened Images.

This project builds security-focused container images with a defined security
baseline, automated testing, supply-chain controls, and lifecycle management.

Contributions should preserve the project's security guarantees and should not
weaken an existing control without documented justification.

## Before Contributing

Please:

1. Read `README.md`.
2. Read `SECURITY.md`.
3. Review `docs/SECURITY-CONTROL-MATRIX.csv`.
4. Review `hardening/common/control-map.yaml`.
5. Check the current image families and supported versions.
6. Search existing issues and pull requests before opening a new one.

The current frozen baseline is:

`security-baseline-v1`

It covers:

- Debian 13
- Python 3.13
- Node.js 22
- Java 21
- Nginx 1.28

## Types of Contributions

Contributions may include:

- Security hardening improvements.
- New image families.
- Package or runtime updates.
- Vulnerability remediation.
- CI/CD improvements.
- Supply-chain security improvements.
- Runtime security tests.
- Integration tests.
- Documentation.
- Lifecycle automation.
- Security policy improvements.
- Bug fixes.

## Adding or Updating an Image

New image families should follow the established project security model.

An image should:

- Use an explicitly versioned base image.
- Run as a non-root user.
- Use a dedicated non-root group.
- Avoid unnecessary packages.
- Avoid unnecessary network and debugging tools.
- Remove package-manager metadata and caches.
- Avoid credentials and secrets in image configuration.
- Minimize setuid/setgid exposure.
- Support reduced Linux capabilities where applicable.
- Support read-only root filesystems where practical.
- Include an appropriate health check or smoke test.
- Pass the applicable security and runtime tests.
- Support the project's multi-architecture release requirements.
- Produce an SBOM.
- Produce build provenance.
- Be cryptographically signed when released.
- Meet the project's vulnerability policy.

## Security Controls

The project maintains a 28-control security baseline.

Changes affecting security controls must preserve the corresponding
acceptance criteria.

If a contribution changes how a control is implemented, update the relevant
documentation and tests together.

Do not mark a control complete merely because an implementation has been
added. The control must have corresponding validated enforcement or evidence.

## Dockerfile Requirements

Dockerfiles should:

- Use explicit image release tags.
- Avoid `latest`.
- Avoid unnecessary packages.
- Avoid unnecessary build dependencies in the final image.
- Run applications as non-root.
- Minimize image layers where practical.
- Clean package-manager metadata and caches.
- Avoid embedding credentials.
- Avoid unnecessary shell utilities in runtime images.
- Include appropriate metadata.
- Pass Dockerfile linting.

Do not introduce static credentials, access tokens, private keys, or other
secrets into Dockerfiles, build arguments, image labels, environment defaults,
or image layers.

## Testing Requirements

Changes should include or update the appropriate tests.

Depending on the change, this may include:

- Container tests.
- CIS/security tests.
- Runtime security tests.
- Integration tests.
- Vulnerability scanning.
- Dockerfile linting.
- Infrastructure/security static analysis.
- Image smoke tests.
- Supply-chain verification.

Existing tests should not be disabled or weakened merely to make a change
pass CI.

If a security test needs to change, explain why in the pull request.

## CI Requirements

Pull requests are expected to pass the applicable CI checks before merge.

Do not bypass security gates without a documented reason.

Changes to:

- Dockerfiles,
- hardening logic,
- security tests,
- release workflows,
- lifecycle automation,
- security policies,

should receive particular attention during review.

## Dependencies

Dependency updates should use supported upstream releases.

Security-sensitive dependency changes should include sufficient testing to
demonstrate that existing functionality and security controls remain intact.

Do not introduce unnecessary runtime dependencies.

## Security Vulnerabilities

Do not report security vulnerabilities through public issues or pull
requests.

Follow the reporting process documented in `SECURITY.md`.

Do not include secrets, credentials, private keys, or unnecessary sensitive
information in issues or pull requests.

## Pull Requests

A pull request should:

- Clearly describe the change.
- Explain why the change is needed.
- Identify affected image families.
- Identify affected security controls when applicable.
- Describe testing performed.
- Identify any security implications.
- Document intentional exceptions.
- Keep unrelated changes out of scope.

For security-sensitive changes, include the relevant test evidence in the
pull request description.

## Pull Request Checklist

Before requesting review, confirm:

- [ ] The change has a clear purpose.
- [ ] Existing security controls are preserved.
- [ ] Relevant tests have been added or updated.
- [ ] CI passes.
- [ ] No secrets are included.
- [ ] Dockerfiles use explicit release versions.
- [ ] Runtime images remain non-root.
- [ ] Unnecessary packages and tools have not been introduced.
- [ ] Documentation has been updated where required.
- [ ] Security exceptions are documented where applicable.
- [ ] The change does not modify the frozen `security-baseline-v1` tag.

## Commit Messages

Use concise commit messages that describe the change.

Examples:

```text
feat: add hardened Go runtime
fix: remediate nginx package vulnerability
test: enforce runtime capability restrictions
ci: improve image release verification
docs: update security baseline