# Contributing to Phantom Terminal

Thank you for your interest in contributing to Phantom Terminal! 🎉

## 🐛 Bug Reports

1. Check [existing issues](https://github.com/Unknown-2829/Phantom-terminal/issues) first.
2. Open a new issue with:
   - Operating system and shell version (`pwsh -v`, `$PSVersionTable`, `bash --version`, `zsh --version`).
   - Terminal emulator (Windows Terminal, Alacritty, Kitty, iTerm2, tmux, etc.).
   - Exact steps to reproduce.
   - Expected vs actual behavior.

## 💡 Feature Requests

Open an issue with `[Feature]` in the title and describe:
- The problem or use-case you are addressing.
- Why zero-dependency native shell architecture is maintained.
- Proposed implementation details.

## 🔧 Pull Requests

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/my-feature`.
3. Make your changes in the relevant startup script(s): `PhantomStartup.ps1` and/or `PhantomStartup.sh`.
4. Ensure zero external dependencies are introduced (no Python, pip, sudo, or mandatory package requirements).
5. Run the test suites across PowerShell and Bash.
6. Commit with a descriptive message: `git commit -m "feat: description of change"`.
7. Push: `git push origin feature/my-feature`.
8. Open a Pull Request.

## 📝 Code Style & Guidelines

- **Zero External Dependencies**: Must run purely on native Windows PowerShell / POSIX Bash primitives.
- **Indentation**: 4 spaces across all `.ps1` and `.sh` files.
- **PowerShell 5.1 Parity**: All `.ps1` files must be saved with UTF-8 BOM (`utf-8-sig`) and maintain backward compatibility with Windows PowerShell 5.1 on Windows 10/11.
- **macOS & BSD Parity**: Bash scripts must avoid GNU-only flags (e.g. `sort -V`) and Bash 4+ constructs (e.g. `mapfile`, `declare -A`) to preserve compatibility with macOS default Bash 3.2.
- **Preserve Documentation Integrity**: Maintain existing comments and docstrings.

## 🧪 Testing

Before submitting a Pull Request, run the automated test engines:

### PowerShell Test Suite
```powershell
# Run in PowerShell Core (pwsh) or Windows PowerShell 5.1
pwsh -File tests/test_engine.ps1
# or
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/test_engine.ps1
```

### Bash Test Suite
```bash
# Run in Linux, macOS, or WSL
bash tests/test_engine.sh
```

### Syntax Validation
```bash
# Validate Bash syntax
bash -n PhantomStartup.sh
bash -n install.sh
bash -n tests/test_engine.sh
```

## 📄 License

By contributing, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).
