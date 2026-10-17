# Troubleshooting & FAQ

## Common Issues & Solutions

### 1. Box characters look misaligned or broken
**Cause**: The current terminal font does not support Unicode box-drawing characters.
**Solution**:
- Install a modern font that includes full box-drawing glyphs, such as Cascadia Code, JetBrains Mono, Fira Code, or any Nerd Font.
- In Windows Terminal, ensure your font is set to `Cascadia Code` or `Consolas`.
- If your environment only supports ASCII, set `BOX_CHAR_BYTES=1` or run in an environment with UTF-8 locale enabled (`export LANG=en_US.UTF-8`).

### 2. Startup animation replays on every subshell / IDE terminal
**Cause**: Spawning subshells, tmux panes, or VS Code integrated terminals.
**Solution**:
- Phantom Terminal automatically exports `PHANTOM_SESSION_ACTIVE=1` to prevent animation loops.
- In nested shells, it bypasses the 5-second intro animation and displays only the compact dashboard.
- To replay the animation at any time, run `phantom-reload` (or `phantom-matrix`).

### 3. PowerShell 5.1 displays encoding or syntax errors
**Cause**: Windows PowerShell 5.1 requires files with Unicode characters to have a UTF-8 BOM (Byte Order Mark).
**Solution**:
- Ensure `PhantomStartup.ps1` and `install.ps1` are saved with UTF-8 BOM encoding.
- The official installer and repository files already include the UTF-8 BOM.

### 4. Bypassing Phantom Terminal in automated scripts & CI
**Cause**: Running automated test jobs, GitHub Actions, or AI coding agents.
**Solution**:
- Phantom Terminal automatically detects CI and agent environments (`CI=true`, `GITHUB_ACTIONS=true`, `CURSOR_AGENT`, `CLAUDE_AGENT`).
- To manually enforce silent execution, set:
  ```bash
  export PHANTOM_QUIET=1
  ```
- To force Phantom Terminal to execute even inside CI or non-interactive shells, set:
  ```bash
  export PHANTOM_FORCE=1
  ```

### 5. Permission denied during execution
**Cause**: Execute permissions missing on scripts.
**Solution**:
```bash
chmod +x ~/.phantom-terminal/PhantomStartup.sh
```
In PowerShell:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
