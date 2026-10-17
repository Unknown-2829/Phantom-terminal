# Configuration Guide

Phantom Terminal stores user configuration in JSON format:
- **PowerShell**: `$HOME/.phantom-terminal/config.json`
- **Bash / Linux / macOS**: `~/.phantom-terminal/config.json`

You can inspect settings at any time with `phantom-config` or edit them directly in your preferred editor with `phantom-config --edit`.

## Configuration Schema

```json
{
  "AnimationEnabled": true,
  "MatrixDuration": 2,
  "MatrixMode": "Letters",
  "SecurityLoadSteps": 8,
  "GlitchIntensity": 3,
  "ShowSystemInfo": true,
  "ShowUsageBars": true,
  "ShowFullPath": true,
  "GradientText": true,
  "StealthMode": false,
  "LiveStats": false,
  "SmartSuggestions": true,
  "Theme": "Phantom",
  "AutoCheckUpdates": true,
  "SilentUpdate": false,
  "UpdateCheckDays": 1
}
```

## Settings Reference

| Key | Type | Default | Description |
|---|---|---|---|
| `AnimationEnabled` | Boolean | `true` | Enables or disables the startup animation sequence. |
| `MatrixDuration` | Integer | `2` | Duration in seconds for the matrix rain animation. |
| `MatrixMode` | String | `"Letters"` | Characters used in matrix rain (`"Letters"` or `"Binary"`). |
| `SecurityLoadSteps` | Integer | `8` | Number of steps rendered in the security verification sequence. |
| `GlitchIntensity` | Integer | `3` | Number of glitch distortion passes during logo reveal. |
| `ShowSystemInfo` | Boolean | `true` | Displays hardware stats (OS, CPU, RAM, Uptime) in dashboard. |
| `ShowUsageBars` | Boolean | `true` | Renders ASCII/Unicode visual progress bars for CPU and RAM. |
| `ShowFullPath` | Boolean | `true` | Shows full path in prompt; `false` shows current folder name. |
| `GradientText` | Boolean | `true` | Applies multi-color gradient styling to banners and titles. |
| `StealthMode` | Boolean | `false` | Cloaks identity, hostname, system specs, and paths. |
| `LiveStats` | Boolean | `false` | Launches live interactive dashboard HUD by default. |
| `SmartSuggestions` | Boolean | `true` | Enables command predictor and history search. |
| `Theme` | String | `"Phantom"` | Active theme (`"Phantom"` or `"Unknown"`). |
| `AutoCheckUpdates` | Boolean | `true` | Checks for new releases in the background. |
| `SilentUpdate` | Boolean | `false` | Automatically downloads updates in background (Opt-in). |
| `UpdateCheckDays` | Integer | `1` | Interval in days between background update checks. |

## Themes

Phantom Terminal includes two built-in cyberpunk themes:
1. **Phantom**: Neon Cyan, Electric Blue, Bright White, and Gold accents.
2. **Unknown**: Hot Pink, Neon Purple, Blood Red, and Dark Gray accents.

Switch themes instantly with:
```bash
phantom-theme Unknown
# or
phantom-theme Phantom
```
