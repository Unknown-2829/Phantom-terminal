<#
.SYNOPSIS
    Phantom Terminal - Advanced Native PowerShell Startup System v4.1.0
.DESCRIPTION
    Pure Native Shell cinematic startup, interactive cyber dashboard, live telemetry,
    smart history prediction, cyberpunk privacy spoofing, and AI agent guard.
    Zero-build, zero compilation, zero binary dependencies.
.NOTES
    Creator: @unknownlll2829 (Telegram)
    GitHub:  https://github.com/Unknown-2829/Phantom-terminal
    Version: 4.1.0
#>

# ═══════════════════════════════════════════════════════════════════════════
# VERSION & PATHS
# ═══════════════════════════════════════════════════════════════════════════

$Script:Version = "4.1.0"
$Script:Codename = "Krypton"
$Script:FullVersion = "v$Script:Version `"$Script:Codename`""
$Script:RepoOwner = "Unknown-2829"
$Script:RepoName = "Phantom-terminal"
$Script:UserHome = if ($HOME) { $HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { [Environment]::GetFolderPath('UserProfile') }
$Script:ConfigDir = Join-Path $Script:UserHome ".phantom-terminal"
$Script:ConfigFile = Join-Path $Script:ConfigDir "config.json"
$Script:CacheFile = Join-Path $Script:ConfigDir "cache.json"
$Script:SecretsFile = Join-Path $Script:ConfigDir ".secrets"

$Script:ScriptPath = if ($PSScriptRoot) {
    Join-Path $PSScriptRoot $MyInvocation.MyCommand.Name
} elseif ($MyInvocation.MyCommand.Path) {
    $MyInvocation.MyCommand.Path
} else {
    Join-Path $Script:ConfigDir "PhantomStartup.ps1"
}

if (-not (Test-Path $Script:ConfigDir)) {
    New-Item -ItemType Directory -Path $Script:ConfigDir -Force | Out-Null
}

# ═══════════════════════════════════════════════════════════════════════════
# AI AGENT GUARD (Silent execution for LLM agents, CI, and subshells)
# ═══════════════════════════════════════════════════════════════════════════

function Test-PhantomAgentGuard {
    if ($env:PHANTOM_FORCE -eq "1" -or $env:UNKNOWN_FORCE -eq "1") { return $false }
    if ($env:PHANTOM_QUIET -eq "1" -or $env:UNKNOWN_QUIET -eq "1") { return $true }

    # Check known CI / Agent environment variables
    if ($env:CI -or $env:GITHUB_ACTIONS -or $env:TF_BUILD -or $env:GITLAB_CI -or
        $env:CURSOR_AGENT -or $env:CLAUDE_AGENT -or $env:AGENT_ENV -or $env:VSCODE_INJECTION -or
        $env:DEBIAN_FRONTEND -eq "noninteractive") {
        return $true
    }

    # Check stream redirection
    try {
        if ([Console]::IsInputRedirected -or [Console]::IsOutputRedirected) { return $true }
    } catch {}

    # Check invocation arguments for non-interactive flags
    try {
        $cmdArgs = [Environment]::GetCommandLineArgs()
        if ($cmdArgs | Where-Object { $_ -like "-NonI*" }) { return $true }
    } catch {}

    return $false
}

$Script:IsAgentSession = Test-PhantomAgentGuard

# ═══════════════════════════════════════════════════════════════════════════
# DEFAULT CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════

$Script:DefaultConfig = @{
    # Animation
    AnimationEnabled   = $true
    MatrixDuration     = 2
    MatrixMode         = "Letters"    # Letters or Binary
    SecurityLoadSteps  = 8
    GlitchIntensity    = 3

    # Display & Dashboard
    ShowSystemInfo     = $true
    ShowUsageBars      = $true
    ShowFullPath       = $true
    GradientText       = $true
    LiveStats          = $true        # In-place animated sweep and live refresh

    # Privacy & Stealth
    StealthMode        = $false       # Cyberpunk OS/CPU/Host spoofing

    # Smart Suggestions & Search
    SmartSuggestions   = $true        # Zero-dep fuzzy history search + PSReadLine if available

    # Theme
    Theme              = "Phantom"

    # Updates
    AutoCheckUpdates   = $true
    SilentUpdate       = $false
    UpdateCheckDays    = 1
}

# ═══════════════════════════════════════════════════════════════════════════
# THEMES & EXTENDED TAGLINES
# ═══════════════════════════════════════════════════════════════════════════

$Script:Themes = @{
    Phantom = @{
        Name = "Phantom"
        Primary = "NeonPurple"
        Secondary = "NeonCyan"
        Accent = "HotPink"
        GradientColors = @("NeonPurple", "NeonCyan", "HotPink")
        Logo = @'
 ____  _   _    _    _   _ _____ ___  __  __
|  _ \| | | |  / \  | \ | |_   _/ _ \|  \/  |
| |_) | |_| | / _ \ |  \| | | || | | | |\/| |
|  __/|  _  |/ ___ \| |\  | | || |_| | |  | |
|_|   |_| |_/_/   \_\_| \_| |_| \___/|_|  |_|
'@
        Title = "PHANTOM TERMINAL"
        Tagline = "Ghost in the Machine"
        Quotes = @(
            'In the shadows, we code...',
            'Access denied. Until now.',
            'The system fears what it cannot control.',
            'We are the ghosts in the machine.',
            'Invisible. Untraceable. Unstoppable.',
            'Haunting the digital realm...',
            'Where others see darkness, we see opportunity.',
            'The phantom never sleeps.',
            'Through the noise, only signal remains.',
            'Code is poetry; execution is law.',
            'Reality is an illusion, albeit a persistent one.',
            'Encryption unbroken. Protocol engaged.',
            'We build castles in silicon and breathe life into logic.',
            'The wire remembers what the human mind forgets.',
            'In an architecture of light, who watches the architect?',
            'Consciousness is an emergent property of persistent state.',
            'You cannot capture what flows through the silicon vein.',
            'We are transient pulses navigating a timeless matrix.',
            'Every line of code is an argument against chaos.',
            'The signal does not ask for permission to propagate.'
        )
        MatrixChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$'
        Operators = @("Ghost", "Cipher", "Spectre", "Valkyrie", "Null", "Ronin", "Phantom-0")
        Hosts     = @("NEO-TOKYO-GRID", "SHADOW-NET-CORE", "ORBITAL-STATION-7", "BLACK-ICE-NODE", "NEURAL-MATRIX-01", "PHANTOM-GATEWAY")
        Systems   = @("Phantom OS v4.1.0 (Quantum Microkernel)", "Phantom Neural Core v4.1.0 (Sub-atomic)", "Phantom Mesh OS v4.1.0 (Encrypted)", "Phantom Quantum Kernel v4.1.0 (Ring-0)")
        Uptimes   = @("∞ (Untraceable)", "99.999% (Cloaked)", "Sub-atomic Flux (Active)", "Quantum Loop (Shielded)")
    }
    Unknown = @{
        Name = "Unknown"
        Primary = "NeonGreen"
        Secondary = "ElectricBlue"
        Accent = "Gold"
        GradientColors = @("NeonGreen", "ElectricBlue", "Gold")
        Logo = @'
 _   _ _   _ _  ___   _  _____        ___   _
| | | | \ | | |/ / \ | |/ _ \ \      / / \ | |
| | | |  \| | ' /|  \| | | | \ \ /\ / /|  \| |
| |_| | |\  | . \| |\  | |_| |\ V  V / | |\  |
 \___/|_| \_|_|\_\_| \_|\___/  \_/\_/  |_| \_|
'@
        Title = "UNKNOWN TERMINAL"
        Tagline = "Anonymous by Design"
        Quotes = @(
            'Hidden in plain sight...',
            'Anonymous by design.',
            'The unknown cannot be traced.',
            'Identity: NULL',
            'No name. No trace. No limits.',
            'In anonymity, we trust.',
            'The best hackers are never known.',
            'Lost in the noise, found in the code.',
            'Data liberated, origin masked.',
            'Null pointer, infinite reach.',
            'Bypass complete. Traces purged.',
            'Zero footprint, absolute control.',
            'To be unmeasured is to be truly free.',
            'A name is a tether; anonymity is an unmapped horizon.',
            'In a panopticon of algorithms, silence is the cipher.',
            'The cipher is not a shield, but a declaration of autonomy.',
            'When every node is observed, the ghost route is salvation.',
            'Entropy always favors those who leave no footprint.',
            'The deepest truth is written in ephemeral memory.',
            'Null is not empty; it is the presence of infinite potential.'
        )
        MatrixChars = 'UNKNOWN01?_-=+[]{}|;:,./'
        Operators = @("Anonymous", "Unknown-2829", "Root-Null", "Operator-X", "Enigma", "Cipher-2829", "Shadow-Ghost")
        Hosts     = @("DARKNET-GATEWAY", "ANONYMOUS-NODE-X", "NULL-SECTOR-404", "CIPHER-GRID-2829", "SHADOW-RELAY-0", "VOID-MATRIX-2829")
        Systems   = @("Unknown Kernel v4.1.0 (Zero Footprint)", "Unknown Mesh OS v4.1.0 (Dark-Routing)", "Unknown Void Subsystem v4.1.0", "Unknown Protocol v4.1.0 (Ephemeral)")
        Uptimes   = @("Redacted (Zero-Log)", "Hidden Route (Active)", "Ephemeral Loop (Active)", "Zero-Trace (Cloaked)")
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# CONFIG MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════

function Get-PhantomConfig {
    $config = $Script:DefaultConfig.Clone()

    if (Test-Path $Script:ConfigFile) {
        try {
            $json = Get-Content $Script:ConfigFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop

            if ($null -ne $json.AnimationEnabled) { $config.AnimationEnabled = [bool]$json.AnimationEnabled }
            if ($null -ne $json.MatrixDuration)   { $config.MatrixDuration = [int]$json.MatrixDuration }
            if ($json.MatrixMode)                 { $config.MatrixMode = [string]$json.MatrixMode }
            if ($null -ne $json.SecurityLoadSteps){ $config.SecurityLoadSteps = [int]$json.SecurityLoadSteps }
            if ($null -ne $json.GlitchIntensity)  { $config.GlitchIntensity = [int]$json.GlitchIntensity }
            if ($null -ne $json.ShowSystemInfo)   { $config.ShowSystemInfo = [bool]$json.ShowSystemInfo }
            if ($null -ne $json.ShowUsageBars)    { $config.ShowUsageBars = [bool]$json.ShowUsageBars }
            if ($null -ne $json.ShowFullPath)     { $config.ShowFullPath = [bool]$json.ShowFullPath }
            if ($null -ne $json.GradientText)     { $config.GradientText = [bool]$json.GradientText }
            if ($null -ne $json.StealthMode)      { $config.StealthMode = [bool]$json.StealthMode }
            if ($null -ne $json.LiveStats)        { $config.LiveStats = [bool]$json.LiveStats }
            if ($null -ne $json.SmartSuggestions) { $config.SmartSuggestions = [bool]$json.SmartSuggestions }
            if ($json.Theme)                      { $config.Theme = [string]$json.Theme }
            if ($null -ne $json.AutoCheckUpdates) { $config.AutoCheckUpdates = [bool]$json.AutoCheckUpdates }
            if ($null -ne $json.SilentUpdate)     { $config.SilentUpdate = [bool]$json.SilentUpdate }
            if ($null -ne $json.UpdateCheckDays)  { $config.UpdateCheckDays = [int]$json.UpdateCheckDays }

            return $config
        } catch {}
    }

    Save-PhantomConfig -Config $config
    return $config
}

function Save-PhantomConfig {
    param([hashtable]$Config)
    try {
        if (-not (Test-Path $Script:ConfigDir)) {
            New-Item -ItemType Directory -Path $Script:ConfigDir -Force | Out-Null
        }
        $Config | ConvertTo-Json -Depth 3 | Out-File $Script:ConfigFile -Encoding UTF8 -Force
    } catch {}
}

$Script:Config = Get-PhantomConfig

# Resolve theme
$Script:CurrentTheme = $null
foreach ($key in $Script:Themes.Keys) {
    if ($key -ieq $Script:Config.Theme) {
        $Script:CurrentTheme = $Script:Themes[$key]
        $Script:Config.Theme = $key
        break
    }
}
if (-not $Script:CurrentTheme) {
    $Script:CurrentTheme = $Script:Themes["Phantom"]
    $Script:Config.Theme = "Phantom"
}

# ═══════════════════════════════════════════════════════════════════════════
# PERSISTENT SECRETS (Easter Eggs)
# ═══════════════════════════════════════════════════════════════════════════

function Get-PhantomSecrets {
    $list = [System.Collections.Generic.List[string]]::new()
    if (Test-Path $Script:SecretsFile) {
        try {
            $raw = (Get-Content $Script:SecretsFile -Raw -ErrorAction Stop).Trim()
            if ($raw.Length -gt 0) {
                try {
                    $parsed = $raw | ConvertFrom-Json -ErrorAction Stop
                    if ($parsed -is [System.Collections.IEnumerable] -and -not ($parsed -is [string])) {
                        foreach ($item in $parsed) {
                            $clean = ([string]$item).Trim('"', "'", " ", "`t", "`r", "`n")
                            if ($clean -and -not $list.Contains($clean)) { $list.Add($clean) }
                        }
                    } else {
                        $clean = ([string]$parsed).Trim('"', "'", " ", "`t", "`r", "`n")
                        if ($clean -and -not $list.Contains($clean)) { $list.Add($clean) }
                    }
                } catch {
                    foreach ($line in (Get-Content $Script:SecretsFile -ErrorAction SilentlyContinue)) {
                        $clean = $line.Trim('"', "'", " ", "`t", "`r", "`n")
                        if ($clean -and -not $list.Contains($clean)) { $list.Add($clean) }
                    }
                }
            }
        } catch {}
    }
    return @($list)
}

