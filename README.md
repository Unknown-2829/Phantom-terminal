# 🔮 Phantom Terminal v4.1.0 "Krypton"

<p align="center">
  <img src="https://img.shields.io/badge/version-4.1.0_%22Krypton%22-purple?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=for-the-badge&logo=powershell" alt="PowerShell">
  <img src="https://img.shields.io/badge/Bash-3.2%2B-green?style=for-the-badge&logo=gnu-bash" alt="Bash">
  <img src="https://img.shields.io/badge/Windows-10%2F11-0078D6?style=for-the-badge&logo=windows" alt="Windows">
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple" alt="macOS">
  <img src="https://img.shields.io/badge/Termux-Android-32DE84?style=for-the-badge&logo=android" alt="Termux">
  <img src="https://img.shields.io/github/license/Unknown-2829/Phantom-terminal?style=for-the-badge" alt="License">
</p>

<p align="center">
  <b>The cinematic cyberpunk startup sequence and real-time telemetry HUD for your terminal.</b><br>
  Multi-color matrix rain • Dual cyber themes • Live hardware monitor • Stealth cloaking • AI Agent Guard<br>
  <i>Runs purely on native shell — Windows (PowerShell), Linux, macOS, and Termux (Android).</i>
</p>

---

## ⚡ Quick Install

Install in seconds with a single command. **Zero external dependencies** — requires no Python, no pip, no admin/sudo rights, and no mandatory package installations.

### Windows (PowerShell 5.1+ / 7+)
```powershell
irm https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/install.ps1 | iex
```

### Linux / macOS / Termux (Bash / Zsh)
```bash
curl -fsSL https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/install.sh | bash
```

*or with wget:*
```bash
wget -qO- https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/install.sh | bash
```

### 🛡️ Two-Step Checksum Verification

To verify download integrity against in-transit corruption or transfer errors prior to execution:

**Linux / Android Termux:**
```bash
curl -fsSLO https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/install.sh
curl -fsSLO https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/SHA256SUMS
grep "install.sh" SHA256SUMS | sha256sum -c - && bash install.sh
```

**macOS / BSD:**
```bash
curl -fsSLO https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/install.sh
curl -fsSLO https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/SHA256SUMS
grep "install.sh" SHA256SUMS | shasum -a 256 -c - && bash install.sh
```

**Windows PowerShell:**
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/install.ps1" -OutFile install.ps1
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/SHA256SUMS" -OutFile SHA256SUMS
$expected = (Get-Content SHA256SUMS | Where-Object { $_ -match '\s+install\.ps1$' } | ForEach-Object { ($_ -split '\s+')[0] })
if ((Get-FileHash install.ps1 -Algorithm SHA256).Hash.ToLower() -eq $expected.ToLower()) { .\install.ps1 } else { throw "Checksum mismatch" }
```

**Interactive Installer Options:**
- **Theme** — Choose between **Phantom** (Purple/Cyan) and **Unknown** (Green/Blue)
- **Matrix Rain Mode** — Traditional **Letters** (Katakana/Matrix glyphs) or Cyber **Binary** (`0101...`)
- **Path Display** — Clean **Folder Name** only or **Full Directory Path**
- **Hardware Telemetry** — Enable CPU & RAM usage bars and dynamic system metrics
- **Smart Suggestions** — History-based command predictions without external dependencies

---

## 🎨 Themes Showcase

Phantom Terminal includes two distinct cyberpunk visual themes with custom ASCII typography and ANSI color palettes:

### 💜 Phantom Theme (Purple / Cyan)
```
 ____  _   _    _    _   _ _____ ___  __  __ 
|  _ \| | | |  / \  | \ | |_   _/ _ \|  \/  |
| |_) | |_| | / _ \ |  \| | | || | | | |\/| |
|  __/|  _  |/ ___ \| |\  | | || |_| | |  | |
|_|   |_| |_/_/   \_\_| \_| |_| \___/|_|  |_|
```

### 💚 Unknown Theme (Green / Blue)
```
 _   _ _   _ _  ___   _  _____        ___   _ 
