# Changelog

All notable changes to Phantom Terminal will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.2.2 "Krypton"] - 2026-10-18

### Fixed
- **Precision Title Box Alignment (`Show-UpdateCelebrationModal` & `show_update_celebration`)**:
  - Implemented terminal visual cell width compensation for `⚡` (U+26A1) emojis (which occupy 2 display cells in terminal font renderers but count as 1 character in .NET `.Length` and `wc -m`).
  - Standardized inner line padding to exactly 66 columns, eliminating the 2-column border hang over the right box boundary.
- **Upgrade Screen Changelog Resilience**:
  - Added direct caching of GitHub API release notes to `latest_changelog.md` and `release_notes.txt` during `phantom-update`, preventing fallback to outdated changelog highlights when CDN caches 404s on newly tagged releases.
  - Refreshed built-in fallback changelog highlights to reflect Krypton v4.2 features.
- **Piped Execution Crash Fix in `install.sh`**:
  - Resolved `bash: line 220: BASH_SOURCE[0]: unbound variable` when piped via `curl -fsSL ... | bash` under `set -u` by guarding `${BASH_SOURCE[0]:-}` and deriving script directory safely.
- **Multi-Tier Release Download Asset Fallback**:
  - `phantom-update` and installers now query official GitHub Release Asset URLs (`github.com/.../releases/download/...`) first with automatic fallback to raw repository URLs, eliminating release asset download failures during GitHub CDN propagation latency.
- **POSIX Profile Compatibility & Fail-Closed Checks**:
  - Replaced non-POSIX `source` command with `. "$INSTALL_PATH"` guarded by `BASH_VERSION` / `ZSH_VERSION` checks in `install.sh`, preventing syntax errors on POSIX shells like `dash`.
  - Added atomic verification to ensure startup hooks exist on disk before reporting installation success.
- **Configuration Corruption Safety**:
  - Added corruption detection in `Get-PhantomConfig` (PowerShell) and `load_config` (Bash) that creates a timestamped `.corrupt` backup and warns the user without overwriting or destroying original settings.

## [4.2.1 "Krypton"] - 2026-10-18

### Added
- **Configurable AI Agent Guard Bypass (`AIBypass`)**:
  - Auto AI bypass enabled by default (`"AIBypass": true`) to preserve tokens and eliminate transcript clutter across automated agents and CI/CD pipelines.
  - Can be toggled on or off directly via `phantom-config aibypass on|off` or by modifying `config.json`.
- **VS Code Integrated Terminal Animation Control (`AllowVSCodeAnimations`)**:
  - Animations are allowed in VS Code integrated terminals by default (`"AllowVSCodeAnimations": true`), while automated tools and background agents remain silenced.
  - Configurable via `phantom-config vscode on|off` or in `config.json`.
- **Configurable Stealth Mode Path Cloaking (`StealthMaskPath`)**:
  - Real directory path is now displayed by default in stealth mode (e.g. `Hp@D:\Projects\Coding`), preserving full shell awareness while masking identity.
  - Users can enable full path obfuscation (`ghost@~/phantom/core/grid`) by setting `"StealthMaskPath": true` or toggling `phantom-config maskpath on|off`.
- **Interactive Configuration Management CLI & Box HUD (`phantom-config` / `unknown-config`)**:
  - Brand-new formatted 66-column configuration HUD displaying live ON/OFF status for all settings.
  - Added direct command-line toggle setters: `phantom-config [setting] on|off` (e.g., `aibypass`, `maskpath`, `vscode`, `animation`, `live`, `bars`, `fullpath`, `suggestions`).
  - Added `-Reset` (`--reset`) to revert configuration to factory defaults, and `-Edit` (`--edit`) to open config in system editor.
- **Dedicated Release Documentation**: Created crisp, terminal-friendly changelog at `docs/changelogs/v4.2.1.md`.

### Fixed
- **Title Box Border Alignment**:
  - Standardized inner width calculation in `Show-Dashboard` (`PhantomStartup.ps1`) and `show_dashboard` (`PhantomStartup.sh`), fixing a 2-column right border gap and achieving flush 66-column closed borders.
