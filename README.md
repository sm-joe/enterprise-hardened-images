# Enterprise Hardened Images

{=html}
<p align="center">

`<strong>`{=html}CIS L1-aligned enterprise container images for secure,
portable application runtimes.`</strong>`{=html}`<br>`{=html} Hardened
Docker images with non-root execution, reduced privileges, security
testing, SBOM, provenance, signing, multi-architecture releases, and
lifecycle automation.
{=html}
</p>

{=html}
<p align="center">

`<img src="https://img.shields.io/badge/Debian-13-A81D33?style=for-the-badge&logo=debian&logoColor=white" alt="Debian 13">`{=html}
`<img src="https://img.shields.io/badge/Python-3.13-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python 3.13">`{=html}
`<img src="https://img.shields.io/badge/Node.js-22-339933?style=for-the-badge&logo=node.js&logoColor=white" alt="Node.js 22">`{=html}
`<img src="https://img.shields.io/badge/Java-21-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java 21">`{=html}
`<img src="https://img.shields.io/badge/Nginx-1.28-009639?style=for-the-badge&logo=nginx&logoColor=white" alt="Nginx 1.28">`{=html}
{=html}
</p>

{=html}
<p align="center">

`<img src="https://img.shields.io/badge/CIS-L1--aligned-2ea44f?style=flat-square" alt="CIS L1 aligned">`{=html}
`<img src="https://img.shields.io/badge/SBOM-generated-6f42c1?style=flat-square" alt="SBOM">`{=html}
`<img src="https://img.shields.io/badge/Provenance-generated-2088FF?style=flat-square" alt="Provenance">`{=html}
`<img src="https://img.shields.io/badge/Cosign-signed-1904DA?style=flat-square" alt="Cosign">`{=html}
`<img src="https://img.shields.io/badge/28%2F28-controls-success?style=flat-square" alt="28 controls">`{=html}
{=html}
</p>


------------------------------------------------------------------------

# What is Enterprise Hardened Images?

**Enterprise Hardened Images** is a Docker-first collection of
security-hardened base and runtime images for application teams that
need a reusable, predictable container security baseline.

It combines:

-   **Debian 13** hardened base
-   **Python 3.13** runtime
-   **Node.js 22** runtime
-   **Java 21 JRE** runtime
-   **Nginx 1.28** runtime
-   Non-root execution with UID/GID `10001`
-   Minimal package footprints
-   Reduced Linux privileges
-   Secret and credential checks
-   Dockerfile linting and static security analysis
-   Runtime and security regression tests
-   SBOM and build provenance
-   Cosign signing and verification
-   `amd64` and `arm64` releases
-   Upstream update detection
-   CVE-triggered rebuild automation
-   Security exception governance

The goal is practical: application teams consume a common hardened
foundation instead of independently rebuilding the same security
controls.

------------------------------------------------------------------------

# Why Enterprise Hardened Images?

A container can be small and still be insecure. This project focuses on
controls that should remain true regardless of the application layered
on top.

  Area              Project approach
  ----------------- ----------------------------------------
  Base OS           Debian 13
  Identity          Non-root UID/GID `10001`
  Privilege         No sudo; unnecessary SUID/SGID removed
  Capabilities      Runtime tested with `cap-drop=ALL`
  Escalation        `no-new-privileges`
  Filesystem        Read-only root filesystem compatible
  Packages          Minimal documented runtime footprint
  Credentials       No credential environment defaults
  Secrets           Secret scanning
  Base releases     Explicit release tags
  Vulnerabilities   Critical blocked; High governed
  SBOM              Release attestation
  Provenance        Release attestation
  Signing           Cosign
  Architectures     `amd64` and `arm64`
  Lifecycle         Upstream + CVE rebuild automation
  Governance        Security exception manifest

------------------------------------------------------------------------

# Supported Images

The current frozen baseline contains five image families.

  Family      Release Image
  --------- --------- --------------------------------------------------
  Debian         `13` `ghcr.io/sm-joe/enterprise-hardened-debian:13`
  Python       `3.13` `ghcr.io/sm-joe/enterprise-hardened-python:3.13`
  Node.js        `22` `ghcr.io/sm-joe/enterprise-hardened-node:22`
  Java           `21` `ghcr.io/sm-joe/enterprise-hardened-java:21`
  Nginx        `1.28` `ghcr.io/sm-joe/enterprise-hardened-nginx:1.28`