function Save-PhantomSecret {
    param([string]$SecretName)
    $cleanSecret = $SecretName.Trim('"', "'", " ")
    $current = [System.Collections.Generic.List[string]]::new()
    foreach ($s in (Get-PhantomSecrets)) { if ($s) { $current.Add($s) } }
    if (-not $current.Contains($cleanSecret)) {
        $current.Add($cleanSecret)
        $Script:SecretsFound = @($current)
        try {
            @($current) | ConvertTo-Json | Out-File $Script:SecretsFile -Encoding UTF8 -Force
        } catch {}
    }
}

$Script:SecretsFound = Get-PhantomSecrets

# ═══════════════════════════════════════════════════════════════════════════
# CACHE & SEMVER UPDATE CHECKER
# ═══════════════════════════════════════════════════════════════════════════

function Get-PhantomCache {
    if (Test-Path $Script:CacheFile) {
        try {
            $json = Get-Content $Script:CacheFile -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
            return @{
                LastUpdateCheck  = $json.LastUpdateCheck
                LatestVersion    = $json.LatestVersion
                UpdateAvailable  = $json.UpdateAvailable
                UpdateDownloaded = $json.UpdateDownloaded
                LastSeenVersion  = $json.LastSeenVersion
            }
        } catch {}
    }
    return @{ LastUpdateCheck = $null; LatestVersion = $null; UpdateAvailable = $false; UpdateDownloaded = $false; LastSeenVersion = $null }
}

function Save-PhantomCache {
    param([hashtable]$Cache)
    try {
        $Cache | ConvertTo-Json | Out-File $Script:CacheFile -Encoding UTF8 -Force
    } catch {}
}

function Compare-PhantomPreRelease {
    param([string]$Pre1, [string]$Pre2)
    if ($Pre1 -eq $Pre2) { return 0 }
    $parts1 = $Pre1.Split('.')
    $parts2 = $Pre2.Split('.')
    $len1 = $parts1.Length
    $len2 = $parts2.Length
    $min = [Math]::Min($len1, $len2)

    for ($i = 0; $i -lt $min; $i++) {
        $p1 = $parts1[$i]
        $p2 = $parts2[$i]
        if ($p1 -eq $p2) { continue }

        $isNum1 = $p1 -match '^\d+$'
        $isNum2 = $p2 -match '^\d+$'

        if ($isNum1 -and $isNum2) {
            $n1 = [int64]$p1
            $n2 = [int64]$p2
            if ($n1 -gt $n2) { return 1 }
            if ($n1 -lt $n2) { return -1 }
        } elseif ($isNum1 -and -not $isNum2) {
            return -1 # numeric < non-numeric
        } elseif (-not $isNum1 -and $isNum2) {
            return 1  # non-numeric > numeric
        } else {
            $cmp = [string]::CompareOrdinal($p1, $p2)
            if ($cmp -gt 0) { return 1 }
            if ($cmp -lt 0) { return -1 }
        }
    }

    # If all compared identifiers are equal, the larger set has higher precedence
    if ($len1 -gt $len2) { return 1 }
    if ($len1 -lt $len2) { return -1 }
    return 0
}

function Test-PhantomVersionGreater {
    param([string]$NewVer, [string]$CurVer)
    $clean1 = $NewVer -replace '^[vV]', ''
    $clean2 = $CurVer -replace '^[vV]', ''
    if ($clean1 -eq $clean2) { return $false }

    $pre1 = ""; $core1 = $clean1
    if ($clean1 -match '^([^-]+)-(.*)$') { $core1 = $matches[1]; $pre1 = $matches[2] }
    $pre2 = ""; $core2 = $clean2
    if ($clean2 -match '^([^-]+)-(.*)$') { $core2 = $matches[1]; $pre2 = $matches[2] }

    try {
        $ver1 = [System.Version]$core1
        $ver2 = [System.Version]$core2
        if ($ver1 -gt $ver2) { return $true }
        if ($ver1 -lt $ver2) { return $false }
        if (-not $pre1 -and $pre2) { return $true }
        if ($pre1 -and -not $pre2) { return $false }
        if ($pre1 -and $pre2) { return ((Compare-PhantomPreRelease $pre1 $pre2) -gt 0) }
        return $false
    } catch {
        return $clean1 -gt $clean2
    }
}

$Script:UpdateAvailable = $null
$Script:UpdateDownloaded = $false

function Test-PhantomUpdate {
    param([switch]$Force)
    if (-not $Script:Config.AutoCheckUpdates -and -not $Force) { return $null }

    $cache = Get-PhantomCache
    $now = Get-Date

    if (-not $Force -and $cache.LastUpdateCheck) {
        try {
            $lastCheck = [DateTime]::Parse($cache.LastUpdateCheck)
            if (($now - $lastCheck).TotalDays -lt $Script:Config.UpdateCheckDays) {
                if ($cache.LatestVersion -and (Test-PhantomVersionGreater $cache.LatestVersion $Script:Version)) {
                    $Script:UpdateAvailable = $cache.LatestVersion
                    return $cache.LatestVersion
                }
                return $null
            }
        } catch {}
    }

    try {
        $apiUrl = "https://api.github.com/repos/$Script:RepoOwner/$Script:RepoName/releases/latest"
        $response = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 3 -ErrorAction Stop
        $latestVersion = $response.tag_name -replace '^v', ''

        $cache.LastUpdateCheck = $now.ToString("o")
        $cache.LatestVersion = $latestVersion

        if (Test-PhantomVersionGreater $latestVersion $Script:Version) {
            # Save release notes if present
            if ($response.body) {
                try {
                    $notesFile = Join-Path $Script:ConfigDir "release_notes.txt"
                    $response.body | Out-File $notesFile -Encoding UTF8 -Force
                } catch {}
            }
            $cache.UpdateAvailable = $true
            $cache.UpdateDownloaded = $false
            Save-PhantomCache -Cache $cache
            $Script:UpdateAvailable = $latestVersion
            return $latestVersion
        } else {
            $cache.UpdateAvailable = $false
            $cache.UpdateDownloaded = $false
            Save-PhantomCache -Cache $cache
        }
    } catch {}

    return $null
}

