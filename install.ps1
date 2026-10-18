<#
.SYNOPSIS
    Phantom Terminal - Fast Native Installer v4.2.3
.DESCRIPTION
    High-performance installer with robust config persistence and profile safety.
    Run: irm https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.2.3/install.ps1 | iex
#>

# Fast init
$ErrorActionPreference = "Stop"
$InstallVersion = "4.2.3"
$InstallCodename = "Krypton"
$ReleaseTag = "v$InstallVersion"
$RepoUrl = "https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/$ReleaseTag"
$AssetUrl = if ($RepoUrl -like "*github*") { "https://github.com/Unknown-2829/Phantom-terminal/releases/download/$ReleaseTag" } else { $RepoUrl }
$ExpectedSha256 = "2505cf46365b856fc819985caa68c2310bcda2d1a37bc6aeb48b70e9e4d1d2bd"
$UserHome = if ($env:PHANTOM_HOME) { $env:PHANTOM_HOME } elseif ($env:UNKNOWN_HOME) { $env:UNKNOWN_HOME } elseif ($HOME) { $HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { [Environment]::GetFolderPath('UserProfile') }
$ConfigDir = Join-Path $UserHome ".phantom-terminal"
$InstallPath = Join-Path $ConfigDir "PhantomStartup.ps1"
$LegacyInstallPath = Join-Path $UserHome "PhantomStartup.ps1"
$ConfigFile = Join-Path $ConfigDir "config.json"

# ANSI Colors (cached)
$E = [char]27
$Purple = "$E[38;5;129m"; $Cyan = "$E[38;5;87m"; $Green = "$E[38;5;118m"
$Blue = "$E[38;5;39m"; $Gold = "$E[38;5;220m"; $Red = "$E[38;5;196m"
$White = "$E[1;37m"; $Gray = "$E[38;5;244m"; $DGray = "$E[38;5;240m"; $R = "$E[0m"

# Bracket indicators (prevents PS 5.1 array indexing parse ambiguity)
$b_star = "[*]"; $b_plus = "[+]"; $b_x = "[x]"
$b_1 = "[1]"; $b_2 = "[2]"; $b_3 = "[3]"; $b_4 = "[4]"
$b_14 = "[1/4]"; $b_24 = "[2/4]"; $b_34 = "[3/4]"; $b_44 = "[4/4]"

# Ensure config directory exists
if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
}

# Function to cleanly remove profile entries without destroying user comments
function Remove-PhantomProfileEntries {
    param([string]$ProfilePath)
    if (-not (Test-Path $ProfilePath)) { return }
    try {
        $content = Get-Content $ProfilePath -Raw
        if ($content -match '# >>> Phantom Terminal START >>>') {
            $content = $content -replace '(?s)# >>> Phantom Terminal START >>>.*?# <<< Phantom Terminal END <<<\r?\n?', ''
        }
        # Clean exact legacy v3 injection blocks
        if ($content -match '(?s)if\s*\(\s*Test-Path\s+["''][^"'']*PhantomStartup\.ps1["'']\s*\)\s*\{\s*\.\s*["''][^"'']*PhantomStartup\.ps1["'']\s*\}') {
            $content = $content -replace '(?s)if\s*\(\s*Test-Path\s+["''][^"'']*PhantomStartup\.ps1["'']\s*\)\s*\{\s*\.\s*["''][^"'']*PhantomStartup\.ps1["'']\s*\}\r?\n?', ''
        }
        $lines = $content -split "`r?`n" | Where-Object {
            $_ -notmatch '^\s*#\s*Phantom Terminal\s*$' -and
            $_ -notmatch '^\s*\.\s*["''][^"'']*PhantomStartup\.ps1["'']\s*$'
        }
        $lines -join "`r`n" | Set-Content $ProfilePath -Force -Encoding UTF8
    } catch {}
}