The project is intentionally frozen at these five families for the
current baseline. New families should be added only when there is a
concrete requirement.

------------------------------------------------------------------------

# Architecture

 text
                         Application
                              |
                              v
                  +-------------------------+
                  | Hardened Runtime Image  |
                  | Python / Node / Java /  |
                  | Nginx                   |
                  +------------+------------+
                               |
                               v
                  +-------------------------+
                  | Hardened Debian 13 Base |
                  | Non-root / Minimal /     |
                  | Security Baseline       |
                  +------------+------------+
                               |
             +-----------------+-----------------+
             |                 |                 |
             v                 v                 v
       Security Tests    Supply Chain       Lifecycle
       CIS/runtime       SBOM/provenance     CVE/upstream
       regression        signing             rebuilds


## Image relationship

 text
debian:13
    |
    v
enterprise-hardened-debian:13
    +--> enterprise-hardened-python:3.13
    +--> enterprise-hardened-node:22
    +--> enterprise-hardened-java:21
    +--> enterprise-hardened-nginx:1.28


------------------------------------------------------------------------

# Security Control Model

The baseline contains **28 controls**, all currently complete.

  ID         Domain          Control
  ---------- --------------- ---------------------------------------------
  CTRL-001   Identity        Run as non-root
  CTRL-002   Identity        Dedicated non-root group
  CTRL-003   Privilege       No sudo
  CTRL-004   Privilege       No unnecessary setuid/setgid binaries
  CTRL-005   Privilege       Privilege escalation disabled
  CTRL-006   Capabilities    Drop unnecessary Linux capabilities
  CTRL-007   Filesystem      Read-only root filesystem compatible
  CTRL-008   Filesystem      Sensitive filesystem permissions restricted
  CTRL-009   Filesystem      Temporary/cache data minimized
  CTRL-010   Packages        Minimal package footprint
  CTRL-011   Packages        No unnecessary network/debug tools
  CTRL-012   Packages        Package manager metadata cleaned
  CTRL-013   Secrets         No secrets in image layers
  CTRL-014   Secrets         No credentials in environment defaults
  CTRL-015   Supply Chain    Pinned base image release
  CTRL-016   Supply Chain    SBOM generated
  CTRL-017   Supply Chain    Build provenance generated
  CTRL-018   Supply Chain    Image cryptographically signed
  CTRL-019   Supply Chain    Multi-architecture build
  CTRL-020   Vulnerability   Critical vulnerabilities blocked
  CTRL-021   Vulnerability   High vulnerabilities governed
  CTRL-022   Build           Dockerfile linting
  CTRL-023   Build           Infrastructure/security static analysis
  CTRL-024   Testing         Image smoke test
  CTRL-025   Testing         Security regression test
  CTRL-026   Lifecycle       Upstream update detection
  CTRL-027   Lifecycle       CVE-triggered rebuild
  CTRL-028   Governance      Security exceptions documented

The authoritative matrix is `docs/SECURITY-CONTROL-MATRIX.csv`.

------------------------------------------------------------------------

# Highlights

## Non-root by default

Runtime images execute as:

 text
UID 10001
GID 10001


Applications are not expected to run as root.

## Minimal package footprint

The image test suite rejects unnecessary network, debugging, and
administrative tools unless explicitly justified, including:

 text
curl  wget  openssh  git  vim  nano
gcc   make  netcat  telnet  ftp


Runtime-specific packages remain documented and tested.

## Credential-free defaults

Image configuration is checked for credential-related environment
variables such as:

 text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
GOOGLE_APPLICATION_CREDENTIALS
AZURE_CLIENT_SECRET
GITHUB_TOKEN
GH_TOKEN
NPM_TOKEN
NODE_AUTH_TOKEN
DOCKER_AUTH_CONFIG


## Runtime hardening

The images are designed to work with:

 text
--read-only
--cap-drop=ALL
--security-opt=no-new-privileges:true
--tmpfs /tmp:rw,nosuid,nodev,noexec