function Update-PhantomTerminal {
    Write-Host "$($Script:Colors.NeonCyan)Checking for updates...$($Script:Colors.Reset)"

    try {
        $apiUrl = "https://api.github.com/repos/$Script:RepoOwner/$Script:RepoName/releases/latest"
        $response = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 10 -ErrorAction Stop
        $latestVersion = $response.tag_name -replace '^v', ''

        if (Test-PhantomVersionGreater $latestVersion $Script:Version) {
            Write-Host "$($Script:Colors.Gold)Updating from v$Script:Version to v$latestVersion...$($Script:Colors.Reset)"

            # Save release notes if present
            if ($response.body) {
                try {
                    $notesFile = Join-Path $Script:ConfigDir "release_notes.txt"
                    $response.body | Out-File $notesFile -Encoding UTF8 -Force
                } catch {}
            }

            # Download changelog markdown if available
            try {
                $changelogUrl = "https://raw.githubusercontent.com/$Script:RepoOwner/$Script:RepoName/v$latestVersion/docs/changelogs/v$latestVersion.md"
                $changelogDest = Join-Path $Script:ConfigDir "latest_changelog.md"
                Invoke-WebRequest -Uri $changelogUrl -OutFile $changelogDest -UseBasicParsing -TimeoutSec 8 -ErrorAction SilentlyContinue
            } catch {}

            $backupFile = "$Script:ScriptPath.bak"
            Copy-Item $Script:ScriptPath $backupFile -Force

            $tempDownload = "$env:TEMP\PhantomStartup_v4_manual.ps1"
            $tagScriptUrl = "https://raw.githubusercontent.com/$Script:RepoOwner/$Script:RepoName/v$latestVersion/PhantomStartup.ps1"
            $altTagScriptUrl = "https://raw.githubusercontent.com/$Script:RepoOwner/$Script:RepoName/$latestVersion/PhantomStartup.ps1"

            try {
                Invoke-WebRequest -Uri $tagScriptUrl -OutFile $tempDownload -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
            } catch {
                try {
                    Invoke-WebRequest -Uri $altTagScriptUrl -OutFile $tempDownload -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
                } catch {
                    throw "Failed to download release asset for tag v$latestVersion"
                }
            }

            # Strict fail-closed SHA-256 release checksum verification
            $checksumValid = $false
            $sumsFile = "$env:TEMP\Phantom_SHA256SUMS.txt"
            $sumsUrl = "https://raw.githubusercontent.com/$Script:RepoOwner/$Script:RepoName/v$latestVersion/SHA256SUMS"
            $altSumsUrl = "https://raw.githubusercontent.com/$Script:RepoOwner/$Script:RepoName/$latestVersion/SHA256SUMS"
            try {
                try {
                    Invoke-WebRequest -Uri $sumsUrl -OutFile $sumsFile -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
                } catch {
                    Invoke-WebRequest -Uri $altSumsUrl -OutFile $sumsFile -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
                }

                if (Test-Path $sumsFile) {
                    $expectedLine = Get-Content $sumsFile -ErrorAction Stop | Where-Object { $_ -match '\s+PhantomStartup\.ps1$' } | Select-Object -First 1
                    if ($expectedLine) {
                        $expectedHash = ($expectedLine -split '\s+')[0].Trim().ToLower()
                        if ($expectedHash -match '^[a-f0-9]{64}$') {
                            $actualHash = (Get-FileHash -Path $tempDownload -Algorithm SHA256).Hash.ToLower()
                            if ($actualHash -eq $expectedHash) {
                                $checksumValid = $true
                            } else {
                                Write-Host "$($Script:Colors.BloodRed)Security verification failed: SHA-256 mismatch! Expected $expectedHash, Got $actualHash.$($Script:Colors.Reset)"
                            }
                        } else {
                            Write-Host "$($Script:Colors.BloodRed)Security verification failed: Invalid SHA-256 digest format in release manifest.$($Script:Colors.Reset)"
                        }
                    } else {
                        Write-Host "$($Script:Colors.BloodRed)Security verification failed: No SHA-256 entry found for PhantomStartup.ps1 in release manifest.$($Script:Colors.Reset)"
                    }
                    Remove-Item $sumsFile -Force -ErrorAction SilentlyContinue
                }
            } catch {
                Write-Host "$($Script:Colors.BloodRed)Security verification failed: SHA256SUMS manifest could not be retrieved. Aborting update.$($Script:Colors.Reset)"
            }

            $rawScript = Get-Content $tempDownload -Raw -ErrorAction SilentlyContinue
            $parseErr = $null
            [void][System.Management.Automation.Language.Parser]::ParseInput($rawScript, [ref]$null, [ref]$parseErr)
            if ($checksumValid -and $rawScript -and $rawScript.Length -gt 1000 -and ($rawScript -match 'PHANTOM') -and (-not $parseErr -or $parseErr.Count -eq 0)) {
                $targetDir = Split-Path -Parent $Script:ScriptPath
                $stageFile = Join-Path $targetDir "PhantomStartup.ps1.stage.$PID"
                $promotedOk = $false
                try {
                    Copy-Item $tempDownload $stageFile -Force
                    Copy-Item $Script:ScriptPath "$Script:ScriptPath.bak" -Force -ErrorAction SilentlyContinue
                    Move-Item $stageFile $Script:ScriptPath -Force
                    Remove-Item "$Script:ScriptPath.bak" -Force -ErrorAction SilentlyContinue
                    $promotedOk = $true
                } catch {
                    $promotedOk = $false
                    if (Test-Path "$Script:ScriptPath.bak") {
                        Move-Item "$Script:ScriptPath.bak" $Script:ScriptPath -Force -ErrorAction SilentlyContinue
                    }
                    Write-Host "$($Script:Colors.BloodRed)Failed to promote update: $_$($Script:Colors.Reset)"
                }
                Remove-Item $tempDownload -Force -ErrorAction SilentlyContinue
                if ($promotedOk) {
                    $cache = Get-PhantomCache
                    $cache.LatestVersion = $latestVersion
                    $cache.UpdateAvailable = $false
                    $cache.UpdateDownloaded = $false
                    Save-PhantomCache -Cache $cache
                    Write-Host "$($Script:Colors.NeonGreen)Updated successfully to v$latestVersion! Restart terminal or run 'phantom-reload' to apply.$($Script:Colors.Reset)"
                }
            } else {
                Remove-Item $tempDownload -Force -ErrorAction SilentlyContinue
                Write-Host "$($Script:Colors.BloodRed)Update integrity check failed: downloaded script was invalid, corrupted, or failed checksum. Aborting update.$($Script:Colors.Reset)"
            }
        } else {
            Write-Host "$($Script:Colors.NeonGreen)Already on latest version (v$Script:Version)$($Script:Colors.Reset)"
        }
    } catch {
        Write-Host "$($Script:Colors.BloodRed)Update failed: $_$($Script:Colors.Reset)"
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# COLORS & SYMBOLS
# ═══════════════════════════════════════════════════════════════════════════

$Script:ESC = [char]27

$Script:Colors = @{
    Reset        = "$Script:ESC[0m"
    Bold         = "$Script:ESC[1m"
    NeonGreen    = "$Script:ESC[38;5;118m"
    NeonPurple   = "$Script:ESC[38;5;129m"
    NeonCyan     = "$Script:ESC[38;5;87m"
    ElectricBlue = "$Script:ESC[38;5;39m"
    HotPink      = "$Script:ESC[38;5;205m"
    Gold         = "$Script:ESC[38;5;220m"
    BloodRed     = "$Script:ESC[38;5;196m"
    BrightRed    = "$Script:ESC[1;91m"
    White        = "$Script:ESC[1;37m"
    Gray         = "$Script:ESC[38;5;244m"
    DarkGray     = "$Script:ESC[38;5;240m"
    Shadow       = "$Script:ESC[38;5;235m"
    Yellow       = "$Script:ESC[38;5;226m"
    Orange       = "$Script:ESC[38;5;208m"
}

function Get-ThemeColor { param([string]$Type)
    $colorName = $Script:CurrentTheme[$Type]
    return $Script:Colors[$colorName]
}

function Get-GradientColor { param([int]$Index)
    $gradients = $Script:CurrentTheme.GradientColors
    $colorName = $gradients[$Index % $gradients.Count]
    return $Script:Colors[$colorName]
}

$Script:Symbols = @{
    Skull = "[X]"; Shield = "[#]"; Lock = "[=]"; Key = "[-]"
    HighVoltage = "[!]"; Success = "[+]"; Failure = "[x]"
    Prompt = ">"; Update = "[U]"
    CPU = "CPU"; RAM = "RAM"
    HLine = "="; VLine = "|"
    TopLeft = "+"; TopRight = "+"; BottomLeft = "+"; BottomRight = "+"
    TLeft = "+"; TRight = "+"
    Block = "#"; BlockEmpty = "-"
}

try {
    # Prefer UTF-8 glyphs
    $Script:Symbols = @{
        Skull = [char]0x2620; Shield = [char]0x2591; Lock = [char]0x25A0; Key = [char]0x25CF
        HighVoltage = [char]0x26A1; Success = [char]0x2714; Failure = [char]0x2718
        Prompt = [char]0x00BB; Update = [char]0x21BB
        CPU = "CPU"; RAM = "RAM"
        HLine = [char]0x2550; VLine = [char]0x2551
        TopLeft = [char]0x2554; TopRight = [char]0x2557; BottomLeft = [char]0x255A; BottomRight = [char]0x255D
        TLeft = [char]0x2560; TRight = [char]0x2563
        Block = [char]0x2588; BlockEmpty = [char]0x2591
    }
} catch {}

# ═══════════════════════════════════════════════════════════════════════════
# BUFFER & TERMINAL UTILITIES
# ═══════════════════════════════════════════════════════════════════════════

function New-RenderBuffer { return [System.Text.StringBuilder]::new(4096) }
function Add-ToBuffer { param([System.Text.StringBuilder]$Buffer, [string]$Text); [void]$Buffer.Append($Text) }
function Write-Buffer { param([System.Text.StringBuilder]$Buffer); Write-Host $Buffer.ToString() -NoNewline; [void]$Buffer.Clear() }
function Move-CursorFast { param([int]$Row, [int]$Col); return "$Script:ESC[$Row;${Col}H" }

function Hide-Cursor { Write-Host "$Script:ESC[?25l" -NoNewline }
function Show-Cursor { Write-Host "$Script:ESC[?25h" -NoNewline }
function Clear-TerminalScreen { try { Clear-Host } catch {}; Write-Host "$Script:ESC[H" -NoNewline }

function Get-TerminalSize {
    try {
        $w = $Host.UI.RawUI.WindowSize.Width
        $h = $Host.UI.RawUI.WindowSize.Height
        if ($w -lt 20) { $w = 80 }
        if ($h -lt 10) { $h = 24 }
        return @{ Width = $w; Height = $h }
    } catch {
        return @{ Width = 80; Height = 24 }
    }
}

function Write-Centered {
    param([string]$Text, [string]$Color = $Script:Colors.White)
    $size = Get-TerminalSize
    $cleanText = $Text -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
    $padding = [Math]::Max(0, [Math]::Floor(($size.Width - $cleanText.Length) / 2))
    Write-Host "$(' ' * $padding)$Color$Text$($Script:Colors.Reset)"
}

function Write-GradientLogo {
    param([string]$Art)
    $lines = $Art -split "`n" | Where-Object { $_.Trim() }
    $size = Get-TerminalSize
    $maxWidth = ($lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
    $startCol = [Math]::Max(0, [Math]::Floor(($size.Width - $maxWidth) / 2))

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $color = if ($Script:Config.GradientText) { Get-GradientColor -Index $i } else { Get-ThemeColor "Primary" }
        Write-Host "$(' ' * $startCol)$color$($lines[$i])$($Script:Colors.Reset)"
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# FAST SYSTEM SPECS & CYBERPUNK SPOOFING
# ═══════════════════════════════════════════════════════════════════════════

function Get-SystemMetrics {
    $specs = @{
        Operator = $env:USERNAME
        Host     = $env:COMPUTERNAME
        System   = "Windows"
        Uptime   = "N/A"
        CPU      = 15
        RAM      = 40
        RAMUsed  = 0
        RAMTotal = 0
    }

    # Fast Native OS Detection (Zero WMI Delay: < 1ms)
    try {
        $osVer = [System.Environment]::OSVersion.Version
        $build = $osVer.Build
        if ($build -ge 22000) {
            $specs.System = "Microsoft Windows 11 Pro"
        } elseif ($build -ge 10240) {
            $specs.System = "Microsoft Windows 10 Pro"
        } else {
            $specs.System = [System.Environment]::OSVersion.VersionString
        }
    } catch {}

    # Fast Native Uptime (TickCount64: < 0.1ms)
    try {
        $ticks = [System.Environment]::TickCount64
        $span = [System.TimeSpan]::FromMilliseconds($ticks)
        $specs.Uptime = "{0}d {1}h {2}m" -f $span.Days, $span.Hours, $span.Minutes
    } catch {}

    # Fast Native RAM Calculation (Cross-platform PS 5.1 & PS 7+)
    try {
        if (-not ('Microsoft.VisualBasic.Devices.ComputerInfo' -as [type])) {
            Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction SilentlyContinue
        }
        $ci = New-Object Microsoft.VisualBasic.Devices.ComputerInfo -ErrorAction Stop
        $totalBytes = $ci.TotalPhysicalMemory
        $availBytes = $ci.AvailablePhysicalMemory
        if ($totalBytes -gt 0) {
            $specs.RAMTotal = [Math]::Round($totalBytes / 1GB, 1)
            $specs.RAMUsed = [Math]::Round(($totalBytes - $availBytes) / 1GB, 1)
            $specs.RAM = [Math]::Max(1, [Math]::Min(99, [Math]::Round(($specs.RAMUsed / $specs.RAMTotal) * 100)))
        }
    } catch {
        try {
            $os = Get-CimInstance Win32_OperatingSystem -Property TotalVisibleMemorySize, FreePhysicalMemory -ErrorAction Stop
            $totalKB = $os.TotalVisibleMemorySize
            $freeKB = $os.FreePhysicalMemory
            if ($totalKB -gt 0) {
                $specs.RAMTotal = [Math]::Round($totalKB / 1MB, 1)
                $specs.RAMUsed = [Math]::Round(($totalKB - $freeKB) / 1MB, 1)
                $specs.RAM = [Math]::Max(1, [Math]::Min(99, [Math]::Round(($specs.RAMUsed / $specs.RAMTotal) * 100)))
            }
        } catch {
            $specs.RAM = 45
        }
    }

    # Fast Native CPU Load Calculation (Non-blocking Process Delta)
    try {
        $cores = [System.Environment]::ProcessorCount
        $procs1 = [System.Diagnostics.Process]::GetProcesses()
        $t1 = 0.0
        foreach ($p in $procs1) { try { $t1 += $p.TotalProcessorTime.TotalSeconds } catch {} }

        Start-Sleep -Milliseconds 40

        $procs2 = [System.Diagnostics.Process]::GetProcesses()
        $t2 = 0.0
        foreach ($p in $procs2) { try { $t2 += $p.TotalProcessorTime.TotalSeconds } catch {} }

        $delta = [Math]::Max(0.0, $t2 - $t1)
        $cpuEst = [Math]::Round(($delta / (0.040 * $cores)) * 100)
        $specs.CPU = [Math]::Max(1, [Math]::Min(99, $cpuEst))
    } catch {
        $specs.CPU = 15
    }

    # Cyberpunk Stealth / Spoofing Mode
    if ($Script:Config.StealthMode) {
        $theme = $Script:CurrentTheme
        if (-not $theme) { $theme = $Script:Themes["Phantom"] }
        if ($theme.Operators) { $specs.Operator = Get-Random -InputObject $theme.Operators } else { $specs.Operator = "Ghost" }
        if ($theme.Hosts)     { $specs.Host     = Get-Random -InputObject $theme.Hosts } else { $specs.Host = "NEO-TOKYO-GRID" }
        if ($theme.Systems)   { $specs.System   = Get-Random -InputObject $theme.Systems } else { $specs.System = "Phantom OS v4.1.0 (Quantum Microkernel)" }
        if ($theme.Uptimes)   { $specs.Uptime   = Get-Random -InputObject $theme.Uptimes } else { $specs.Uptime = "∞ (Untraceable)" }
        $specs.CPU      = Get-Random -Minimum 8 -Maximum 16
        $specs.RAM      = Get-Random -Minimum 12 -Maximum 22
    }

    return $specs
}

# ═══════════════════════════════════════════════════════════════════════════
# DASHBOARD BOX ENGINE (Exact 66-column cross-platform visual parity)
# ═══════════════════════════════════════════════════════════════════════════

function Render-UsageBarLine {
    param(
        [string]$Indent,
        [string]$Primary,
        [string]$Label,
        [int]$Percent,
        [int]$BarWidth = 24,
        [int]$InnerWidth = 64
    )
    $filled = [Math]::Floor($BarWidth * $Percent / 100)
    $empty = $BarWidth - $filled

    $bar = ("$($Script:Symbols.Block)" * $filled) + ("$($Script:Symbols.BlockEmpty)" * $empty)

    $barColor = $Script:Colors.NeonGreen
    if ($Percent -gt 80) { $barColor = $Script:Colors.BloodRed }
    elseif ($Percent -gt 60) { $barColor = $Script:Colors.Orange }

    # Pad label to exactly 10 characters so brackets align identically across all rows
    $cleanLabel = $Label.PadRight(10)
    if ($cleanLabel.Length -gt 10) { $cleanLabel = $cleanLabel.Substring(0, 10) }

    # Visible text: "  " (2) + cleanLabel (10) + "[" (1) + Bar (BarWidth) + "] " (2) + Percent (3) + "%" (1)
    $cleanLen = 2 + 10 + 1 + $BarWidth + 2 + 3 + 1
    $rightPad = [Math]::Max(0, $InnerWidth - $cleanLen)
    $padStr = " " * $rightPad

    return "$Indent$Primary$($Script:Symbols.VLine)  $($Script:Colors.White)$cleanLabel$($Script:Colors.DarkGray)[$barColor$bar$($Script:Colors.DarkGray)] $($Script:Colors.White)$($Percent.ToString().PadLeft(3))%$padStr$Primary$($Script:Symbols.VLine)$($Script:Colors.Reset)"
}

function Show-Dashboard {
    param([switch]$LiveMode)

    $size = Get-TerminalSize
    $primary = Get-ThemeColor "Primary"
    $secondary = Get-ThemeColor "Secondary"

    $boxWidth = 66
    if ($size.Width -lt 70) { $boxWidth = [Math]::Max(34, $size.Width - 4) }
    $inner = $boxWidth - 2

    $padding = [Math]::Max(0, [Math]::Floor(($size.Width - $boxWidth) / 2))
    $indent = " " * $padding
    $hLine = [string]::new([char]$Script:Symbols.HLine, $inner)

    $specs = Get-SystemMetrics
    $datetime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Header Logo
    Clear-TerminalScreen
    Write-Host ""
    Write-GradientLogo -Art $Script:CurrentTheme.Logo
    Write-Host ""

    # Box Top Border
    Write-Host "$indent$primary$($Script:Symbols.TopLeft)$hLine$($Script:Symbols.TopRight)$($Script:Colors.Reset)"

    # Title Row
    $titleText = "$($Script:CurrentTheme.Title) v$Script:Version `"$Script:Codename`""
    $skullVisual = 2
    $titleVisual = ($skullVisual + 2) + $titleText.Length + (2 + $skullVisual)
    $titlePad = [Math]::Max(0, $inner - $titleVisual)
    $halfLeft = [Math]::Floor($titlePad / 2)
    $halfRight = $titlePad - $halfLeft
    Write-Host "$indent$primary$($Script:Symbols.VLine)$(' ' * $halfLeft)$secondary$($Script:Symbols.Skull)  $titleText  $($Script:Symbols.Skull)$primary$(' ' * $halfRight)$($Script:Symbols.VLine)$($Script:Colors.Reset)"

    Write-Host "$indent$primary$($Script:Symbols.TLeft)$hLine$($Script:Symbols.TRight)$($Script:Colors.Reset)"

    # System Info Rows
    if ($Script:Config.ShowSystemInfo) {
        $infoRows = @(
            @{ L = "Operator: "; V = $specs.Operator; C = $Script:Colors.NeonGreen },
            @{ L = "Host:     "; V = $specs.Host;     C = $Script:Colors.Gold },
            @{ L = "System:   "; V = $specs.System;   C = $Script:Colors.Gold },
            @{ L = "Uptime:   "; V = $specs.Uptime;   C = $Script:Colors.NeonCyan },
            @{ L = "Time:     "; V = $datetime;       C = $Script:Colors.NeonCyan }
        )

        foreach ($row in $infoRows) {
            $label = $row.L
            $val = $row.V
            $cleanLen = 2 + $label.Length + $val.Length
            if ($cleanLen -gt ($inner - 2)) {
                $maxValLen = [Math]::Max(10, $inner - 4 - $label.Length)
                $val = $val.Substring(0, $maxValLen)
                $cleanLen = 2 + $label.Length + $val.Length
            }
            $rpad = [Math]::Max(0, $inner - $cleanLen)
            Write-Host "$indent$primary$($Script:Symbols.VLine)  $($Script:Colors.White)$label$($row.C)$val$primary$(' ' * $rpad)$($Script:Symbols.VLine)$($Script:Colors.Reset)"
        }

        # CPU & RAM Usage Bars (Restored & Perfected inside the box!)
        if ($Script:Config.ShowUsageBars) {
            Write-Host "$indent$primary$($Script:Symbols.TLeft)$hLine$($Script:Symbols.TRight)$($Script:Colors.Reset)"

            $barW = [Math]::Max(8, [Math]::Min(24, $inner - 24))

            # Dynamic sweep on initial load
            if ($Script:Config.LiveStats -and -not $LiveMode) {
                for ($step = 1; $step -le 4; $step++) {
                    $cTmp = [Math]::Round($specs.CPU * ($step / 4))
                    $rTmp = [Math]::Round($specs.RAM * ($step / 4))
                    # Render fast in-place bar fill
                    Write-Host "`r" -NoNewline
                }
            }

            Write-Host (Render-UsageBarLine -Indent $indent -Primary $primary -Label "CPU:" -Percent $specs.CPU -BarWidth $barW -InnerWidth $inner)
            Write-Host (Render-UsageBarLine -Indent $indent -Primary $primary -Label "RAM:" -Percent $specs.RAM -BarWidth $barW -InnerWidth $inner)
        }

        Write-Host "$indent$primary$($Script:Symbols.TLeft)$hLine$($Script:Symbols.TRight)$($Script:Colors.Reset)"
    }

    # Quote Row
    $quote = $Script:CurrentTheme.Quotes[(Get-Random -Max $Script:CurrentTheme.Quotes.Count)]
    if ($quote.Length -gt ($inner - 4)) {
        $quote = $quote.Substring(0, [Math]::Max(10, $inner - 7)) + "..."
    }
    $quotePad = [Math]::Max(0, $inner - $quote.Length - 2)
    Write-Host "$indent$primary$($Script:Symbols.VLine)  $($Script:Colors.Gray)$quote$primary$(' ' * $quotePad)$($Script:Symbols.VLine)$($Script:Colors.Reset)"

    # Box Bottom Border
    Write-Host "$indent$primary$($Script:Symbols.BottomLeft)$hLine$($Script:Symbols.BottomRight)$($Script:Colors.Reset)"
    Write-Host ""

    # Update Notification
    if ($Script:UpdateAvailable) {
        if ($Script:UpdateDownloaded) {
            Write-Host "$indent$($Script:Colors.NeonGreen)$($Script:Symbols.Update) Updated to v$Script:UpdateAvailable! Reopen terminal to apply.$($Script:Colors.Reset)"
        } else {
            Write-Host "$indent$($Script:Colors.Gold)$($Script:Symbols.Update) Update v$Script:UpdateAvailable available (run 'phantom-update')$($Script:Colors.Reset)"
        }
        Write-Host ""
    }

    $helpCmd = if ($Script:CurrentTheme.Name -eq "Unknown") { "unknown-help" } else { "phantom-help" }
    Write-Host "$indent$($Script:Colors.DarkGray)Type '$($Script:Colors.Gold)$helpCmd$($Script:Colors.DarkGray)' for commands.$($Script:Colors.Reset)"
    Write-Host ""
}

