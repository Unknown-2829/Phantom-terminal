# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| 4.x.x | ✅ Supported (Active) |
| 3.x.x | ⚠️ Security fixes only |
| < 3.0 | ❌ End of Life |

## Reporting a Vulnerability

If you discover a security vulnerability in Phantom Terminal:

1. **Do NOT** open a public issue.
2. Submit a report privately via GitHub Private Vulnerability Reporting or contact the maintainer directly at:
   - Telegram: [@unknownlll2829](https://t.me/unknownlll2829)
3. Please provide:
   - A clear description of the vulnerability.
   - Exact steps or proof-of-concept to reproduce the issue.
   - Operating system and shell version tested.
   - Potential impact of the issue.

We will review and acknowledge all reports within 48 hours.

## Security Architecture in v4.0.0+

- **Zero-Dependency Native Execution**: Phantom Terminal requires no external compilers, Python runtime, or package managers. Scripts run purely via native Windows PowerShell, PowerShell 7+, Bash, and Zsh.
- **Opt-in Silent Updates**: `SilentUpdate` is disabled by default (`false`), ensuring automated background updates only run when explicitly configured by the user.
- **Fail-Closed Release Verification & Embedded Trust Root**:
  - Fresh installations strictly download from versioned release tags.
  - Downloaded assets undergo AST parsing, syntax validation, and strict fail-closed SHA-256 release checksum verification against `SHA256SUMS`.
  - Installers embed hard-coded release digests (`EXPECTED_SHA256` / `$ExpectedSha256`) as an independent root-of-trust to authenticate the engine before installation.
  - If `SHA256SUMS` cannot be retrieved, lacks the target script entry, or does not match the embedded root-of-trust digest, execution immediately aborts with exit code 1.
  - Runtime updaters (`phantom-update`) download updates from versioned release tags, verify the SHA-256 hash against the release's `SHA256SUMS`, stage beside the target file, and atomically promote with backup rollback.
- **Transactional Staging (Remote and Local)**:
  - Both remote downloads and local repository installations (`./install.sh` and `.\install.ps1`) deploy through isolated temporary staging files (`.stage.<pid>`).
  - Staged files must pass AST syntax parsing (`bash -n` for Bash, `[System.Management.Automation.Language.Parser]` for PowerShell), size validation, and header verification before atomic promotion.
  - If any check fails, the staged file is deleted and the active engine and user profile (`.bashrc`, `.zshrc`, `$PROFILE`) remain 100% untouched.
- **Two-Step Checksum Verification (Pre-Execution Integrity)**:
  - Piping any script directly from `curl | bash` or `irm | iex` relies on transport security (HTTPS) to deliver an unmodified script. For users who wish to verify file integrity against in-transit corruption or CDN tampering prior to execution, download the installer and manifest, verify the SHA-256 hash, and execute the verified file:
    ```bash
    # Linux / Termux:
    curl -fsSLO https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.0.0/install.sh
    curl -fsSLO https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.0.0/SHA256SUMS
    grep "install.sh" SHA256SUMS | sha256sum -c - && bash install.sh

    # macOS / BSD:
    curl -fsSLO https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.0.0/install.sh
    curl -fsSLO https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.0.0/SHA256SUMS
    grep "install.sh" SHA256SUMS | shasum -a 256 -c - && bash install.sh
    ```
- **Best-Effort History Sanitization**: Universal history searches (`phantom-search`) provide best-effort heuristic filtering of targeted credential patterns (flags such as `--password`, `--token`, `Authorization: Bearer`, exported API keys, private key files) and strip shell timestamp prefixes. Because arbitrary user variables or custom argument structures cannot be fully parsed without an AST of every external CLI tool, this feature is a privacy convenience rather than a cryptographically enforced secret boundary.
- **Stealth Mode Scope**: Cyberpunk Stealth Mode (`phantom-stealth`) is a visual display/identity spoofing feature designed for screen recording, live streaming, and presentations. It obfuscates terminal display strings (username, hostname, paths, OS name); it does not provide OS-level sandboxing, kernel anonymity, or network VPN cloaking.