Runtime regression tests verify identity, protected filesystem paths,
writable temporary storage, effective capabilities, `NoNewPrivs`, and
SUID/SGID state.

------------------------------------------------------------------------

# Build and Release Flow

 text
Source Change
     |
     v
Validation
     |
     +--> Dockerfile lint
     +--> Static security analysis
     +--> Secret scanning
     +--> Metadata validation
     |
     v
Build
     |
     +--> amd64
     +--> arm64
     |
     v
Container Tests
     |
     +--> Smoke tests
     +--> Package footprint
     +--> Image policy
     +--> Runtime security
     |
     v
Vulnerability Scan
     |
     v
Release
     |
     +--> SBOM
     +--> Provenance
     +--> Cosign signature
     |
     v
Published Multi-Arch Image


------------------------------------------------------------------------

# Lifecycle Automation

The lifecycle pipeline checks published images for both upstream changes
and qualifying vulnerabilities.

## Upstream updates

`scripts/check-upstream-updates.sh` checks the current published
versions against upstream releases for:

-   Debian
-   Python
-   Node.js
-   Java
-   Nginx

When a supported upstream update is detected, the lifecycle pipeline can
dispatch the appropriate release workflow.

## CVE-triggered rebuilds

 text
HIGH / CRITICAL vulnerability
          |
          +--> fixed version available
          |          |
          |          v
          |     rebuild image
          |
          +--> no fixed version
                     |
                     v
               remain governed


This avoids meaningless rebuild loops for vulnerabilities without an
available fix while allowing fixed vulnerabilities to trigger a new
release.

------------------------------------------------------------------------

# Supply Chain Security

Every production release is designed to provide:

 text
Image
  +-- Multi-architecture manifest
  +-- SBOM attestation
  +-- Build provenance
  +-- Cosign signature


Supported architectures:

 text
linux/amd64
linux/arm64


------------------------------------------------------------------------

# Base Image Policy

Base image references use explicit release tags.

Allowed:

 dockerfile
FROM debian:13
FROM ghcr.io/sm-joe/enterprise-hardened-debian:13


Not allowed:

 dockerfile
FROM debian:latest
FROM debian
FROM debian@sha256:...


The project uses explicit release tags to keep upstream lifecycle
tracking clear.

Validation is implemented in:

 text
tests/cis/test-base-image-release.sh


------------------------------------------------------------------------

# Runtime Security

Example hardened Docker invocation:

 powershell
docker run --rm `
  --read-only `
  --cap-drop=ALL `
  --security-opt=no-new-privileges:true `
  --tmpfs /tmp:rw,nosuid,nodev,noexec `
  ghcr.io/sm-joe/enterprise-hardened-python:3.13 `
  python --version


The runtime security regression suite verifies:

-   Non-root UID/GID
-   Protected `/etc` and `/usr`
-   Approved writable temporary storage
-   Zero effective Linux capabilities
-   `NoNewPrivs=1`
-   No unnecessary SUID/SGID binaries

------------------------------------------------------------------------

# Image Families

## Debian 13

Common hardened foundation with a dedicated non-root user/group,
SUID/SGID cleanup, minimal filesystem setup, cleaned package metadata,
`/app`, and runtime healthcheck.

 powershell
docker pull ghcr.io/sm-joe/enterprise-hardened-debian:13


## Python 3.13

Python application runtime based on the hardened Debian 13 foundation.

 powershell
docker pull ghcr.io/sm-joe/enterprise-hardened-python:3.13


## Node.js 22

Node.js 22 runtime using the official Node.js distribution on the
hardened Debian foundation.

 powershell
docker pull ghcr.io/sm-joe/enterprise-hardened-node:22


## Java 21

JRE-oriented Java runtime. The baseline uses `openjdk-21-jre-headless`
and does not include the JDK/compiler toolchain.

 powershell
docker pull ghcr.io/sm-joe/enterprise-hardened-java:21


## Nginx 1.28

Nginx runtime using the official Nginx Debian repository with
signing-key verification. It runs as non-root, listens on `8080`, and
uses approved temporary paths.

 powershell
docker pull ghcr.io/sm-joe/enterprise-hardened-nginx:1.28