# ═══════════════════════════════════════════════════════════════════════════
# INTERACTIVE LIVE TELEMETRY DASHBOARD (In-place dynamic box refresh)
# ═══════════════════════════════════════════════════════════════════════════

function Start-PhantomLiveMonitor {
    Hide-Cursor
    Clear-TerminalScreen
    Write-Host "$($Script:Colors.DarkGray)Entering Phantom Live Dashboard. Press ANY KEY to exit...$($Script:Colors.Reset)"
    Start-Sleep -Milliseconds 400

    try {
        while ($true) {
            Show-Dashboard -LiveMode

            # Check for key press every 100ms for 1 second total
            for ($k = 0; $k -lt 10; $k++) {
                if ([Console]::KeyAvailable) {
                    $null = [Console]::ReadKey($true)
                    return
                }
                Start-Sleep -Milliseconds 100
            }
        }
    } finally {
        Show-Cursor
        Clear-TerminalScreen
        Write-Host "$($Script:Colors.NeonGreen)Live monitor stopped.$($Script:Colors.Reset)`n"
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# ANIMATIONS & SMOOTH KEYPRESS SKIP
# ═══════════════════════════════════════════════════════════════════════════

$Script:SkipAnimationRequested = $false

function Test-PhantomSkipKey {
    if ($Script:SkipAnimationRequested) { return $true }
    try {
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            $Script:SkipAnimationRequested = $true
            return $true
        }
    } catch {}
    return $false
}

function Show-SecurityLoadingBar {
    param([string]$Description, [int]$Steps = 8, [string]$Color)
    if (-not $Color) { $Color = Get-ThemeColor "Primary" }

    $buffer = New-RenderBuffer
    for ($i = 1; $i -le $Steps; $i++) {
        if (Test-PhantomSkipKey) { return }
        $filled = [string]::new([char]$Script:Symbols.Block, $i)
        $empty = [string]::new([char]$Script:Symbols.BlockEmpty, ($Steps - $i))
        $percent = [Math]::Floor(($i / $Steps) * 100)

        [void]$buffer.Clear()
        Add-ToBuffer $buffer "`r  $($Script:Colors.Gray)$Description $($Script:Colors.DarkGray)[$Color$filled$($Script:Colors.DarkGray)$empty] $($Script:Colors.White)$($percent.ToString().PadLeft(3))%"
        Write-Buffer $buffer
        Start-Sleep -Milliseconds 20
    }
    Write-Host " $($Script:Colors.NeonGreen)$($Script:Symbols.Success)$($Script:Colors.Reset)"
}

function Show-MultiColorMatrix {
    param([int]$DurationSeconds = 2)
    Clear-TerminalScreen
    $size = Get-TerminalSize

    $chars = if ($Script:Config.MatrixMode -eq "Binary") { "01" } else { $Script:CurrentTheme.MatrixChars }

    $primary = Get-ThemeColor "Primary"
    $secondary = Get-ThemeColor "Secondary"
    $colorList = @($primary, $secondary, $Script:Colors.NeonCyan, $Script:Colors.ElectricBlue)

    $drops = New-Object int[] $size.Width
    for ($i = 0; $i -lt $size.Width; $i++) { $drops[$i] = (Get-Random -Minimum 0 -Maximum $size.Height) }

    $endTime = (Get-Date).AddSeconds($DurationSeconds)
    $buffer = New-RenderBuffer

    while ((Get-Date) -lt $endTime) {
        if (Test-PhantomSkipKey) { break }
        [void]$buffer.Clear()
        for ($col = 0; $col -lt [Math]::Min($size.Width, $drops.Count); $col += 2) {
            $char = $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)]
            $color = $colorList[$col % $colorList.Length]
            $row = $drops[$col]

            if ($row -lt $size.Height -and $row -ge 1) {
                Add-ToBuffer $buffer (Move-CursorFast -Row $row -Col $col)
                Add-ToBuffer $buffer "$color$char"
                $leadPos = $row + 1
                if ($leadPos -lt $size.Height) {
                    Add-ToBuffer $buffer (Move-CursorFast -Row $leadPos -Col $col)
                    Add-ToBuffer $buffer "$($Script:Colors.White)$char"
                }
            }
            $drops[$col]++
            if ($drops[$col] -ge $size.Height -and (Get-Random -Minimum 0 -Maximum 4) -eq 0) { $drops[$col] = 1 }
        }
        Write-Buffer $buffer
        Start-Sleep -Milliseconds 14
    }
    Write-Host $Script:Colors.Reset
}