- **Interactive Upgrade Changelog Modal**:
  - Post-update celebration modal now pauses and prompts `Press any key to continue...`, waiting for user keypress instead of disappearing prematurely.
  - Celebration modal is now strictly restricted to upgrading users with an older `LastSeenVersion`, completely skipping fresh installations.

### Changed
- Bumped project version to **4.2.1** across PowerShell and Bash engines, installers, tests, documentation, and release manifests.
- Preserved `AIBypass`, `AllowVSCodeAnimations`, and `StealthMaskPath` across installer upgrades.

---

## [4.1.0 "Krypton"] - 2026-10-18

### Added
- **Theme-Matched Rotating Sci-Fi Telemetry**:
  - In Stealth Mode and customizable sessions, the Operator, Host, System/Kernel, and Uptime telemetry now dynamically rotate per session and match the active theme identity:
    - **Phantom Theme**: Operators (`Ghost`, `Cipher`, `Spectre`, `Valkyrie`, `Null`, `Ronin`, `Phantom-0`), Hosts (`NEO-TOKYO-GRID`, `SHADOW-NET-CORE`, `ORBITAL-STATION-7`, `BLACK-ICE-NODE`, `NEURAL-MATRIX-01`, `PHANTOM-GATEWAY`), Systems (`Phantom OS v4.1.0 (Quantum Microkernel)`, `Phantom Neural Core v4.1.0 (Sub-atomic)`, `Phantom Mesh OS v4.1.0 (Encrypted)`, `Phantom Quantum Kernel v4.1.0 (Ring-0)`), and Uptimes (`∞ (Untraceable)`, `99.999% (Cloaked)`, `Sub-atomic Flux (Active)`, `Quantum Loop (Shielded)`).
    - **Unknown Theme**: Operators (`Anonymous`, `Unknown-2829`, `Root-Null`, `Operator-X`, `Enigma`, `Cipher-2829`, `Shadow-Ghost`), Hosts (`DARKNET-GATEWAY`, `ANONYMOUS-NODE-X`, `NULL-SECTOR-404`, `CIPHER-GRID-2829`, `SHADOW-RELAY-0`, `VOID-MATRIX-2829`), Systems (`Unknown Kernel v4.1.0 (Zero Footprint)`, `Unknown Mesh OS v4.1.0 (Dark-Routing)`, `Unknown Void Subsystem v4.1.0`, `Unknown Protocol v4.1.0 (Ephemeral)`), and Uptimes (`Redacted (Zero-Log)`, `Hidden Route (Active)`, `Ephemeral Loop (Active)`, `Zero-Trace (Cloaked)`).
  - Telemetry CPU and RAM metrics now feature a subtle randomized cyber flux in stealth sessions (8–16% CPU, 12–22% RAM).
  - Stealth prompt path dynamically reflects the theme: `~/phantom/core/grid` for Phantom vs `~/unknown/darknet/grid` for Unknown.
- **Enhanced Prompt Spacing**:
  - Added clean double-spacing between the status indicator (`✔` / `✘`) and the prompt arrow (`»` / `>`) across PowerShell, Bash, and Zsh (`✔  » `), eliminating cramped text rendering in modern terminal fonts.
- **Dedicated v4.1.0 Release Documentation**: Added comprehensive changelog documentation at `docs/changelogs/v4.1.0.md`.

### Fixed
- **Dashboard Box & Usage Bar Right-Border Overflow**:
  - Resolved border misalignment where CPU and RAM rows pushed the right double-line border (`║`) 1 cell past the 66-column boundary in Windows Terminal, Linux, and macOS monospace fonts.
  - Replaced ambiguous-width Unicode pictographs (`⚙` / `☰`) with standardized, font-resilient monospace labels (`CPU:` and `RAM:` padded to exactly 10 characters).
  - Usage bar opening brackets `[` on CPU and RAM rows now align with pixel-perfect vertical precision at column 14.
- **Quote Row Padding & Border Alignment**:
  - Corrected quote row string construction in both PowerShell (`Show-Dashboard`) and Bash (`show_dashboard`) to output 2 spaces after the left vertical border, resolving an off-by-one indentation error where the right border closed 1 character inside the box boundary.
