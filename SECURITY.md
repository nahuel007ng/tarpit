# Security policy

## Supported versions

Fixes land on the latest minor release only.

| Version | Supported |
|---|---|
| 0.1.x | Yes |
| Older | No |

## Reporting a vulnerability

The `tarpit` command reads and analyzes Dart test files, often in CI, and
the watchdog runs inside your test process. A crafted source file that makes
the checker hang, crash in an exploitable way, read outside the given paths,
or write somewhere other than `--output` is a security problem.

Please report privately: open this repository's **Security** tab and choose
**Report a vulnerability**. This creates a private advisory that only you and
the maintainer can see.

Do **not** open a public issue, pull request or discussion for a
vulnerability.

Useful things to include:

- the package version, `flutter --version` and the host OS
- the exact command you ran
- a minimal file that reproduces it (invented code, never a real project's)
- what an attacker could achieve, and any fix you have in mind

## What to expect

You will usually get a first reply within a week. Once the issue is
confirmed, a fix is prepared in the private advisory, released, and the
advisory is published with credit to you unless you prefer otherwise.