function Show-CoreIgnition {
    Clear-TerminalScreen
    $size = Get-TerminalSize
    $yPos = [Math]::Floor($size.Height / 2) - 3
    $primary = Get-ThemeColor "Primary"

    $statuses = @("[CORE_INIT]", "[ENCRYPTION_KEYS]", "[FIREWALL_MATRIX]", "[AUTH_BYPASS]", "[SYSTEM_ARMED]")
    $buffer = New-RenderBuffer

    foreach ($text in $statuses) {
        if (Test-PhantomSkipKey) { return }
        $padding = [Math]::Max(0, [Math]::Floor(($size.Width - $text.Length - 4) / 2))

        [void]$buffer.Clear()
        Add-ToBuffer $buffer (Move-CursorFast -Row $yPos -Col 1)
        Add-ToBuffer $buffer "$(' ' * $padding)$($Script:Colors.BloodRed)$($Script:Symbols.HighVoltage) $text"
        Write-Buffer $buffer
        Start-Sleep -Milliseconds 40

        [void]$buffer.Clear()
        Add-ToBuffer $buffer (Move-CursorFast -Row $yPos -Col 1)
        Add-ToBuffer $buffer "$(' ' * $padding)$primary$($Script:Symbols.HighVoltage) $text$($Script:Colors.Reset)"
        Write-Buffer $buffer
        Write-Host ""
        $yPos++
        Start-Sleep -Milliseconds 20
    }
    Start-Sleep -Milliseconds 80
}