- **Title Row Visual Centering & Emoji Width Accounting**:
  - Accounted for the 2-cell display width of the skull glyph (`☠`) in modern terminal font engines (Cascadia Code, DirectWrite, CoreText, libvte).
  - Added explicit 2-space breathing room between skulls and title text (`☠  UNKNOWN TERMINAL v4.1.0 "Krypton"  ☠`), preventing terminal font engines from rendering wide glyphs over adjacent text.
- **Installer Header & Completion Box Centering**:
  - Replaced hardcoded space padding in `install.ps1` and `install.sh` with dynamic mathematical centering, ensuring top corners (`╔`, `╗`), side borders (`║`), and bottom corners (`╚`, `╝`) align flawlessly regardless of version string or codename length.
- **Test Suite Telemetry Matrix**:
  - Updated `tests/test_engine.ps1` to validate rotating themed telemetry pools across both Phantom and Unknown themes, achieving 100% test pass rates across all 69 test assertions.

### Changed
- Bumped project version to **4.1.0** across `PhantomStartup.ps1`, `PhantomStartup.sh`, `install.ps1`, `install.sh`, `SHA256SUMS`, `README.md`, and test suites.
- Recomputed release authenticity root-of-trust digests (`EXPECTED_SHA256` / `$ExpectedSha256`) and refreshed `SHA256SUMS`.

---

## [4.0.0 "Krypton"] - 2026-10-17

### Added
- **AI Agent Guard**: Instant silent startup for subshells, CI/CD runners (`$CI`, `$GITHUB_ACTIONS`), and AI coding agents (`$CLAUDE_AGENT`, `$CURSOR_AGENT`, Copilot, non-interactive tty). Override with `PHANTOM_FORCE=1` or silence on-demand with `PHANTOM_QUIET=1`.
- **Cyberpunk Stealth Mode (`phantom-stealth`)**: Hardware and identity cloaking system. Masks Operator, OS, CPU, Host, RAM, and Prompt path (`~/phantom/core/grid`) with customizable sci-fi aliases (`phantom-stealth on|off|toggle`).
- **Interactive Live Telemetry (`phantom-dash -Live` / `phantom-top` / `phantom-live`)**: In-place real-time monitoring of CPU, RAM, and Uptime directly inside the dashboard box without terminal scrollback clutter. Exits cleanly on any keypress.
- **Zero-Dependency History Search (`phantom-search`)**: Interactive cross-platform command history search (`F2` / `phantom-search`) running purely on native shell primitives without requiring PSReadLine 2.2+, Python, or external binaries.
- **Fail-Closed Release Verification & Embedded Root-of-Trust**: Both fresh installations and runtime updaters enforce fail-closed cryptographic integrity using `SHA256SUMS` manifests and embedded root-of-trust digests (`EXPECTED_SHA256` / `$ExpectedSha256`), aborting execution immediately if checksums mismatch or manifests are unavailable.
- **Atomic Transactional Staging (Remote & Local)**: Installers deploy updates to isolated temporary files (`.stage.<pid>`), completing AST parsing and SHA-256 validation *before* promoting files or touching user profile hooks. Both remote downloads and local repository installations undergo isolated staging and AST syntax validation. If any error occurs, active installations and profiles remain 100% untouched.
- **Headless CI & Automated Installer Mode**: Both `install.sh` and `install.ps1` natively detect CI environments, skipping interactive prompts, handling console handles safely in non-interactive pipelines, and supporting `$env:PHANTOM_HOME` and `$env:PHANTOM_PROFILE` overrides for test isolation.
- **Automated Engine Test Suites**: Added `tests/test_engine.ps1` (31 tests) and `tests/test_engine.sh` (36 tests) validating SemVer comparison, Agent Guard detection, profile boundary parsing, string visual length calculations, history filtering, end-to-end installer transaction safety, and strict fail-closed verification.
- **Zsh Native Support & CI**: Added native Zsh prompt hooks (`add-zsh-hook precmd _phantom_ps1`), POSIX parameter expansion for git branch detection, and multi-platform GitHub Actions CI coverage across Linux, macOS, and Windows.
- **Strict Line Ending Enforcement**: Added `.gitattributes` and `.editorconfig` enforcing LF for all Unix shell scripts and CRLF with UTF-8 BOM for Windows PowerShell scripts.