------------------------------------------------------------------------

# Quick Start

## Prerequisites

Install:

-   Git
-   Docker Desktop
-   Docker Buildx

## Pull an image

 powershell
docker pull ghcr.io/sm-joe/enterprise-hardened-python:3.13


## Inspect an image

 powershell
docker image inspect ghcr.io/sm-joe/enterprise-hardened-python:3.13


## Run as non-root

 powershell
docker run --rm `
  ghcr.io/sm-joe/enterprise-hardened-python:3.13 `
  python --version


## Run with runtime hardening

 powershell
docker run --rm `
  --read-only `
  --cap-drop=ALL `
  --security-opt=no-new-privileges:true `
  --tmpfs /tmp:rw,nosuid,nodev,noexec `
  ghcr.io/sm-joe/enterprise-hardened-python:3.13 `
  python --version


------------------------------------------------------------------------

# Repository Layout

 text
enterprise-hardened-images/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── lifecycle/
│   │   └── images.yaml
│   └── workflows/
├── docs/
│   ├── ARCHITECTURE.md
│   ├── SECURITY-CONTROL-MATRIX.csv
│   ├── SECURITY-EXCEPTIONS.md
│   └── SECURITY-STANDARDS.md
├── hardening/
│   ├── common/
│   └── debian/
├── images/
│   ├── base/
│   │   └── debian/
│   └── runtime/
│       ├── python/
│       ├── node/
│       ├── java/
│       └── nginx/
├── metadata/
├── policies/
│   └── security-exceptions.yaml
├── scripts/
├── tests/
│   ├── cis/
│   ├── container/
│   ├── integration/
│   └── runtime/
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── SECURITY.md


------------------------------------------------------------------------

# Testing

Container tests cover each supported family:

 powershell
bash tests/container/test-debian-base.sh
bash tests/container/test-python-base.sh
bash tests/container/test-node-base.sh
bash tests/container/test-java-base.sh
bash tests/container/test-nginx-base.sh


Image policy:

 powershell
bash tests/container/test-image-policy.sh


Base-image release validation:

 powershell
bash tests/cis/test-base-image-release.sh


Runtime integration/security validation:

 powershell
bash tests/integration/test-runtime-security.sh


GitHub Actions remains the authoritative repository-wide validation
path.

------------------------------------------------------------------------

# CI / DevSecOps

The repository uses GitHub Actions for source validation, image testing,
releases, and lifecycle operations.

 text
Change / Release
       |
       v
Source Validation
       |
       +--> Lint
       +--> Static security analysis
       +--> Secret scanning
       +--> Metadata checks
       |
       v
Build + Test
       |
       +--> Container tests
       +--> Runtime security
       +--> Vulnerability policy
       |
       v
Release
       |
       +--> Multi-arch
       +--> SBOM
       +--> Provenance
       +--> Cosign
       |
       v
GHCR
       |
       v
Lifecycle Monitoring


------------------------------------------------------------------------

# Security

Security is a release requirement rather than a final checklist.

Current controls include:

-   Non-root images
-   Dedicated non-root group
-   No sudo
-   SUID/SGID reduction
-   `no-new-privileges`
-   Linux capability dropping
-   Read-only filesystem compatibility
-   Restricted sensitive filesystem permissions
-   Minimal package footprints
-   No unnecessary network/debug tools
-   Clean package metadata
-   Secret scanning
-   Credential-free image defaults
-   Explicit base-image release tags
-   SBOM
-   Provenance
-   Cosign signing
-   Multi-architecture builds
-   Critical vulnerability blocking
-   High vulnerability governance
-   Dockerfile linting
-   Static security analysis
-   Image smoke testing
-   Security regression testing
-   Upstream update detection
-   CVE-triggered rebuilds
-   Security exception governance

See [`SECURITY.md`](SECURITY.md) for the public security policy.

------------------------------------------------------------------------

# Security Exceptions

Exceptions are governed rather than silently ignored.

 text
policies/security-exceptions.yaml
docs/SECURITY-EXCEPTIONS.md


A security exception should identify the affected control/image, owner,
reason, risk, compensating control, and review or expiry information.

------------------------------------------------------------------------

# Recommended Consumer Runtime