# Fast config load
$cfg = @{
    AnimationEnabled      = $true
    Theme                 = "Phantom"
    MatrixMode            = "Letters"
    ShowFullPath          = $true
    GradientText          = $true
    AutoCheckUpdates      = $true
    ShowSystemInfo        = $true
    SmartSuggestions      = $true
    StealthMode           = $false
    StealthMaskPath       = $false
    AIBypass              = $true
    AllowVSCodeAnimations = $true
    LiveStats             = $false
    ShowUsageBars         = $true
}

if (Test-Path $ConfigFile) {
    $rawContent = Get-Content $ConfigFile -Raw -ErrorAction SilentlyContinue
    if (-not [string]::IsNullOrWhiteSpace($rawContent)) {
        try {
            $json = $rawContent | ConvertFrom-Json -ErrorAction Stop
            if ($null -ne $json.AnimationEnabled) { $cfg.AnimationEnabled = [bool]$json.AnimationEnabled }
            if ($json.Theme) { $cfg.Theme = [string]$json.Theme }
            if ($json.MatrixMode) { $cfg.MatrixMode = [string]$json.MatrixMode }
            if ($null -ne $json.ShowFullPath) { $cfg.ShowFullPath = [bool]$json.ShowFullPath }
            if ($null -ne $json.GradientText) { $cfg.GradientText = [bool]$json.GradientText }
            if ($null -ne $json.AutoCheckUpdates) { $cfg.AutoCheckUpdates = [bool]$json.AutoCheckUpdates }
            if ($null -ne $json.ShowSystemInfo) { $cfg.ShowSystemInfo = [bool]$json.ShowSystemInfo }
            if ($null -ne $json.SmartSuggestions) { $cfg.SmartSuggestions = [bool]$json.SmartSuggestions }
            if ($null -ne $json.StealthMode) { $cfg.StealthMode = [bool]$json.StealthMode }
            if ($null -ne $json.StealthMaskPath) { $cfg.StealthMaskPath = [bool]$json.StealthMaskPath }
            if ($null -ne $json.AIBypass) { $cfg.AIBypass = [bool]$json.AIBypass }
            if ($null -ne $json.AllowVSCodeAnimations) { $cfg.AllowVSCodeAnimations = [bool]$json.AllowVSCodeAnimations }
            if ($null -ne $json.LiveStats) { $cfg.LiveStats = [bool]$json.LiveStats }
            if ($null -ne $json.ShowUsageBars) { $cfg.ShowUsageBars = [bool]$json.ShowUsageBars }
        } catch {
            $ts = Get-Date -Format "yyyyMMddHHmmss"
            $corruptBackup = "$ConfigFile.corrupt.$ts"
            try { Copy-Item -Path $ConfigFile -Destination $corruptBackup -Force } catch {}
            Write-Host "  $Red$b_x Warning: Malformed configuration detected. Backed up to $corruptBackup. Loading defaults.$R"
            Write-Host ""
        }
    }
}

