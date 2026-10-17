# Uninstallation Guide

Phantom Terminal is designed to be cleanly removable without leaving stray modifications in your environment.

## Quick Removal

### Bash (Linux / macOS / Termux)

1. Remove the Phantom Terminal block from your shell profile:
   Open your profile (e.g. `~/.bashrc` or `~/.zshrc`) and delete the lines between:
   ```bash
   # >>> Phantom Terminal START >>>
   ...
   # <<< Phantom Terminal END <<<
   ```

2. Remove the configuration directory:
   ```bash
   rm -rf ~/.phantom-terminal
   ```

3. Reload your shell profile:
   ```bash
   source ~/.bashrc  # or source ~/.zshrc
   ```

### PowerShell (Windows)

1. Open your PowerShell profile in your editor:
   ```powershell
   notepad $PROFILE
   ```
   Remove the lines between:
   ```powershell
   # >>> Phantom Terminal START >>>
   ...
   # <<< Phantom Terminal END <<<
   ```

2. Remove the Phantom configuration folder:
   ```powershell
   Remove-Item -Path "$HOME\.phantom-terminal" -Recurse -Force
   ```

3. Restart your PowerShell window.

## Automated Cleanup via Installer

Running `install.sh` or `install.ps1` automatically detects existing installations, cleans prior hooks, and replaces them cleanly.
