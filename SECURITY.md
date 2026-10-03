# Security Policy

Ubuntu workspace hardening profiles, configuration and idempotent installer scripts (Ubuntu, Pop!_OS, TUXEDO OS).
These scripts run with root privileges on the machines they configure.

## Supported versions

Only the current `main` branch is supported.
Fixes land on `main`; there are no release branches.

## Reporting a vulnerability

Please report privately.
Do not open a public issue or pull request.

- **Preferred:** [report a vulnerability](https://github.com/JOduMonT/ubuntu/security/advisories/new) through GitHub private vulnerability reporting.
- **Email:** jodumont+security@gmail.com
- Include what you found, the affected file or service, steps to reproduce and the impact you see.
- Do not access, change or delete data that is not yours, and do not run denial-of-service or automated scanning against live systems.

You can expect an acknowledgement within 3 business days and a status update within 10.
Confirmed issues are fixed as quickly as severity allows, and you are credited in the fix unless you prefer not to be.

## Scope

In scope:

- Command injection, unsafe temp files or globbing, and unquoted variables in any script.
- Downloads fetched without checksum or signature verification, or over plain HTTP.
- Hardening settings that are weaker than they claim, or that open a service by default.

Out of scope:

- Vulnerabilities in Ubuntu packages and in third-party apt repositories or installers the scripts add.
- Social engineering and physical attacks.

## How this repository is kept safe

- Dependabot alerts and security updates are on, and `.github/dependabot.yml` opens weekly grouped version updates.
- Dependabot pull requests are merged automatically by `.github/workflows/dependabot-auto-merge.yml` once every other check passes.
  Major version bumps are left open for review.
- GitHub secret scanning with push protection and CodeQL code scanning are enabled.
- Scripts are linted in CI.
- Run a script only from a tagged or reviewed commit, never straight from an unreviewed branch.