### Fixed
- **Semantic Versioning Comparison (Bug 1)**: Replaced alphabetical string comparisons with pure Semantic Versioning (`[version]` in PS1 and pure Bash integer SemVer arithmetic). Double-digit minor/patch numbers (e.g. `3.10.0` vs `3.9.0`) and pre-releases (`4.0.0 > 4.0.0-beta.10`) now compare accurately without requiring GNU `sort -V`.
- **PowerShell Easter Eggs Persistence (Bug 2)**: Replaced ephemeral in-memory storage with persistent disk-backed JSON storage at `~/.phantom-terminal/.secrets`. Fixed array unrolling bugs when loading single-item secrets.
- **Update Target Path Drift (Bug 3)**: Unified installation target across all platforms to `~/.phantom-terminal/PhantomStartup.ps1` / `.sh`. Auto-migrates legacy `$HOME\PhantomStartup.ps1`.
- **Termux & Linux CPU Telemetry (Bug 4)**: Replaced single `/proc/stat` read with a 100ms dual-sample delta, accurately reporting real-time CPU utilization rather than post-boot lifetime averages.
- **Easter Eggs Leak in Help Menu (Bug 5)**: Removed hidden commands from standard `phantom-help` in Bash, aligning with PowerShell parity.
- **SmartSuggestions Configuration Loss (Bug 6)**: Added full serialization, validation, and retention of `SmartSuggestions`, `StealthMode`, `LiveStats`, and `ShowUsageBars` across config re-saves.
- **Non-blocking Git HUD (Bug 7)**: Wrapped git branch lookups with timeouts and direct `.git/HEAD` traversal so unresponsive or massive Git repositories never hang shell launch.
- **Safe Profile Cleaner (Bug 8 / F-06)**: Replaced greedy regex sed deletion with an exact 3-line buffered state machine in `awk` and timestamped backups, protecting user custom comments, aliases, and functions.
- **PowerShell Core Cross-Platform Path Portability (F-05)**: Replaced Windows-only `$env:USERPROFILE` with platform-agnostic `$HOME` and `Join-Path` directory resolution, ensuring flawless operation across Linux, macOS, and Windows.
- **History Credential Filter False Positives (F-08)**: Replaced broad keyword matching with precise parameter flags and assignments (`--password=`, `export API_KEY=`, `cat id_rsa`), permitting safe commands like `git commit -m "feat: auth login"` or `kubectl get secret`.
- **JSON Boolean Normalization (Bug 9)**: Enforced strict lowercase `true`/`false` booleans in Bash config writer to avoid invalid capitalized JSON.
- **Dashboard Box Visual Alignment**: Unified dashboard box width to 66 characters across PowerShell, Linux, macOS, and Termux with closed right borders (`║`) on CPU/RAM usage bars.
- **Ctrl+C Terminal State Restoration**: Scoped signal traps strictly around animations and live monitors, restoring cursor visibility without killing active shell sessions upon interrupt.
- **Zero External Dependencies**: Removed `Install-Module PSReadLine`, `sudo apt-get`, and `pkg install jq`. Zero Python, zero pip, zero mandatory modules, zero admin requirements.

### Changed
- Unified project version to **4.0.0** across all engines, installers, test suites, and documentation.
- Streamlined documentation architecture with dedicated guides in `docs/` (`install.md`, `configuration.md`, `platforms.md`, `troubleshooting.md`, `uninstall.md`, `changelogs/`).
- Cleaned distribution archive packaging to exclude `.git` metadata, reducing release archive size from 1.1 MB down to 76.2 KB.

---

## [3.7.0] - 2026-04-03

### Fixed

* **Termux / narrow-terminal box alignment** — root cause was `bash ${#var}` returning
  *byte count* for UTF-8 strings, not visual character count. Box-drawing chars like
  `║ ═ ╔` are 3 bytes each in UTF-8, so the old padding formula placed the right border
  ~2× too far right on Termux. Fix: new `_vlen()` helper strips ANSI codes and counts
  characters with `wc -m` before every padding calculation in `show_dashboard()`.
