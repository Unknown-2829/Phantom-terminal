# Platform Support & Architecture

Phantom Terminal v4.2.2 "Krypton" delivers pure native shell performance across Windows, Linux, macOS, and Termux with complete feature parity and **zero mandatory external dependencies**.

## Supported Platforms

| Platform | Shell | Requirements | Native Telemetry Engine | Status |
|---|---|---|---|:---:|
| **Windows 10 / 11** | Windows PowerShell 5.1 | Built-in Windows PowerShell | Native Win32 & .NET Environment | ✅ Full Support |
| **Windows 10 / 11** | PowerShell 7+ (`pwsh`) | PowerShell Core | Cross-platform .NET Core | ✅ Full Support |
| **Linux (All Distros)** | Bash 3.2+ / Zsh | Standard shell | Dual-sample `/proc/stat` delta & `/proc/meminfo` | ✅ Full Support |
| **macOS (Intel & Apple Silicon)** | Zsh / Bash 3.2+ | Default Terminal / iTerm2 | Native `top` & `vm_stat` hardware metrics | ✅ Full Support |
| **Android (Termux)** | Bash / Zsh | Termux environment | Calibrated `/proc/stat` delta & mobile auto-scaling | ✅ Full Support |
| **BSD (FreeBSD / OpenBSD)** | Bash / POSIX shell | Standard shell | POSIX system metrics | ✅ Full Support |

---

## ⚡ Zero-Dependency Architecture

Unlike traditional CLI enhancement tools, Phantom Terminal requires:
- ❌ **Zero Python or pip** (No Python runtime or virtual environments)
- ❌ **Zero Administrator / sudo privileges** (Installs purely in user `$HOME`)
- ❌ **Zero mandatory package installations** (No `apt`, `yum`, `brew`, or `pkg` calls during install)
- ❌ **Zero mandatory external modules** (PSReadLine is optional; native `phantom-search` works everywhere)

---

## Platform Details & Optimizations

### Windows (PowerShell)
- Works out-of-the-box on both legacy Windows PowerShell 5.1 and modern PowerShell 7+.
- Queries Win32 and .NET system APIs directly (< 5ms startup overhead, zero WMI query lag).
- Dynamic CPU & RAM usage bars render inside the 66-character box with closed right borders.
- Interactive zero-dependency history search (`phantom-search`).
- Encoded with UTF-8 BOM (`utf-8-sig`) for full compatibility with Windows PowerShell 5.1 string parsers.

### Linux
- **Tested Distributions**: Ubuntu (20.04/22.04/24.04), Debian (11/12), Fedora, Arch Linux, Alpine, CentOS/RHEL, openSUSE.
- Reads `/proc/stat` using a 100ms dual-sample delta for true real-time CPU usage instead of lifetime averages.
- Direct `/proc/meminfo` parsing for low-overhead RAM utilization.
- Visual character width helper (`_vlen`) dynamically adapts to system UTF-8 locales (`C.utf8`, `C.UTF-8`, `en_US.UTF-8`) and guarantees clean 66-column alignment even under `LC_ALL=C`.

### macOS
- Compatible with Terminal.app, iTerm2, Kitty, Alacritty, Ghostty, and WezTerm.
- Automatically identifies default shell (`~/.zshrc` vs `~/.bash_profile`).
- Native hardware queries: memory via `vm_stat` and `sysctl`, CPU via non-blocking single-iteration `top`.
- Eliminates Bash 4+ dependencies (`mapfile`, `declare -A`) and GNU extensions (`sort -V`) to maintain 100% compatibility with Apple's default Bash 3.2 environment.

### Android (Termux)
- Mobile-optimized column stepping (`col_step=3`) and shorter animations prevent rendering flicker on touch screens.
- Auto-scales dashboard layout when terminal width is narrower than 60 columns.
- Runs entirely without root or proot privileges.

---

## 📊 Feature Comparison Matrix

| Feature | Windows | Linux | macOS | Termux |
|---|:---:|:---:|:---:|:---:|
| **Matrix Rain Animation** | ✅ | ✅ | ✅ | ✅ (Optimized) |
| **Binary Rain Mode (`0101...`)** | ✅ | ✅ | ✅ | ✅ |
| **Glitch Logo Reveal** | ✅ | ✅ | ✅ | ✅ |
| **Dual Themes (`Phantom` / `Unknown`)** | ✅ | ✅ | ✅ | ✅ |
| **Instant Keypress Skip** | ✅ | ✅ | ✅ | ✅ |
| **AI Agent Guard (CI / Claude / Cursor)** | ✅ | ✅ | ✅ | ✅ |
| **Cyberpunk Stealth Mode** | ✅ | ✅ | ✅ | ✅ |
| **Live Telemetry HUD (`phantom-top`)** | ✅ | ✅ | ✅ | ✅ |
| **Universal History Search (`phantom-search`)** | ✅ | ✅ | ✅ | ✅ |
| **Non-blocking Git Branch Detection** | ✅ | ✅ | ✅ | ✅ |
| **Persistent Secrets Tracker** | ✅ | ✅ | ✅ | ✅ |
| **Safe Bounded Profile Hooks** | ✅ | ✅ | ✅ | ✅ |
| **Zero External Dependencies** | ✅ | ✅ | ✅ | ✅ |