| | | | \ | | |/ / \ | |/ _ \ \      / / \ | |
| | | |  \| | ' /|  \| | | | \ \ /\ / /|  \| |
| |_| | |\  | . \| |\  | |_| |\ V  V / | |\  |
 \___/|_| \_|_|\_\_| \_|\___/  \_/\_/  |_| \_|
```

Switch between themes anytime with `phantom-theme` (or `unknown-theme`).

> [!NOTE]
> **100% Unknown-Terminal Peer Parity:** Phantom Terminal is equally **Unknown-Terminal**. Every single command has an identical `unknown-*` equivalent (`unknown-help`, `unknown-dash`, `unknown-stealth`, `unknown-search`, `unknown-live`, `unknown-secrets`, etc.). When the **Unknown** theme is active, all interactive help menus, dashboard footers, celebration screens, and installer summaries automatically adapt to `unknown-*` syntax.

---

## ✨ Key Features

| Feature | Description |
|:---|:---|
| 🎬 **Cinematic Startup** | Multi-stage boot ignition, security sequences & glitch logo reveal |
| 🌧️ **Matrix Rain** | Customizable Katakana letters or cyber binary mode with theme colors |
| 📊 **Dashboard HUD** | 66-column aligned system specs, host info, uptime, and CPU & RAM bars |
| ⚡ **Live Telemetry Monitor** | Real-time, in-place refreshing hardware monitor (`phantom-dash -Live` / `phantom-top`) |
| 🕶️ **Cyberpunk Stealth Mode** | Visual identity and hardware spoofing for screen shares and streams (`phantom-stealth`) |
| 🎨 **Dual Themes** | Seamless switching between `Phantom` (Purple/Cyan) and `Unknown` (Green/Blue) |
| 💡 **Smart Suggestions** | History-driven predictive auto-suggestions for instant command recall |
| 🔍 **Credential-Safe Search** | Interactive command-history search with automatic token and key masking (`phantom-search`) |
| ⏩ **Skip on Keypress** | Tap any key during launch to immediately bypass animations and jump to prompt |
| 🛡️ **AI Agent & CI Guard** | Instant sub-millisecond silent startup inside Claude Code, Cursor, Copilot & CI runners |
| 📱 **Mobile & Termux Ready** | Responsive layout scaling for small screens and Android touch terminals |
| 🏆 **Secrets & Achievements** | Hidden cyber commands with persistent unlock tracking (`phantom-secrets`) |

### 🎬 Cinematic Startup Experience
- **Multi-Stage Ignition**: High-speed core initialization, matrix rain sequence, security loading bars with glitch effects, and smooth logo reveal.
- **Skip on Keypress**: Tap any key (such as Spacebar) during launch to immediately skip straight to your prompt.
- **Subshell & Tmux Protection**: Automatically prevents animation replays when opening child processes or nested tmux panes.

### 📊 Hardware Telemetry HUD & Live Monitor
- **Real-Time System Metrics**: Displays Operator, Host, OS, Uptime, and dynamic CPU & RAM usage bars locked to a clean 66-column border.
- **Interactive Live Telemetry (`phantom-dash -Live` / `phantom-top`)**: Dynamic, in-place refreshing monitor displaying live system resource utilization with single-key exit.
- **Fast Non-Blocking Git HUD**: Reads `.git/HEAD` directly across repositories and subdirectories without spawning sluggish child processes.

### 🕶️ Cyberpunk Stealth Mode
- **Display Spoofing (`phantom-stealth`)**: Mask sensitive hostnames, usernames, real paths, and hardware specs during screen recordings, live streams, or demos. (Note: this is a terminal visual display spoofing feature, not a kernel sandbox or network VPN).
- Quickly toggle between real hardware telemetry and cyberpunk spoofed profiles with `phantom-stealth toggle`.

### 🛡️ AI Agent & CI Guard
- **Zero-Latency Agent Startup**: Automatically detects AI coding agents (Claude Code, Cursor, Copilot CLI, Gemini, Windsurf), CI/CD runners (`$CI`, `$GITHUB_ACTIONS`), and redirected input/output pipes.
- Instantly bypasses all animations and visual delays, providing sub-millisecond shell startup for automated pipelines.
- Manual control via `export PHANTOM_QUIET=1` or `export UNKNOWN_QUIET=1` (silent), and `export PHANTOM_FORCE=1` or `export UNKNOWN_FORCE=1` (force animations).

### 🔍 Zero-Dependency History Search
- **Universal History Search (`phantom-search`)**: Fast, interactive command history search with substring matching and best-effort credential filtering running purely on native shell primitives. Works on Windows, Linux, macOS, and Termux with zero module dependencies.

---

## 🛠️ Commands Reference

All commands support dual-identity aliases (`phantom-*` and `unknown-*`):

| Command (Phantom / Unknown) | Description |
|-----------------------------|-------------|
| `phantom-help` / `unknown-help` | Display the interactive command guide and status overview |
| `phantom-dash` / `unknown-dash` | Display the system specs and hardware telemetry dashboard |
| `phantom-dash -Live` / `unknown-dash -Live` | Open real-time, in-place hardware monitor (`phantom-top` / `unknown-top` / `phantom-live` / `unknown-live`) |
| `phantom-stealth [on\|off\|toggle]` | Activate or toggle Cyberpunk identity and hardware cloaking |
| `phantom-theme` / `unknown-theme` | Interactively switch between `Phantom` and `Unknown` visual themes |
| `phantom-search` / `unknown-search` | Interactive zero-dependency command history search |
| `phantom-matrix` / `unknown-matrix` | Run the fullscreen multi-color matrix rain animation |
| `phantom-reload` / `unknown-reload` | Replay the full cinematic startup animation sequence |
| `phantom-config` / `unknown-config` | View active configuration settings |
| `phantom-config -Edit` / `unknown-config -Edit` | Open `config.json` in your system's default text editor |
| `phantom-update` / `unknown-update` | Check for updates with AST syntax verification and safe backup |
| `phantom-changelog` / `unknown-changelog` | Display full changelog highlights and release history |
| `phantom-secrets` / `unknown-secrets` | View unlocked achievements and easter egg status |

---

## ⚙️ Configuration

Phantom Terminal saves user configuration to `~/.phantom-terminal/config.json`.

```json
{
  "AnimationEnabled": true,
  "MatrixDuration": 2,
  "MatrixMode": "Letters",
  "SecurityLoadSteps": 8,
  "GlitchIntensity": 3,
  "ShowSystemInfo": true,
  "ShowFullPath": true,
  "GradientText": true,
  "SmartSuggestions": true,
  "Theme": "Phantom",
  "AutoCheckUpdates": true,
  "SilentUpdate": false,
  "UpdateCheckDays": 1,
  "StealthMode": false,
  "LiveStats": false,
  "ShowUsageBars": true
}
```

### Settings Breakdown

| Setting | Type | Options | Description |
|---------|------|---------|-------------|
| `Theme` | string | `"Phantom"`, `"Unknown"` | Active visual color palette and typography |
| `MatrixMode` | string | `"Letters"`, `"Binary"` | Character style for matrix rain animation |
| `MatrixDuration` | int | `1` – `5` | Duration of the matrix rain animation in seconds |
| `SecurityLoadSteps` | int | `1` – `12` | Number of segments in the animated security sequence |
| `GlitchIntensity` | int | `0` – `5` | Intensity of glitch text reveal effects |
| `ShowSystemInfo` | bool | `true`, `false` | Display Operator, Host, OS, and Uptime in dashboard |
| `ShowUsageBars` | bool | `true`, `false` | Render dynamic CPU and RAM usage bars |
| `ShowFullPath` | bool | `true`, `false` | Display full directory path or current folder name in prompt |
| `GradientText` | bool | `true`, `false` | Enable multi-color ANSI gradient on the logo banner |
| `SmartSuggestions` | bool | `true`, `false` | Enable predictive shell suggestions based on history |
| `StealthMode` | bool | `true`, `false` | Enable cyberpunk privacy cloaking on startup |
| `AnimationEnabled` | bool | `true`, `false` | Master toggle to enable or disable startup animations |
| `AutoCheckUpdates` | bool | `true`, `false` | Enable periodic background update checks |
| `SilentUpdate` | bool | `true`, `false` | Automatically download verified updates in background (default: `false`, opt-in) |
| `UpdateCheckDays` | int | `1`+ | Frequency of update checks in days |

---

## 🌍 Platform Parity

| Operating System | Shell | Native Telemetry Engine | Status |
|---|---|---|:---:|
| **Windows 10 / 11** | PowerShell 5.1+ / 7+ | Native Win32 & .NET Environment primitives | ✅ Full Support |
| **Linux (All Distros)** | Bash 4.0+ / Zsh | Dual-sample `/proc/stat` delta & `/proc/meminfo` | ✅ Full Support |
| **macOS (Intel & Apple Silicon)** | Bash / Zsh | Native `sysctl` & `vm_stat` hardware metrics | ✅ Full Support |
| **Termux (Android)** | Bash / Zsh | Calibrated `/proc/stat` delta & mobile auto-scaling | ✅ Full Support |

For detailed platform specifics and architecture, see [Platform Support Guide](docs/platforms.md). Comprehensive guides are available in the [docs/](docs/) directory:
- [Platform Support & Architecture](docs/platforms.md)
- [Configuration Guide](docs/configuration.md)
- [Installation Guide](docs/install.md)
- [Uninstallation Guide](docs/uninstall.md)
- [Troubleshooting & FAQ](docs/troubleshooting.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

---

## 📦 Manual Installation & Safe Removal

### Manual Setup
If you prefer not to use the automated one-line installer:

#### Windows (PowerShell)
```powershell
$dir = "$HOME\.phantom-terminal"
if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force }
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/PhantomStartup.ps1" -OutFile "$dir\PhantomStartup.ps1"