# Header
$isInteractive = -not $env:CI -and -not $env:GITHUB_ACTIONS -and [Environment]::UserInteractive
if ($isInteractive) {
    try { Clear-Host } catch {}
}
Write-Host ""
$title = "PHANTOM TERMINAL INSTALLER v$InstallVersion `"$InstallCodename`""
$boxInner = 56
$titlePad = [Math]::Max(0, $boxInner - $title.Length)
$hl = [Math]::Floor($titlePad / 2)
$hr = $titlePad - $hl
$hLine = [string]::new([char]0x2550, $boxInner)
Write-Host "$Purple  $([char]0x2554)$hLine$([char]0x2557)$R"
Write-Host "$Purple  $([char]0x2551)$Cyan$(' ' * $hl)$title$(' ' * $hr)$Purple$([char]0x2551)$R"
Write-Host "$Purple  $([char]0x255A)$hLine$([char]0x255D)$R"
Write-Host ""

# Detect existing installation
$isReinstall = (Test-Path $InstallPath) -or (Test-Path $LegacyInstallPath)
if ($isReinstall) {
    Write-Host "  $Gold$b_star $Gray Detected existing installation (preserving active setup until verified)...$R"
    Write-Host ""
}

# Installation Mode Selection
$InstallMode = "1"
if ($isInteractive) {
    Write-Host "  $Gold$b_star INSTALLATION MODE:$R"
    Write-Host "  $Cyan$b_1 Express Install (Recommended)$R $Gray- Fast setup with defaults / preserved settings$R"
    Write-Host "  $Purple$b_2 Custom / Interactive Setup$R   $Gray- Step-by-step configuration wizard$R"
    Write-Host ""
    Write-Host "  Choice [Enter=1]: " -NoNewline
    $cMode = Read-Host
    if ($cMode -eq "2") { $InstallMode = "2" } else { $InstallMode = "1" }
    Write-Host ""
} else {
    $InstallMode = "1"
    Write-Host "  $Green$b_plus Running in non-interactive/Express mode with default configuration$R"
    Write-Host ""
}

if ($InstallMode -eq "2") {
    Write-Host "  $Gold─── CUSTOM CONFIGURATION WIZARD ───$R"; Write-Host ""

    # === THEME ===
    Write-Host "  $Gold$b_1 THEME$R"
    $d1 = if ($cfg.Theme -eq "Unknown") { "2" } else { "1" }
    Write-Host "  $Purple$b_1 Phantom$R  $Green$b_2 Unknown$R  $DGray(current: $($cfg.Theme))$R"
    Write-Host "  Choice [Enter=$d1]: " -NoNewline
    $c = Read-Host; if (-not $c) { $c = $d1 }
    $Theme = if ($c -eq "2") { "Unknown" } else { "Phantom" }
    Write-Host "  $Green→ $Theme$R"; Write-Host ""

    # === MATRIX ===
    Write-Host "  $Gold$b_2 MATRIX RAIN$R"
    $d2 = if ($cfg.MatrixMode -eq "Binary") { "2" } else { "1" }
    Write-Host "  $Cyan$b_1 Letters$R  $Green$b_2 Binary$R  $DGray(current: $($cfg.MatrixMode))$R"
    Write-Host "  Choice [Enter=$d2]: " -NoNewline
    $c = Read-Host; if (-not $c) { $c = $d2 }
    $MatrixMode = if ($c -eq "2") { "Binary" } else { "Letters" }
    Write-Host "  $Green→ $MatrixMode$R"; Write-Host ""

    # === PATH ===
    Write-Host "  $Gold$b_3 PROMPT PATH$R"
    $d3 = if ($cfg.ShowFullPath) { "1" } else { "2" }
    $currPathStr = if ($cfg.ShowFullPath) { "Full" } else { "Folder" }
    Write-Host "  $Cyan$b_1 Full path$R  $Blue$b_2 Folder only$R  $DGray(current: $currPathStr)$R"
    Write-Host "  Choice [Enter=$d3]: " -NoNewline
    $c = Read-Host; if (-not $c) { $c = $d3 }
    $ShowFullPath = $c -ne "2"
    $selPathStr = if ($ShowFullPath) { "Full path" } else { "Folder only" }
    Write-Host "  $Green→ $selPathStr$R"; Write-Host ""

    # === ANIMATIONS & VISUALS ===
    Write-Host "  $Gold$b_4 ANIMATIONS & VISUALS$R"
    $dAni = if ($cfg.AnimationEnabled -eq $false) { "n" } else { "Y" }
    Write-Host "  Enable startup animations? [Y/n, Enter=$dAni]: " -NoNewline
    $c = Read-Host; if (-not $c) { $c = $dAni }
    $AnimationEnabled = $c -ne "n" -and $c -ne "N"

    $dG = if ($cfg.GradientText) { "Y" } else { "n" }
    Write-Host "  Gradient logo? [Y/n, Enter=$dG]: " -NoNewline
    $c = Read-Host; if (-not $c) { $c = $dG }
    $GradientText = $c -ne "n" -and $c -ne "N"
    Write-Host ""

    # === AI GUARD & DEVELOPER SETTINGS ===
    Write-Host "  $Gold$b_1 AI GUARD & DEVELOPER SETTINGS$R"
    $dAI = if ($cfg.AIBypass -eq $false) { "n" } else { "Y" }
    Write-Host "  Auto-bypass in AI coding agents / CI? [Y/n, Enter=$dAI]: " -NoNewline
    $c = Read-Host; if (-not $c) { $c = $dAI }
    $AIBypass = $c -ne "n" -and $c -ne "N"

    $dVSC = if ($cfg.AllowVSCodeAnimations -eq $false) { "n" } else { "Y" }
    Write-Host "  Allow animations in VS Code terminal? [Y/n, Enter=$dVSC]: " -NoNewline
    $c = Read-Host; if (-not $c) { $c = $dVSC }
    $AllowVSCodeAnimations = $c -ne "n" -and $c -ne "N"
    Write-Host ""

    # === TELEMETRY & FEATURES ===
    Write-Host "  $Gold$b_2 TELEMETRY & FEATURES$R"
    $dS = if ($cfg.ShowSystemInfo -eq $false) { "n" } else { "Y" }
    Write-Host "  Show system info? [Y/n, Enter=$dS]: " -NoNewline
    $c = Read-Host; if (-not $c) { $c = $dS }
    $ShowSystemInfo = $c -ne "n" -and $c -ne "N"

    $dUB = if ($cfg.ShowUsageBars -eq $false) { "n" } else { "Y" }
    Write-Host "  Show real-time CPU & RAM usage bars? [Y/n, Enter=$dUB]: " -NoNewline
    $c = Read-Host; if (-not $c) { $c = $dUB }
    $ShowUsageBars = $c -ne "n" -and $c -ne "N"

    $dSS = if ($cfg.SmartSuggestions -eq $false) { "n" } else { "Y" }
    Write-Host "  Smart Suggestions? [Y/n, Enter=$dSS]: " -NoNewline
    $c = Read-Host; if (-not $c) { $c = $dSS }
    $SmartSuggestions = $c -ne "n" -and $c -ne "N"

    $dA = if ($cfg.AutoCheckUpdates) { "Y" } else { "n" }
    Write-Host "  Auto-update check? [Y/n, Enter=$dA]: " -NoNewline
    $c = Read-Host; if (-not $c) { $c = $dA }
    $AutoUpdate = $c -ne "n" -and $c -ne "N"
    Write-Host ""
} else {
    $AnimationEnabled = $cfg.AnimationEnabled
    $Theme = $cfg.Theme
    $MatrixMode = $cfg.MatrixMode
    $ShowFullPath = $cfg.ShowFullPath
    $GradientText = $cfg.GradientText
    $AIBypass = $cfg.AIBypass
    $AllowVSCodeAnimations = $cfg.AllowVSCodeAnimations
    $ShowSystemInfo = $cfg.ShowSystemInfo
    $ShowUsageBars = $cfg.ShowUsageBars
    $AutoUpdate = $cfg.AutoCheckUpdates
    $SmartSuggestions = $cfg.SmartSuggestions
    $pStr = if ($ShowFullPath) { "Full" } else { "Folder" }
    Write-Host "  $Green$b_plus Express mode active:$White Using configuration ($Theme | $MatrixMode | $pStr)$R"
    Write-Host ""
}

# === INSTALL ===
Write-Host "  $Gold═══ INSTALLING ═══$R"; Write-Host ""

# Dependencies Check (Zero mandatory external dependencies)
Write-Host "  $Cyan$b_14 $White Verifying zero-dependency environment...$R"
try {
    $psrl = Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    if ($psrl -and $psrl.Version -ge [version]"2.2.0") {
        Write-Host "  $Green$b_plus PSReadLine $($psrl.Version) detected (Predictive suggestions active)$R"
    } else {
        Write-Host "  $Green$b_plus Zero-dependency mode active (Native history & phantom-search ready)$R"
    }
} catch {
    Write-Host "  $Green$b_plus Native shell mode ready$R"
}

try {
    # File placement: check for local repo file first (offline / dev install)
    Write-Host "  $Cyan$b_24 $White Deploying PhantomStartup.ps1...$R"
    $localSource = $null
    if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "PhantomStartup.ps1"))) {
        $localSource = Join-Path $PSScriptRoot "PhantomStartup.ps1"
    } elseif (-not $PSScriptRoot -and (Test-Path ".\PhantomStartup.ps1")) {
        $localSource = (Resolve-Path ".\PhantomStartup.ps1").Path
    }

    if ($localSource) {
        # Isolated staging & AST syntax validation for local deployment
        $stageId = "$PID.$([Environment]::TickCount)"
        $stagePath = Join-Path $ConfigDir "PhantomStartup.ps1.stage.$stageId"
        Copy-Item -Path $localSource -Destination $stagePath -Force

        $rawLocal = Get-Content $stagePath -Raw -ErrorAction SilentlyContinue
        $parseErr = $null
        [void][System.Management.Automation.Language.Parser]::ParseInput($rawLocal, [ref]$null, [ref]$parseErr)
        if (-not $rawLocal -or $rawLocal.Length -lt 1000 -or ($rawLocal -notmatch 'PHANTOM') -or ($parseErr -and $parseErr.Count -gt 0)) {
            if (Test-Path $stagePath) { Remove-Item $stagePath -Force -ErrorAction SilentlyContinue }
            throw "Local PhantomStartup.ps1 failed integrity check (corrupted or invalid syntax). Aborting installation."
        }
        Move-Item -Path $stagePath -Destination $InstallPath -Force
        if (Test-Path $LegacyInstallPath) {
            Remove-Item $LegacyInstallPath -Force -ErrorAction SilentlyContinue
        }
        Write-Host "  $Green$b_plus Deployed and validated from local repository$R"
    } else {
        # Isolated transactional staging: NEVER touch active $InstallPath until download & verification pass
        $stageId = "$PID.$([Environment]::TickCount)"
        $stagePath = Join-Path $ConfigDir "PhantomStartup.ps1.stage.$stageId"
        $sumsFile = Join-Path $ConfigDir "SHA256SUMS.stage.$stageId"

        try {
            Invoke-WebRequest -Uri "$AssetUrl/PhantomStartup.ps1" -OutFile $stagePath -UseBasicParsing -TimeoutSec 30
        } catch {
            try {
                Invoke-WebRequest -Uri "$RepoUrl/PhantomStartup.ps1" -OutFile $stagePath -UseBasicParsing -TimeoutSec 30
            } catch {
                if (Test-Path $stagePath) { Remove-Item $stagePath -Force -ErrorAction SilentlyContinue }
                throw "Failed to download PhantomStartup.ps1 from $($ReleaseTag): $_"
            }
        }

        # Mandatory fail-closed SHA-256 release checksum verification
        $manifestHash = $null
        try {
            Invoke-WebRequest -Uri "$AssetUrl/SHA256SUMS" -OutFile $sumsFile -UseBasicParsing -TimeoutSec 15 -ErrorAction SilentlyContinue
        } catch {}
        if (-not (Test-Path $sumsFile) -or (Get-Item $sumsFile).Length -eq 0) {
            try {
                Invoke-WebRequest -Uri "$RepoUrl/SHA256SUMS" -OutFile $sumsFile -UseBasicParsing -TimeoutSec 15 -ErrorAction SilentlyContinue
            } catch {}
        }
        try {
            if (Test-Path $sumsFile) {
                $expectedLine = Get-Content $sumsFile -ErrorAction SilentlyContinue | Where-Object { $_ -match '\s+PhantomStartup\.ps1$' } | Select-Object -First 1
                if ($expectedLine) {
                    $manifestHash = ($expectedLine -split '\s+')[0].Trim().ToLower()
                }
                Remove-Item $sumsFile -Force -ErrorAction SilentlyContinue
            }
        } catch {
            # Manifest parsing failed
        }

        # Strict fail-closed verification: manifest MUST exist and contain target hash
        if (-not $manifestHash -or $manifestHash -notmatch '^[a-f0-9]{64}$') {
            if (Test-Path $stagePath) { Remove-Item $stagePath -Force -ErrorAction SilentlyContinue }
            throw "Security verification failed: SHA256SUMS release manifest is missing, invalid, or does not contain PhantomStartup.ps1. Aborting for security."
        }

        # Manifest hash MUST match embedded root-of-trust digest
        if ($ExpectedSha256 -and ($manifestHash -ne $ExpectedSha256)) {
            if (Test-Path $stagePath) { Remove-Item $stagePath -Force -ErrorAction SilentlyContinue }
            throw "Security verification failed: Manifest checksum does not match embedded root-of-trust digest."
        }

        $expectedHash = $manifestHash
        $actualHash = (Get-FileHash -Path $stagePath -Algorithm SHA256).Hash.ToLower()
        if ($actualHash -ne $expectedHash) {
            if (Test-Path $stagePath) { Remove-Item $stagePath -Force -ErrorAction SilentlyContinue }
            throw "Security verification failed: SHA-256 checksum mismatch for PhantomStartup.ps1 (expected: $expectedHash, got: $actualHash)."
        }

        $rawDownloaded = Get-Content $stagePath -Raw -ErrorAction SilentlyContinue
        $parseErr = $null
        [void][System.Management.Automation.Language.Parser]::ParseInput($rawDownloaded, [ref]$null, [ref]$parseErr)
        if (-not $rawDownloaded -or $rawDownloaded.Length -lt 1000 -or ($rawDownloaded -notmatch 'PHANTOM') -or ($parseErr -and $parseErr.Count -gt 0)) {
            if (Test-Path $stagePath) { Remove-Item $stagePath -Force -ErrorAction SilentlyContinue }
            throw "Downloaded PhantomStartup.ps1 failed integrity check (corrupted or invalid syntax)."
        }

        # Staging passed all checks: promote staged file to active destination atomically
        Move-Item -Path $stagePath -Destination $InstallPath -Force
        if (Test-Path $LegacyInstallPath) {
            Remove-Item $LegacyInstallPath -Force -ErrorAction SilentlyContinue
        }
        Write-Host "  $Green$b_plus Downloaded from $ReleaseTag and verified SHA-256 integrity$R"
    }

    # Profile integration with explicit start and end boundary markers (executed ONLY after engine is validated)
    Write-Host "  $Cyan$b_34 $White Configuring Profile...$R"
    $targetProfile = if ($env:PHANTOM_PROFILE) { $env:PHANTOM_PROFILE } elseif ($env:UNKNOWN_PROFILE) { $env:UNKNOWN_PROFILE } else { $PROFILE }
    $profileDir = Split-Path -Parent $targetProfile
    if ($profileDir -and !(Test-Path $profileDir)) {
        New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
    }
    if (!(Test-Path $targetProfile)) {
        New-Item -Path $targetProfile -ItemType File -Force | Out-Null
    }

    # Backup profile before modifying
    $backupTs = (Get-Date).ToString("yyyyMMddHHmmss")
    Copy-Item -Path $targetProfile -Destination "$targetProfile.phantom-backup.$backupTs" -Force -ErrorAction SilentlyContinue

    Remove-PhantomProfileEntries -ProfilePath $targetProfile

    $profileBlock = @"

# >>> Phantom Terminal START >>>
if (Test-Path "$InstallPath") {
    . "$InstallPath"
}
# <<< Phantom Terminal END <<<
"@
    try {
        Add-Content -Path $targetProfile -Value $profileBlock -Encoding UTF8 -ErrorAction Stop
        $profileContent = Get-Content -Path $targetProfile -Raw -ErrorAction Stop
        if ($profileContent -notmatch '# >>> Phantom Terminal START >>>') {
            throw "Verification failed: Startup block missing from $targetProfile."
        }
        Write-Host "  $Green$b_plus Profile configured safely$R"
    } catch {
        throw "Failed to configure PowerShell profile at $($targetProfile): $_"
    }

    # Config
    Write-Host "  $Cyan$b_44 $White Saving Config...$R"
    $config = [ordered]@{
        AnimationEnabled      = $AnimationEnabled
        MatrixDuration        = 2
        MatrixMode            = $MatrixMode
        SecurityLoadSteps     = 8
        GlitchIntensity       = 3
        ShowSystemInfo        = $ShowSystemInfo
        ShowFullPath          = $ShowFullPath
        GradientText          = $GradientText
        SmartSuggestions      = $SmartSuggestions
        Theme                 = $Theme
        AutoCheckUpdates      = $AutoUpdate
        SilentUpdate          = $false
        UpdateCheckDays       = 1
        StealthMode           = $cfg.StealthMode
        StealthMaskPath       = $cfg.StealthMaskPath
        AIBypass              = $AIBypass
        AllowVSCodeAnimations = $AllowVSCodeAnimations
        LiveStats             = $cfg.LiveStats
        ShowUsageBars         = $ShowUsageBars
    }
    $config | ConvertTo-Json -Depth 3 | Out-File $ConfigFile -Encoding UTF8 -Force
    Write-Host "  $Green$b_plus Config saved to $ConfigFile$R"

    # Initialize cache for fresh installs (so upgrade modal is NOT shown on new installs)
    $cacheFile = Join-Path $ConfigDir "cache.json"
    if (-not (Test-Path $cacheFile)) {
        $nowEpoch = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        $initCache = [ordered]@{
            LastUpdateCheck  = $nowEpoch
            LatestVersion    = $InstallVersion
            UpdateAvailable  = $false
            UpdateDownloaded = $false
            LastSeenVersion  = $InstallVersion
        }
        $initCache | ConvertTo-Json | Out-File $cacheFile -Encoding UTF8 -Force
    }

    Write-Host ""
    $cTitle = "INSTALLATION COMPLETE! (v$InstallVersion `"$InstallCodename`")"
    $cInner = 52
    $cPad = [Math]::Max(0, $cInner - $cTitle.Length)
    $cLeft = [Math]::Floor($cPad / 2)
    $cRight = $cPad - $cLeft
    $cHLine = [string]::new([char]0x2550, $cInner)
    Write-Host "  $Green$([char]0x2554)$cHLine$([char]0x2557)$R"
    Write-Host "  $Green$([char]0x2551)$White$(' ' * $cLeft)$cTitle$(' ' * $cRight)$Green$([char]0x2551)$R"
    Write-Host "  $Green$([char]0x255A)$cHLine$([char]0x255D)$R"
    Write-Host ""
    Write-Host "  $Cyan Restart terminal or run: $White . `"$InstallPath`"$R"
    Write-Host ""
    $finalPathStr = if ($ShowFullPath) { "Full" } else { "Folder" }
    Write-Host "  $Gold Settings: $White $Theme | $MatrixMode | $finalPathStr$R"
    $cmdPrefix = if ($Theme -eq "Unknown") { "unknown" } else { "phantom" }
    Write-Host "  $Gold Commands: $White $cmdPrefix-help | $cmdPrefix-dash -Live | $cmdPrefix-stealth | $cmdPrefix-search$R"
    Write-Host ""

} catch {
    Write-Host "  $Red$b_x Installation failed: $_$R"
    exit 1
}