Consuming workloads should preserve the image security model.

Recommended Kubernetes baseline:

 yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 10001
  runAsGroup: 10001
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL


The application workload remains responsible for application-specific
writable paths, ports, capabilities, secrets, and network policy.

------------------------------------------------------------------------

# Configuration and Customization

Example application image:

 dockerfile
FROM ghcr.io/sm-joe/enterprise-hardened-python:3.13

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

USER 10001:10001

CMD ["python", "app.py"]


Application images should not switch back to root or add unnecessary
administrative tooling without an explicit security justification.

------------------------------------------------------------------------

# Design Principles

## 1. Secure by default

Security controls should be inherited rather than repeatedly rebuilt by
every application team.

## 2. Least privilege

Only required runtime functionality should be present.

## 3. Explicit versions

Floating base-image references make lifecycle management harder.
Supported images use explicit release tags.

## 4. Evidence over assumptions

Controls are considered complete when implementation and repeatable
evidence demonstrate the expected behavior.

## 5. Automation over manual maintenance

Upstream changes and qualifying CVEs should flow through lifecycle
automation.

## 6. Exceptions must be visible

Exceptions should be documented, owned, justified, and reviewable.

## 7. Keep the baseline understandable

The project intentionally stops at five families for the current
baseline rather than expanding without a concrete requirement.

------------------------------------------------------------------------

# Current Status

  Area                               Status
  ---------------------------------- ----------------------
  Debian 13 hardened base            Complete
  Python 3.13 runtime                Complete
  Node.js 22 runtime                 Complete
  Java 21 runtime                    Complete
  Nginx 1.28 runtime                 Complete
  Security controls                  **28 / 28 complete**
  Container tests                    Complete
  Runtime security tests             Complete
  Package footprint controls         Complete
  Credential environment checks      Complete
  Base-image release validation      Complete
  SBOM generation                    Complete
  Build provenance                   Complete
  Cosign signing                     Complete
  Multi-architecture releases        Complete
  Vulnerability policy               Complete
  Upstream update detection          Complete
  CVE-triggered rebuild automation   Complete
  Security exception governance      Complete
  Public security documentation      Complete
  Baseline release                   **v1.0.0**

------------------------------------------------------------------------

# Baseline Release

The frozen baseline is:

 text
security-baseline-v1


The public release is:

 text
v1.0.0


It contains:

 text
Debian 13
Python 3.13
Node.js 22
Java 21
Nginx 1.28


New image families should be introduced only when a concrete requirement
justifies expanding the supported surface.

------------------------------------------------------------------------

# Project Scope

## In scope

-   Hardened Docker base images
-   Hardened application runtime images
-   CIS L1-aligned controls
-   Container security testing
-   Runtime security testing
-   Vulnerability scanning
-   SBOM and provenance
-   Image signing
-   Multi-architecture releases
-   Lifecycle automation
-   Security exception governance
-   Public security documentation

## Out of scope for the current baseline

-   Unlimited runtime families
-   Replacing every upstream distribution
-   Application-specific business logic
-   Kubernetes platform management
-   Enterprise service mesh
-   Full enterprise observability platform
-   Application-level identity systems
-   Automatic expansion without a concrete requirement

The project remains a focused hardened-image platform rather than a
general-purpose platform engineering stack.

------------------------------------------------------------------------

# Contributing

Before submitting changes:

1.  Preserve the existing security baseline.
2.  Do not weaken required controls without a documented exception.
3.  Add or update tests for behavior changes.
4.  Validate affected Dockerfiles and metadata.
5.  Verify affected images before release.
6.  Never commit credentials, tokens, private keys, or local runtime
    state.
7.  Document security-sensitive changes.
8.  Keep supported version references explicit and lifecycle-manageable.

See [`CONTRIBUTING.md`](CONTRIBUTING.md).

------------------------------------------------------------------------

# License

This project is licensed under the **Apache License 2.0**.

See [`LICENSE`](LICENSE) for the full license text.

------------------------------------------------------------------------

## Enterprise Hardened Images

Built as a practical security baseline for teams that want reusable,
testable, signed, and lifecycle-managed Docker images without rebuilding
the same container hardening controls for every application.
