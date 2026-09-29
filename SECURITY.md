# Security Policy

## Supported Versions

Security fixes are applied to the currently supported image families and the
current maintained release line.

The current Security Baseline v1 covers:

| Image | Version |
|---|---|
| Debian | 13 |
| Python | 3.13 |
| Node.js | 22 |
| Java | 21 |
| Nginx | 1.28 |

Security Baseline v1 is identified by the Git tag:

`security-baseline-v1`

Older image versions may not receive security updates after their supported
lifecycle ends.

## Reporting a Vulnerability

Please do not report security vulnerabilities through public GitHub Issues,
pull requests, discussions, or other public channels.

If GitHub private vulnerability reporting is enabled for this repository,
please use the repository's **Security** tab to submit a private vulnerability
report.

When reporting a vulnerability, provide as much of the following information
as possible:

- A clear description of the vulnerability.
- Affected image and version.
- Affected component or package.
- Vulnerability identifier, if known, such as a CVE.
- Steps required to reproduce the issue.
- Relevant Dockerfile, configuration, or test information.
- Expected behavior.
- Actual behavior.
- Potential security impact.
- Any available mitigation or remediation information.

Please avoid including secrets, credentials, private keys, personal data, or
other sensitive information that is not necessary to reproduce the issue.

## Disclosure

Please allow reasonable time for the issue to be investigated and, where
appropriate, remediated before publicly disclosing vulnerability details.

Security fixes may result in:

- A new image build.
- A new image tag.
- Updated package versions.
- Updated security tests.
- Updated lifecycle automation.
- A security advisory.

The project may coordinate disclosure timing with affected users or
upstream projects when appropriate.

## Security Scope

The project focuses on the security of the container images, their build
process, supply-chain controls, runtime security characteristics, and
associated automation.

The security baseline includes controls covering:

- Non-root execution.
- Privilege reduction.
- Linux capability reduction.
- Filesystem security.
- Minimal package footprint.
- Credential and secret protection.
- Base image release control.
- SBOM generation.
- Build provenance.
- Cryptographic image signing.
- Multi-architecture builds.
- Vulnerability scanning.
- Dockerfile and infrastructure security analysis.
- Runtime security testing.
- Upstream update detection.
- CVE-triggered rebuilds.
- Security exception governance.

The project is aligned with the documented security control matrix and
control map.

## Security Baseline

The current baseline is **Security Baseline v1**.

Security Baseline v1 covers five image families:

- Debian 13
- Python 3.13
- Node.js 22
- Java 21
- Nginx 1.28

The baseline contains 28 documented security controls.

The baseline is intentionally frozen. Future improvements or additional image
families should be introduced through subsequent changes and should not
silently modify the historical `security-baseline-v1` state.

## Vulnerability Handling

Vulnerabilities are evaluated according to the project's vulnerability
controls and CI policies.

In particular:

- Unresolved critical vulnerabilities are blocked.
- High-severity vulnerabilities are governed by the project's security
  policy and documented exceptions.
- Vulnerabilities with available fixes may trigger lifecycle rebuilds.
- Unfixed vulnerabilities are not treated as automatically remediated.
- Security exceptions must be documented according to the project's
  exception governance process.

## Supply Chain Security

Released images are expected to provide the security artifacts and controls
defined by the project's security baseline, including:

- SBOM.
- Build provenance.
- Cryptographic image signatures.
- Multi-architecture manifests.
- Vulnerability scanning.

Consumers should verify image signatures and use the published image
metadata when establishing their own software supply-chain trust policy.

## Security Exceptions

Security exceptions must be documented with:

- The affected control.
- Reason for the exception.
- Owner.
- Scope.
- Compensating controls, where applicable.
- Expiration or review date.

Exceptions should not be used to permanently bypass security controls
without documented justification and review.

## Responsible Disclosure

Please act in good faith when researching or reporting security issues.

Do not:

- Access or modify data that does not belong to you.
- Disrupt project infrastructure or services.
- Perform destructive testing.
- Publish credentials or secrets.
- Publicly disclose an exploitable vulnerability before reasonable
  remediation coordination.

Thank you for helping improve the security of the project.