* **`_row()` value truncation** — long OS names or hostnames that exceed box width now
  truncate cleanly instead of overflowing and breaking alignment.
* **`write_centered()` centering** — also switched to `_vlen()` so ANSI-colored text
  centres correctly on all platforms.
* **Core ignition centering** — `[CORE_INIT]` etc. now visually centred on Termux.

### Changed

* **Matrix rain** — sparser columns and lead/trail char fade now match Windows version.
  `col_step=2` on Linux/macOS (every other column), `col_step=3` on Termux (mobile perf).
* **Uptime format** — switched from parsing `uptime` text output (varies by distro) to
  reading `/proc/uptime` directly. Output format `2d 4h 17m` now matches Windows version.
* **OS name** — reads `/etc/os-release → PRETTY_NAME` on Linux so dashboard shows
  `Ubuntu 24.04.4 LTS` / `Arch Linux` etc., matching Windows' `Microsoft Windows 11 Pro`.
* **Hostname** — strips domain suffix (`host.local` → `host`) for cleaner display.
* **Glitch reveal** — added `col_step=3` / shorter duration on Termux to avoid flicker.
* **`SCRIPT_VERSION`** bumped to `3.7.0` in `PhantomStartup.sh`.

### Technical

* New helper `_vlen()` — strips ANSI escapes via `sed`, then counts chars with `wc -m`.
  Used by `show_dashboard`, `write_centered`, and `show_core_ignition`.
* Box inner-width arithmetic now always operates on visual character counts, never bytes.
* `write_usage_bar` bar-width now derived from `inner - 22` (dynamic) so CPU/RAM bars
  fit correctly on any terminal width including Termux.

---

## [3.6.1] - 2026-04-03

### Fixed
- Linux CPU usage detection now uses a `/proc/stat` dual-read sample for more accurate readings in the dashboard.
- Unicode capability detection now handles more Linux terminal types (including Alacritty, Kitty, and tmux) with safer fallbacks.
- Config cache parsing now has a fallback path when `jq` is unavailable.
- Date handling has improved Linux/macOS compatibility (`date -d` vs `date -j`).
- Platform detection fallback now defaults to Linux behavior instead of unknown mode when detection is ambiguous.

### Changed
- Unified project version metadata to **3.6.1** across startup scripts, installer banners, and top-level documentation.

---

## [3.6.0] - 2026-02-12

### Added
- **🌍 Cross-Platform Support**: Now works on Linux, macOS, and Termux (Android)!
  - New Bash/Shell version (`PhantomStartup.sh`) with feature parity to PowerShell version
  - All animations, themes, and effects ported to Unix-like systems
  - Termux-optimized with mobile-friendly display options
- **Universal Installer**: `install.sh` with automatic platform detection
  - Auto-detects: Linux, macOS, Termux, or Windows
  - Automatically selects appropriate shell profile (.bashrc, .zshrc, .bash_profile)
  - Smart dependency installation for each platform
  - Preserves existing configuration on reinstall
- **Platform-Specific Optimizations**:
  - Termux: ASCII fallback for better mobile compatibility
  - macOS: Proper .bash_profile handling
  - Linux: Support for multiple package managers (apt, yum, pkg)
- **Enhanced README**:
  - Installation instructions for all platforms
  - Platform-specific badges
  - Uninstall instructions for each OS

### Changed
- Version bumped to 3.6.0 to reflect major cross-platform milestone
- Updated documentation to emphasize multi-platform support
- Installer now more robust with better error handling

### Technical Details
- Bash version supports all PowerShell features:
  - Matrix rain animation (Letters/Binary modes)
  - Multi-color gradient effects
  - Glitch reveal animations
  - Security loading sequences
  - Two themes (Phantom/Unknown)
  - Custom prompt with git branch detection
  - Dashboard with system information
  - Configuration management with JSON
  - Auto-update checking
- Universal installer (`install.sh`):
  - Platform detection via `$OSTYPE` and environment variables
  - Shell detection (bash/zsh/sh)
  - Automatic profile file selection
  - Dependency checking and installation
  - Config preservation across reinstalls

---

## [3.5.0] - 2026-01-26