if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force }
Add-Content $PROFILE "`n# >>> Phantom Terminal START >>>`nif (Test-Path `"$dir\PhantomStartup.ps1`") { . `"$dir\PhantomStartup.ps1`" }`n# <<< Phantom Terminal END <<<"
```

#### Linux / macOS / Termux
```bash
mkdir -p ~/.phantom-terminal
curl -fsSL https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/PhantomStartup.sh -o ~/.phantom-terminal/PhantomStartup.sh
chmod +x ~/.phantom-terminal/PhantomStartup.sh

cat >> ~/.bashrc << 'EOF'

# >>> Phantom Terminal START >>>
if [ -f "$HOME/.phantom-terminal/PhantomStartup.sh" ]; then
    source "$HOME/.phantom-terminal/PhantomStartup.sh"
fi
# <<< Phantom Terminal END <<<
EOF
```

### Safe Profile Removal
Phantom Terminal safely isolates its startup hooks between explicit `# >>> Phantom Terminal START >>>` and `# <<< Phantom Terminal END <<<` delimiters. Uninstalling never touches your personal aliases, comments, or custom shell functions:

#### Windows (PowerShell)
```powershell
$p = Get-Content $PROFILE -Raw
$p -replace '(?s)# >>> Phantom Terminal START >>>.*?# <<< Phantom Terminal END <<<\r?\n?', '' | Set-Content $PROFILE
Remove-Item "$HOME\.phantom-terminal" -Recurse -Force -ErrorAction SilentlyContinue
```

#### Linux / macOS / Termux
```bash
sed -i.bak '/# >>> Phantom Terminal START >>>/,/# <<< Phantom Terminal END <<</d' ~/.bashrc ~/.zshrc 2>/dev/null || true
rm -rf ~/.phantom-terminal
```

---

## 📜 Changelog
All historical releases and changes are documented in [CHANGELOG.md](CHANGELOG.md). Detailed release notes for the current release are available in [v4.1.0 Release Notes](docs/changelogs/v4.1.0.md).

---

## 📄 License & Author

Distributed under the **MIT License**. Free for personal and commercial use.

- **Author:** [@unknownlll2829](https://t.me/unknownlll2829)
- **GitHub:** [@Unknown-2829](https://github.com/Unknown-2829)
- **Repository:** [Unknown-2829/Phantom-terminal](https://github.com/Unknown-2829/Phantom-terminal)