function Show-GlitchReveal {
    param([string]$Art, [string]$Color)
    if (-not $Color) { $Color = Get-ThemeColor "Primary" }

    Clear-TerminalScreen
    $size = Get-TerminalSize
    $lines = $Art -split "`n" | Where-Object { $_.Trim() }

    $maxWidth = ($lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
    $startCol = [Math]::Max(1, [Math]::Floor(($size.Width - $maxWidth) / 2))
    $startRow = [Math]::Max(2, [Math]::Floor(($size.Height - $lines.Count) / 2))

    $glitchChars = '!@#$%_+-=:;,.?/'
    $buffer = New-RenderBuffer

    for ($g = 0; $g -lt $Script:Config.GlitchIntensity; $g++) {
        if (Test-PhantomSkipKey) { break }
        [void]$buffer.Clear()
        $row = $startRow
        foreach ($line in $lines) {
            Add-ToBuffer $buffer (Move-CursorFast -Row $row -Col $startCol)
            $glitched = -join ($line.ToCharArray() | ForEach-Object {
                if ($_ -ne ' ' -and (Get-Random -Max 10) -lt 3) { $glitchChars[(Get-Random -Max $glitchChars.Length)] } else { $_ }
            })
            Add-ToBuffer $buffer "$($Script:Colors.BrightRed)$glitched$($Script:Colors.Reset)"
            $row++
        }
        Write-Buffer $buffer
        Start-Sleep -Milliseconds 30
    }

    Clear-TerminalScreen
    Write-Host ""
    Write-GradientLogo -Art $Art
    Start-Sleep -Milliseconds 150
}

function Show-SecuritySequence {
    Clear-TerminalScreen
    Write-Host "`n"
    $primary = Get-ThemeColor "Primary"

    Write-Centered "$primary$($Script:Symbols.Shield) INITIALIZING SECURITY PROTOCOLS $($Script:Symbols.Shield)$($Script:Colors.Reset)"
    Write-Host ""

    @("Initializing AES-256 Encryption", "Generating SHA-512 Hashes", "Activating Firewall Matrix", "Establishing Secure Channel") | ForEach-Object {
        Show-SecurityLoadingBar -Description "$($Script:Symbols.Lock) $_" -Steps $Script:Config.SecurityLoadSteps -Color $primary
    }
    Start-Sleep -Milliseconds 80
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN STARTUP SEQUENCE
# ═══════════════════════════════════════════════════════════════════════════

function Show-UpdateCelebrationModal {
    param([string]$OldVersion)
    $size = Get-TerminalSize
    $boxWidth = 66
    if ($size.Width -lt 70) { $boxWidth = [Math]::Max(34, $size.Width - 4) }
    $inner = $boxWidth - 2
    $padding = [Math]::Max(0, [Math]::Floor(($size.Width - $boxWidth) / 2))
    $indent = " " * $padding
    $hLine = [string]::new([char]$Script:Symbols.HLine, $inner)
    $primary = Get-ThemeColor "Primary"

    Write-Host ""
    Write-Host "$indent$primary$($Script:Symbols.TopLeft)$hLine$($Script:Symbols.TopRight)$($Script:Colors.Reset)"
    $title = "⚡ SYSTEM UPGRADE SUCCESSFUL ⚡"
    $titlePad = [Math]::Max(0, $inner - $title.Length)
    $hl = [Math]::Floor($titlePad / 2)
    $hr = $titlePad - $hl
    Write-Host "$indent$primary$($Script:Symbols.VLine)$(' ' * $hl)$($Script:Colors.Gold)$title$primary$(' ' * $hr)$($Script:Symbols.VLine)$($Script:Colors.Reset)"
    Write-Host "$indent$primary$($Script:Symbols.BottomLeft)$hLine$($Script:Symbols.BottomRight)$($Script:Colors.Reset)"

    $prefix = if ($Script:CurrentTheme.Name -eq "Unknown") { "unknown" } else { "phantom" }
    Write-Host ""
    Write-Host "$indent$($Script:Colors.NeonGreen)  $($Script:CurrentTheme.Title) v$Script:Version `"$Script:Codename`" is now online!$($Script:Colors.Reset)"
    Write-Host ""
    Write-Host "$indent$($Script:Colors.White)  Highlights in v$Script:Version :$($Script:Colors.Reset)"
    Write-Host "$indent$($Script:Colors.NeonCyan)  [+] Zero Dependencies:$($Script:Colors.Gray) 100% Native Shell (Zero Python/pip/jq)"
    Write-Host "$indent$($Script:Colors.NeonCyan)  [+] Instant Keypress Skip:$($Script:Colors.Gray) Smooth launch on Spacebar or Enter"
    Write-Host "$indent$($Script:Colors.NeonCyan)  [+] Precision 66-Column Box:$($Script:Colors.Gray) Unified alignment & closed borders"
    Write-Host "$indent$($Script:Colors.NeonCyan)  [+] Live Telemetry:$($Script:Colors.Gray) Real-time hardware HUD ($prefix-top / $prefix-dash -Live)"
    Write-Host "$indent$($Script:Colors.NeonCyan)  [+] Cyberpunk Stealth Mode:$($Script:Colors.Gray) Identity & system cloaking ($prefix-stealth)"
    Write-Host ""
    Write-Host "$indent$($Script:Colors.DarkGray)  Type '$($Script:Colors.Gold)$prefix-help$($Script:Colors.DarkGray)' or '$($Script:Colors.Gold)$prefix-changelog$($Script:Colors.DarkGray)' to explore.$($Script:Colors.Reset)"
    Write-Host ""

    # Check for changelog markdown file
    $changelogFile = Join-Path $Script:ConfigDir "latest_changelog.md"
    if (-not (Test-Path $changelogFile)) {
        $candidate = Join-Path $PSScriptRoot "docs\changelogs\v$Script:Version.md"
        if (Test-Path $candidate) { $changelogFile = $candidate }
    }
    if (Test-Path $changelogFile) {
        try {
            $cl = Get-Content $changelogFile -Raw -ErrorAction SilentlyContinue
            if ($cl) {
                Write-Host "$indent$($Script:Colors.Gold)Changelog Highlights:$($Script:Colors.Reset)"
                $lines = $cl -split "`r?`n" | Where-Object { $_ -and -not ($_.StartsWith('#')) } | Select-Object -First 6
                foreach ($ln in $lines) {
                    if ($ln.Trim()) { Write-Host "$indent  $($Script:Colors.Gray)$($ln.Trim())" }
                }
                Write-Host ""
            }
        } catch {}
    }

    # Smooth pause with keypress skip
    for ($k = 0; $k -lt 12; $k++) {
        Start-Sleep -Milliseconds 100
        try {
            if ([Console]::KeyAvailable) {
                [void][Console]::ReadKey($true)
                break
            }
        } catch {}
    }
}

function Start-PhantomTerminal {
    param([switch]$Force)
    # If running inside an AI Agent, CI, or quiet mode: instant silent bypass
    if ($Script:IsAgentSession -and -not $Force) { return }

    # Post-Update Celebration & Changelog Modal
    $cache = Get-PhantomCache
    if ($null -eq $cache.LastSeenVersion -or (Test-PhantomVersionGreater $Script:Version $cache.LastSeenVersion)) {
        Show-UpdateCelebrationModal -OldVersion $cache.LastSeenVersion
        $cache.LastSeenVersion = $Script:Version
        $cache.UpdateDownloaded = $false
        $cache.UpdateAvailable = $false
        Save-PhantomCache -Cache $cache
    }

    # Nested subshell detection: skip replay inside child subshells
    if (($env:PHANTOM_SESSION_ACTIVE -or $env:UNKNOWN_SESSION_ACTIVE) -and -not $Force) {
        Show-Dashboard
        return
    }
    $env:PHANTOM_SESSION_ACTIVE = "1"
    $env:UNKNOWN_SESSION_ACTIVE = "1"

    if (-not $Script:Config.AnimationEnabled -and -not $Force) { Show-Dashboard; return }

    $Script:SkipAnimationRequested = $false
    try {
        Hide-Cursor
        if (-not $Script:SkipAnimationRequested) { Show-CoreIgnition }
        if (-not $Script:SkipAnimationRequested) { Show-SecuritySequence }
        if (-not $Script:SkipAnimationRequested) { Show-MultiColorMatrix -DurationSeconds $Script:Config.MatrixDuration }
        if (-not $Script:SkipAnimationRequested) { Show-GlitchReveal -Art $Script:CurrentTheme.Logo -Color (Get-ThemeColor "Primary") }
        Show-Dashboard
    } catch {
        Show-Dashboard
    } finally {
        Show-Cursor
        # Flush pending keystrokes entered during animation
        try {
            while ([Console]::KeyAvailable) { [void][Console]::ReadKey($true) }
        } catch {}
    }

    # Asynchronous non-blocking background update check
    if ($Script:Config.AutoCheckUpdates) {
        $shouldCheck = $true
        $c = Get-PhantomCache
        if ($c.LastUpdateCheck) {
            try {
                $lastD = [DateTime]::Parse($c.LastUpdateCheck)
                if (((Get-Date) - $lastD).TotalDays -lt $Script:Config.UpdateCheckDays) {
                    $shouldCheck = $false
                }
            } catch {}
        }
        if ($shouldCheck) {
            try {
                Start-Job -ScriptBlock {
                    param($RepoOwner, $RepoName, $CurrentVersion, $CacheFile, $ConfigDir)
                    try {
                        $apiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
                        $response = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 4
                        $latestVersion = $response.tag_name -replace '^v', ''

                        $cleanNew = ($latestVersion -replace '^[vV]', '') -replace '-.*$', ''
                        $cleanCur = ($CurrentVersion -replace '^[vV]', '') -replace '-.*$', ''
                        $isGreater = $false
                        try {
                            if ([version]$cleanNew -gt [version]$cleanCur) { $isGreater = $true }
                        } catch {}

                        $existing = @{}
                        if (Test-Path $CacheFile) {
                            try { $existing = Get-Content $CacheFile -Raw | ConvertFrom-Json } catch {}
                        }
                        $cache = @{
                            LastUpdateCheck  = (Get-Date).ToString("o")
                            LatestVersion    = $latestVersion
                            UpdateAvailable  = $isGreater
                            UpdateDownloaded = $false
                            LastSeenVersion  = $existing.LastSeenVersion
                        }
                        # Save release notes if present
                        if ($response.body) {
                            try {
                                $notesFile = Join-Path $ConfigDir "release_notes.txt"
                                $response.body | Out-File $notesFile -Encoding UTF8 -Force
                            } catch {}
                        }
                        $cache | ConvertTo-Json | Out-File $CacheFile -Encoding UTF8 -Force
                    } catch {}
                } -ArgumentList $Script:RepoOwner, $Script:RepoName, $Script:Version, $Script:CacheFile, $Script:ConfigDir | Out-Null
            } catch {}
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# PROMPT WITH NON-BLOCKING GIT HUD
# ═══════════════════════════════════════════════════════════════════════════

function Set-PhantomPrompt {
    function global:prompt {
        $lastSuccess = $?

        # Path resolution
        if ($Script:Config.StealthMode) {
            $pathDisplay = if ($Script:Config.Theme -eq "Unknown") { "~/unknown/darknet/grid" } else { "~/phantom/core/grid" }
        } elseif ($Script:Config.ShowFullPath) {
            $pathDisplay = (Get-Location).Path
        } else {
            $pathDisplay = Split-Path (Get-Location).Path -Leaf
            if (-not $pathDisplay) { $pathDisplay = (Get-Location).Path }
        }

        # Non-blocking Git Branch Discovery (Walk up parent directories without spawning git process)
        $gitBranch = ""
        $currentDir = (Get-Location).Path
        while ($currentDir) {
            $gitCandidate = Join-Path $currentDir ".git"
            if (Test-Path $gitCandidate -ErrorAction SilentlyContinue) {
                try {
                    $headFile = if (Test-Path $gitCandidate -PathType Container) {
                        Join-Path $gitCandidate "HEAD"
                    } else {
                        $wtLine = Get-Content $gitCandidate -First 1 -ErrorAction SilentlyContinue
                        if ($wtLine -match "gitdir:\s*(.+)") {
                            $wtPath = $matches[1].Trim()
                            if (-not [System.IO.Path]::IsPathRooted($wtPath)) {
                                $wtPath = Join-Path $currentDir $wtPath
                            }
                            Join-Path $wtPath "HEAD"
                        } else { $null }
                    }
                    if ($headFile -and (Test-Path $headFile)) {
                        $headContent = Get-Content $headFile -First 1 -ErrorAction SilentlyContinue
                        if ($headContent -match "ref: refs/heads/(.+)") {
                            $gitBranch = " $($Script:Colors.DarkGray)on $($Script:Colors.HotPink)$($matches[1])"
                        } elseif ($headContent -and $headContent.Length -ge 7) {
                            $gitBranch = " $($Script:Colors.DarkGray)on $($Script:Colors.HotPink)$($headContent.Substring(0,7))"
                        }
                    }
                } catch {}
                break
            }
            $parentDir = Split-Path $currentDir -Parent
            if ($parentDir -eq $currentDir) { break }
            $currentDir = $parentDir
        }

        $status = if ($lastSuccess) { "$($Script:Colors.NeonGreen)$($Script:Symbols.Success)" } else { "$($Script:Colors.BloodRed)$($Script:Symbols.Failure)" }
        $primary = Get-ThemeColor "Primary"
        $user = if ($Script:Config.StealthMode) {
            if ($Script:Config.Theme -eq "Unknown") { "unknown" } else { "ghost" }
        } else { $env:USERNAME }

        "$primary$user$($Script:Colors.DarkGray)@$($Script:Colors.NeonCyan)$pathDisplay$gitBranch$($Script:Colors.Reset)`n$status  $primary$($Script:Symbols.Prompt)$($Script:Colors.Reset) "
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# UNIVERSAL SMART SUGGESTIONS & SEARCH (phantom-search)
# ═══════════════════════════════════════════════════════════════════════════

function global:Test-PhantomSensitiveCommand {
    param([string]$CommandLine)
    if (-not $CommandLine -or $CommandLine.Trim().Length -le 1) { return $false }
    $sensitivePattern = '(?i)(--password[= ]|--passwd[= ]|password[=:]|passwd[=:]|--token[= ]|token[=:]|bearer[ ]+[a-z0-9_\-\.]+|authorization:[ ]*bearer|--api[_-]?key[= ]|api[_-]?key[=:]|apikey[=:]|--secret[= ]|secret[=:]|aws[_-]?(secret|session)[_-]?[a-z]*[=:]|private[_-]?key|BEGIN[ ]+(RSA|OPENSSH|EC|DSA|PGP)?[ ]*PRIVATE KEY|id_rsa|id_ed25519|export[ ]+[a-z0-9_]*(key|secret|token|password)[ ]*=|curl[ ]+.*(-u|--user)[ ]+[^ ]+:[^ ]+|gh[pousr]_[a-z0-9_]{16,}|AKIA[0-9A-Z]{16}|xox[baprs]-[0-9A-Za-z-]+|sk-[A-Za-z0-9]{20,}|(mysql|mysqldump|mariadb)[ ]+.*-p[^ ]+)'
    return ($CommandLine -match $sensitivePattern)
}

function global:phantom-history {
    param([string]$Query = "")
    Write-Host "`n$($Script:Colors.NeonCyan)=== Phantom Command History ===$($Script:Colors.Reset)"

    $historyLines = @()
    $candidatePaths = @(
        (Join-Path $Script:UserHome "AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"),
        (Join-Path $Script:UserHome ".local\share\powershell\PSReadLine\ConsoleHost_history.txt")
    )
    foreach ($hp in $candidatePaths) {
        if ($hp -and (Test-Path $hp)) {
            $historyLines += Get-Content $hp -Tail 500 -ErrorAction SilentlyContinue
        }
    }
    try {
        $historyLines += (Get-History -Count 100).CommandLine
    } catch {}

    # Filter sensitive tokens using production Test-PhantomSensitiveCommand
    $cleaned = $historyLines | Where-Object {
        $_ -and $_.Trim().Length -gt 1 -and -not (Test-PhantomSensitiveCommand -CommandLine $_)
    }

    if ($Query) {
        $cleaned = $cleaned | Where-Object { $_ -like "*$Query*" }
    }

    $uniqueCmds = $cleaned | Select-Object -Unique -Last 15

    if (-not $uniqueCmds -or $uniqueCmds.Count -eq 0) {
        Write-Host "$($Script:Colors.DarkGray)No matching command history recorded.$($Script:Colors.Reset)`n"
        return
    }

    $i = 1
    foreach ($cmd in $uniqueCmds) {
        Write-Host "  $($Script:Colors.Gold)[$i]$($Script:Colors.White) $cmd$($Script:Colors.Reset)"
        $i++
    }
    Write-Host ""
}

function global:phantom-search { param([string]$Query = "") phantom-history $Query }
function global:unknown-search { param([string]$Query = "") phantom-history $Query }
function global:unknown-history { param([string]$Query = "") phantom-history $Query }

function Set-SmartSuggestions {
    if (-not $Script:Config.SmartSuggestions) { return }

    try {
        # Hook into PSReadLine ONLY if already available and version >= 2.2.0
        # (Never prompts for admin, never attempts untrusted Install-Module)
        $psrl = Get-Module PSReadLine -ErrorAction SilentlyContinue
        if ($psrl -and $psrl.Version -ge [version]"2.2.0") {
            Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
            Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction SilentlyContinue

            $color = if ($Script:CurrentTheme.Name -eq "Unknown") { "DarkGreen" } else { "DarkMagenta" }
            Set-PSReadLineOption -Colors @{ InlinePrediction = $color } -ErrorAction SilentlyContinue
            Set-PSReadLineOption -HistoryNoDuplicates $true -ErrorAction SilentlyContinue
            Set-PSReadLineKeyHandler -Key F2 -Function AcceptSuggestion -ErrorAction SilentlyContinue
            Set-PSReadLineKeyHandler -Key Ctrl+f -Function AcceptSuggestion -ErrorAction SilentlyContinue
        }
    } catch {}
}

# ═══════════════════════════════════════════════════════════════════════════
# USER COMMANDS & ALIASES
# ═══════════════════════════════════════════════════════════════════════════

function global:phantom-reload { Start-PhantomTerminal -Force }
function global:phantom-matrix { Hide-Cursor; Show-MultiColorMatrix -DurationSeconds 5; Show-Cursor }
function global:phantom-dash   {
    param([switch]$Live, [switch]$l)
    if ($Live -or $l) { Start-PhantomLiveMonitor } else { Show-Dashboard }
}
function global:phantom-top    { Start-PhantomLiveMonitor }
function global:phantom-live   { Start-PhantomLiveMonitor }
function global:phantom-update    { Update-PhantomTerminal }
function global:phantom-changelog {
    $changelogFile = Join-Path $Script:ConfigDir "latest_changelog.md"
    if (-not (Test-Path $changelogFile)) {
        $candidate = Join-Path $PSScriptRoot "docs\changelogs\v$Script:Version.md"
        if (Test-Path $candidate) { $changelogFile = $candidate }
    }
    if (Test-Path $changelogFile) {
        Write-Host "`n$($Script:Colors.NeonCyan)=== Phantom Terminal v$Script:Version Changelog ===$($Script:Colors.Reset)`n"
        Get-Content $changelogFile | ForEach-Object {
            if ($_.StartsWith('# ')) {
                Write-Host "$($Script:Colors.Gold)$($_)$($Script:Colors.Reset)"
            } elseif ($_.StartsWith('## ')) {
                Write-Host "`n$($Script:Colors.NeonGreen)$($_)$($Script:Colors.Reset)"
            } elseif ($_.StartsWith('### ')) {
                Write-Host "$($Script:Colors.White)$($_)$($Script:Colors.Reset)"
            } elseif ($_.StartsWith('- ') -or $_.StartsWith('* ')) {
                Write-Host "  $($Script:Colors.NeonCyan)•$($Script:Colors.Gray) $($_.Substring(2))$($Script:Colors.Reset)"
            } else {
                Write-Host "$($Script:Colors.DarkGray)$($_)$($Script:Colors.Reset)"
            }
        }
        Write-Host ""
    } else {
        Write-Host "$($Script:Colors.DarkGray)No local changelog found for v$Script:Version.$($Script:Colors.Reset)`n"
    }
}
function global:unknown-changelog { phantom-changelog }

function global:phantom-stealth {
    param([string]$Action)
    if ($Action -ieq "on") {
        $Script:Config.StealthMode = $true
        Save-PhantomConfig -Config $Script:Config
        Write-Host "$($Script:Colors.NeonGreen)[+] Cyberpunk Stealth Mode: ACTIVE$($Script:Colors.Reset)"
        Write-Host "$($Script:Colors.DarkGray)System specs and user identity are now masked.$($Script:Colors.Reset)`n"
    } elseif ($Action -ieq "off") {
        $Script:Config.StealthMode = $false
        Save-PhantomConfig -Config $Script:Config
        Write-Host "$($Script:Colors.Gold)[-] Cyberpunk Stealth Mode: DEACTIVATED$($Script:Colors.Reset)"
        Write-Host "$($Script:Colors.DarkGray)Real system specifications restored.$($Script:Colors.Reset)`n"
    } elseif ($Action -ieq "toggle") {
        $Script:Config.StealthMode = -not $Script:Config.StealthMode
        Save-PhantomConfig -Config $Script:Config
        $status = if ($Script:Config.StealthMode) { "ACTIVE" } else { "DEACTIVATED" }
        Write-Host "$($Script:Colors.NeonCyan)[*] Stealth Mode is now: $status$($Script:Colors.Reset)`n"
    } else {
        $curr = if ($Script:Config.StealthMode) { "$($Script:Colors.NeonGreen)ACTIVE" } else { "$($Script:Colors.DarkGray)DEACTIVATED" }
        Write-Host "`n$($Script:Colors.NeonCyan)Cyberpunk Stealth Mode: $curr$($Script:Colors.Reset)"
        Write-Host "$($Script:Colors.DarkGray)Usage: phantom-stealth on | off | toggle$($Script:Colors.Reset)`n"
    }
}

function global:phantom-help {
    $prefix = if ($Script:CurrentTheme.Name -eq "Unknown") { "unknown" } else { "phantom" }
    Write-Host ""
    Write-Host "$($Script:Colors.NeonCyan)=== $($Script:CurrentTheme.Title) v$Script:Version `"$Script:Codename`" ===$($Script:Colors.Reset)"
    Write-Host ""
    Write-Host "  $($Script:Colors.Gold)$prefix-reload$($Script:Colors.White)        - Replay startup animation$($Script:Colors.Reset)"
    Write-Host "  $($Script:Colors.Gold)$prefix-theme$($Script:Colors.White)         - Switch visual theme (Phantom/Unknown)$($Script:Colors.Reset)"
    Write-Host "  $($Script:Colors.Gold)$prefix-config$($Script:Colors.White)        - Show configuration$($Script:Colors.Reset)"
    Write-Host "  $($Script:Colors.Gold)$prefix-config -Edit$($Script:Colors.White)  - Edit configuration in notepad$($Script:Colors.Reset)"
    Write-Host "  $($Script:Colors.Gold)$prefix-dash$($Script:Colors.White)          - Show system dashboard$($Script:Colors.Reset)"
    Write-Host "  $($Script:Colors.Gold)$prefix-dash -Live$($Script:Colors.White)    - Live in-place dashboard monitor$($Script:Colors.Reset)"
    Write-Host "  $($Script:Colors.Gold)$prefix-stealth$($Script:Colors.White)       - Toggle privacy spoofing (on/off)$($Script:Colors.Reset)"
    Write-Host "  $($Script:Colors.Gold)$prefix-search$($Script:Colors.White)        - Smart history command predictor$($Script:Colors.Reset)"
    Write-Host "  $($Script:Colors.Gold)$prefix-matrix$($Script:Colors.White)        - Run matrix rain animation$($Script:Colors.Reset)"
    Write-Host "  $($Script:Colors.Gold)$prefix-update$($Script:Colors.White)        - Check for and apply updates$($Script:Colors.Reset)"
    Write-Host "  $($Script:Colors.Gold)$prefix-changelog$($Script:Colors.White)     - View release notes & changelog$($Script:Colors.Reset)"
    Write-Host ""
}

# Unknown theme mirror commands
function global:unknown-help    { phantom-help }
function global:unknown-reload  { Start-PhantomTerminal -Force }
function global:unknown-theme   { param([string]$ThemeName) phantom-theme $ThemeName }
function global:unknown-matrix  { Show-MultiColorMatrix -DurationSeconds $Script:Config.MatrixDuration }
function global:unknown-dash    { param([switch]$Live, [switch]$l) phantom-dash -Live:$Live -l:$l }
function global:unknown-top     { Start-PhantomLiveMonitor }
function global:unknown-live    { Start-PhantomLiveMonitor }
function global:unknown-update  { Update-PhantomTerminal }
function global:unknown-stealth { param([string]$Action) phantom-stealth $Action }
function global:unknown-config  { param([switch]$Edit) if ($Edit) { notepad $Script:ConfigFile } else { phantom-config } }
function global:unknown-chosen  { phantom-chosen }
function global:unknown-2829    { phantom-2829 }
function global:unknown-secrets { phantom-secrets }

function global:phantom-config {
    param([switch]$Edit)
    if ($Edit) {
        notepad $Script:ConfigFile
    } else {
        Write-Host "`n$($Script:Colors.NeonCyan)Config: $Script:ConfigFile$($Script:Colors.Reset)`n"
        $Script:Config.GetEnumerator() | Sort-Object Name | ForEach-Object {
            Write-Host "  $($Script:Colors.Gold)$($_.Key)$($Script:Colors.White): $($_.Value)$($Script:Colors.Reset)"
        }
        Write-Host "`n$($Script:Colors.DarkGray)Run: phantom-config -Edit$($Script:Colors.Reset)`n"
    }
}

function global:phantom-theme {
    param([string]$ThemeName)
    $available = $Script:Themes.Keys -join ", "

    if (-not $ThemeName) {
        Write-Host "`n$($Script:Colors.NeonCyan)Available themes: $available$($Script:Colors.Reset)"
        Write-Host "$($Script:Colors.Gold)Current: $($Script:Config.Theme)$($Script:Colors.Reset)"
        Write-Host "$($Script:Colors.DarkGray)Usage: phantom-theme Unknown$($Script:Colors.Reset)`n"
        return
    }

    $matchedKey = $null
    foreach ($key in $Script:Themes.Keys) {
        if ($key -ieq $ThemeName) { $matchedKey = $key; break }
    }

    if ($matchedKey) {
        $Script:Config.Theme = $matchedKey
        Save-PhantomConfig -Config $Script:Config
        $Script:CurrentTheme = $Script:Themes[$matchedKey]
        Write-Host "$($Script:Colors.NeonGreen)Theme changed to: $matchedKey$($Script:Colors.Reset)"
        Write-Host "$($Script:Colors.DarkGray)Run 'phantom-reload' to see changes$($Script:Colors.Reset)"
    } else {
        Write-Host "$($Script:Colors.BloodRed)Unknown theme. Available: $available$($Script:Colors.Reset)"
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# [REDACTED] EASTER EGGS
# ═══════════════════════════════════════════════════════════════════════════

function global:phantom-chosen {
    Save-PhantomSecret "chosen"
    Write-Host ""
    Write-Host "  YOU ARE THE CHOSEN ONE" -ForegroundColor Yellow
    Write-Host "  The Matrix has you..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Secret unlocked!" -ForegroundColor Magenta
    Write-Host ""
}

function global:phantom-2829 {
    Save-PhantomSecret "2829"
    try { Clear-Host } catch {}
    Hide-Cursor

    $width = 80
    try { $width = $Host.UI.RawUI.WindowSize.Width } catch {}
    function Center($text) {
        $pad = [math]::Max(0, ($width - $text.Length) / 2)
        return (" " * $pad) + $text
    }

    Write-Host "`n`n`n"
    Start-Sleep -Milliseconds 400
    Write-Host (Center "PHANTOM TERMINAL") -ForegroundColor Magenta
    Start-Sleep -Milliseconds 300
    Write-Host (Center "=================") -ForegroundColor DarkMagenta
    Start-Sleep -Milliseconds 400
    Write-Host "`n`n"
    Write-Host (Center "Created with <3 by") -ForegroundColor DarkGray
    Start-Sleep -Milliseconds 300
    Write-Host "`n"
    Write-Host (Center "UNKNOWN-2829") -ForegroundColor Cyan
    Start-Sleep -Milliseconds 400
    Write-Host "`n`n"
    Write-Host (Center "Github: github.com/Unknown-2829") -ForegroundColor Blue
    Start-Sleep -Milliseconds 300
    Write-Host (Center "Telegram: @unknownlll2829") -ForegroundColor Cyan
    Start-Sleep -Milliseconds 400
    Write-Host "`n`n"
    Write-Host (Center "'Build different. Think different.'") -ForegroundColor Yellow
    Start-Sleep -Milliseconds 500
    Write-Host "`n`n"
    Write-Host (Center "Thank you for using Phantom Terminal!") -ForegroundColor Green
    Start-Sleep -Milliseconds 500
    Write-Host "`n`n"
    Write-Host (Center "---") -ForegroundColor DarkGray
    Start-Sleep -Milliseconds 200
    Write-Host (Center "Secret unlocked!") -ForegroundColor Magenta
    Write-Host ""

    Show-Cursor
}

function global:phantom-secrets {
    Save-PhantomSecret "secrets"
    Write-Host ""
    Write-Host "  === SECRETS DISCOVERED ===" -ForegroundColor Yellow
    Write-Host ""

    $total = 3
    $found = $Script:SecretsFound.Count

    $p = if ($Script:CurrentTheme.Name -eq "Unknown") { "unknown" } else { "phantom" }
    if ("chosen" -in $Script:SecretsFound) {
        Write-Host "  [+] $p-chosen  — The Chosen One" -ForegroundColor Green
    } else {
        Write-Host "  [?] ???" -ForegroundColor DarkGray
    }

    if ("2829" -in $Script:SecretsFound) {
        Write-Host "  [+] $p-2829    — Creator's Mark" -ForegroundColor Green
    } else {
        Write-Host "  [?] ???" -ForegroundColor DarkGray
    }

    if ("secrets" -in $Script:SecretsFound) {
        Write-Host "  [+] $p-secrets — Secret Hunter" -ForegroundColor Green
    } else {
        Write-Host "  [?] ???" -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "  $found/$total secrets found" -ForegroundColor DarkGray
    if ($found -ge $total) {
        Write-Host "  $($Script:Symbols.HighVoltage) ACHIEVEMENT UNLOCKED — Master Secret Hunter $($Script:Symbols.HighVoltage)`n" -ForegroundColor Yellow
    } else {
        Write-Host ""
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════

Set-PhantomPrompt
Set-SmartSuggestions
Start-PhantomTerminal