### Added
- **Smart Installer Upgrade**: 
  - Auto-checks and installs PSReadLine 2.2+ (needed for suggestions)
  - New "Smart Suggestions" option in installer wizard
  - Handles admin/non-admin installation gracefully

---

## [3.4.1] - 2026-01-26

### Fixed
- **Auto-fix PSReadLine Version**: Automatically loads the newest installed version (fixes "Version 2.0.0" issue on Windows)

---

## [3.4.0] - 2026-01-26

### Changed
- **Smart Suggestions v2** - Simplified and reliable
  - Inline predictions as you type (theme-colored)
  - `F2` / `Ctrl+F` / `End` to accept suggestion
  - No duplicate history, faster performance
  - 100% local, no data collection

---

## [3.3.9] - 2026-01-26

### Changed
- **Tab accepts suggestion** - Press Tab to complete inline suggestion
- Theme-based suggestion colors (purple for Phantom, green for Unknown)

---

## [3.3.8] - 2026-01-26

### Changed
- **Browser-style inline suggestions** - Gray text appears as you type
- Press `RightArrow` or `End` to accept suggestion

---

## [3.3.7] - 2026-01-26

### Fixed
- Stability improvements

---

## [3.3.6] - 2026-01-26

### Changed
- UI improvements

---

## [3.3.5] - 2026-01-26

### Fixed
- Minor improvements

---

## [3.3.4] - 2026-01-26

### Fixed
- Stability improvements

---

## [3.3.3] - 2026-01-26

### Fixed
- Syntax fix for all PowerShell versions

---

## [3.3.2] - 2026-01-26

### Fixed
- Syntax compatibility fix

---

## [3.3.1] - 2026-01-26

### Fixed
- Minor internal improvements

---

## [3.3.0] - 2026-01-26

### Added
- **Smart Suggestions** - History-based command predictions (default ON)
  - ListView shows multiple suggestions as you type
  - Theme-matching colors
  - `Tab` = menu complete, `Ctrl+F` = accept suggestion
  - `Up/Down` arrows = history search
  - 100% local processing, **no data collection**

---

## [3.2.9] - 2026-01-24

### Changed
- **Compact UNKNOWN logo** - Cleaner, more readable ASCII art

---

## [3.2.8] - 2026-01-24

### Added
- **Unknown theme commands** - `unknown-help`, `unknown-reload`, etc. work for Unknown theme users
- Dashboard shows `unknown-help` instead of `phantom-help` for Unknown theme
- Updated README with new Unknown ASCII art

---

## [3.2.7] - 2026-01-24

### Changed
- **Better UNKNOWN ASCII art** - Cleaner, smoother font style with proper W letter

---

## [3.2.6] - 2026-01-24

### Fixed
- **UNKNOWN ASCII art** - Was showing "UNKOUN", now shows correct "UNKNOWN" with W
- Improved Unknown theme logo design

---

## [3.2.5] - 2026-01-24

### Changed
- **Background updates after dashboard** - Update check now runs AFTER animation finishes
- Uses PowerShell background job - doesn't slow startup
- Terminal stays fast even when checking for updates

---

## [3.2.4] - 2026-01-24

### Fixed
- **ShowSystemInfo now works** - Set to false to hide system info in dashboard
- Added ShowSystemInfo option in installer
- All config options now properly applied

---

## [3.2.3] - 2026-01-24

### Fixed
- **PowerShell 5.1 compatibility** - Config loading now works on all PS versions
- Removed `-AsHashtable` parameter (requires PS6+)
- Config properties now explicitly copied for reliability
- Using `Out-File` for consistent UTF8 encoding

---

## [3.2.2] - 2026-01-24

### Changed
- **Performance optimizations** - Faster config loading and installer
- **Theme-colored help** - `phantom-help` now shows in gold color
- **Reliable config save** - Using Out-File for better persistence
- **Updated README** - New features and themes documented

### Fixed
- Config sometimes forgetting choices on reinstall
- Installer now properly loads all previous settings

---

## [3.2.1] - 2026-01-24

### Changed
- Quote now displays inside the dashboard box (like previous version)
- Removed CPU/RAM bars (cleaner dashboard)
- Removed typing effect (faster loading)
- Simplified installer options

