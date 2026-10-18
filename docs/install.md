# Installation Guide

Phantom Terminal features automated native installers with zero dependencies. No Python, pip, sudo, or package managers are needed.

## Quick Install

### Bash (Linux, macOS, Android Termux, BSD)

Using `curl`:
```bash
curl -fsSL https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.2.3/install.sh | bash
```

Using `wget`:
```bash
wget -qO- https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.2.3/install.sh | bash
```

### PowerShell (Windows, Linux, macOS)

In Windows PowerShell or PowerShell Core:
```powershell
irm https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.2.3/install.ps1 | iex
```

### 🛡️ Two-Step Checksum Verification

To verify download integrity against in-transit corruption or transfer errors prior to execution:

**Linux / Android Termux / BSD:**
```bash
curl -fsSLO https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.2.3/install.sh
curl -fsSLO https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.2.3/SHA256SUMS
grep "install.sh" SHA256SUMS | sha256sum -c - && bash install.sh
```

**macOS / BSD:**
```bash
curl -fsSLO https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.2.3/install.sh
curl -fsSLO https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.2.3/SHA256SUMS
grep "install.sh" SHA256SUMS | shasum -a 256 -c - && bash install.sh
```

**Windows PowerShell:**
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.2.3/install.ps1" -OutFile install.ps1
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.2.3/SHA256SUMS" -OutFile SHA256SUMS
$expected = (Get-Content SHA256SUMS | Where-Object { $_ -match '\s+install\.ps1$' } | ForEach-Object { ($_ -split '\s+')[0] })
if ((Get-FileHash install.ps1 -Algorithm SHA256).Hash.ToLower() -eq $expected.ToLower()) { .\install.ps1 } else { throw "Checksum mismatch" }
```

## Manual Installation

If you prefer to install manually or are working in an air-gapped environment:

1. Clone or download the repository:
   ```bash
   git clone https://github.com/Unknown-2829/Phantom-terminal.git
   cd Phantom-terminal
   ```

2. Run the local installer script:
   - **Bash**:
     ```bash
     bash install.sh
     ```
   - **PowerShell**:
     ```powershell
     .\install.ps1
     ```

## Automated / Headless Installation

To run in automated scripts or container build environments without interactive prompts:
```bash
CI=true bash install.sh
```
or in PowerShell:
```powershell
$env:CI = "true"; .\install.ps1
```

## What the Installer Does

1. Verifies your shell environment and creates the local configuration directory consistently at `~/.phantom-terminal/` (derived portably from `$HOME` across Windows, Linux, and macOS).
2. Deploys `PhantomStartup.sh` or `PhantomStartup.ps1` using fail-closed cryptographic verification and atomic staging to prevent installation corruption.
3. Initializes `config.json` with your chosen or default preferences.
4. Adds a cleanly delimited hook to your shell profile (`~/.bashrc`, `~/.zshrc`, or `$PROFILE`):
   - **Bash / Zsh**:
     ```bash
     # >>> Phantom Terminal START >>>
     if [ -n "${BASH_VERSION:-}" ] || [ -n "${ZSH_VERSION:-}" ]; then
         if [ -f "$HOME/.phantom-terminal/PhantomStartup.sh" ]; then
             . "$HOME/.phantom-terminal/PhantomStartup.sh"
         fi
     fi
     # <<< Phantom Terminal END <<<
     ```
   - **PowerShell**:
     ```powershell
     # >>> Phantom Terminal START >>>
     if (Test-Path "$HOME\.phantom-terminal\PhantomStartup.ps1") {
         . "$HOME\.phantom-terminal\PhantomStartup.ps1"
     }
     # <<< Phantom Terminal END <<<
     ```
5. Automatically creates a timestamped backup of your shell profile before modifying it.