---

## [3.2.0] - 2026-01-24

### Added
- **Binary Rain Mode** - Choose between Letters or Binary (01) matrix rain
- **CPU/RAM Usage Bars** - Real-time system stats in dashboard
- **Typing Effect** - Character-by-character reveal for quotes
- **Gradient Logo** - Multi-color gradient for logo display
- **Extended Quotes** - 8 quotes per theme, theme-specific content
- **Theme-Specific Matrix** - Different characters per theme

### Changed
- **Fully Automatic Updates** - Downloads silently, shows "Reopen to apply"
- **Installer Overhaul** - Step-by-step options for all features
- Themes now have taglines, gradient colors, and custom matrix chars

### Fixed
- Auto-update now works reliably with proper caching
- Update notification shows correct status

---

## [3.1.1] - 2026-01-24

### Added
- **ShowFullPath option** - Choose full path or folder name in prompt
- Path display selection during installation

### Fixed
- Theme now persists correctly across terminal restarts
- Case-insensitive theme matching (unknown/Unknown both work)
- Improved installer theme selection UI with ASCII art preview

---

## [3.1.0] - 2026-01-24

### Added
- **Theme System** - Switch between Phantom and Unknown themes
- **Unknown Theme** - Green/Blue neon with anonymous styling
- **phantom-theme command** - Easy theme switching
- **Silent Auto-Update** - Background update check without disturbance
- **Theme selection during install** - Choose theme at installation

### Changed
- Auto-update now runs silently in background using PowerShell jobs
- Dashboard shows current theme
- Colors and logos adapt to selected theme

---

## [3.0.1] - 2026-01-24

### Fixed
- Fixed encoding issues with emojis causing parse errors
- Fixed special characters in strings (ampersand, brackets)
- Improved ASCII-safe symbols with Unicode fallback

### Changed
- Installer now detects existing installation and cleans properly
- Installer removes old profile entries before adding new
- Simpler ASCII logo for better compatibility

---

## [3.0.0] - 2026-01-24

### Added
- 🚀 **StringBuilder Fast Rendering** - Optimized rendering using StringBuilder for smoother animations
- 📁 **External JSON Config** - Configuration stored in `~\.phantom-terminal\config.json`
- 🔄 **Auto-Update Checker** - Checks GitHub for new versions automatically
- 📦 **One-Line Installer** - Simple `irm | iex` installation
- 🎮 **New Commands** - `phantom-update`, `phantom-config -Edit`

### Changed
- Renamed all commands from `unknown-*` to `phantom-*`
- Improved matrix animation performance
- Better Unicode symbol handling with ASCII fallback

### Fixed
- Terminal size detection on various Windows configurations
- ANSI escape code compatibility

## [2.0.0] - 2026-01-20

### Added
- Multi-color matrix rain animation
- Security loading bars with glitch effects
- Core ignition sequence
- Glitch reveal animation
- System dashboard with uptime
- Custom colored prompt with git branch detection

### Changed
- Complete rewrite from bash to PowerShell
- Optimized for Windows Terminal

## [1.0.0] - 2026-01-15

### Added
- Initial PowerShell port
- Basic matrix animation
- Simple dashboard

---

[4.2.1]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v4.2.1
[4.1.0]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v4.1.0
[4.0.0]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v4.0.0
[3.7.0]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.7.0
[3.6.1]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.6.1
[3.6.0]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.6.0
[3.5.0]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.5.0
[3.4.1]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.4.1
[3.4.0]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.4.0
[3.3.9]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.3.9
[3.3.8]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.3.8
[3.3.7]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.3.7
[3.3.6]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.3.6
[3.3.5]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.3.5
[3.3.4]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.3.4
[3.3.3]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.3.3
[3.3.2]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.3.2
[3.3.1]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.3.1
[3.3.0]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.3.0
[3.2.9]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.2.9
[3.2.8]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.2.8
[3.1.1]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.1.1
[3.1.0]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.1.0
[3.0.1]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.0.1
[3.0.0]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v3.0.0
[2.0.0]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v2.0.0
[1.0.0]: https://github.com/Unknown-2829/Phantom-terminal/releases/tag/v1.0.0
