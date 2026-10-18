# Phantom Terminal v4.2.3 - Rigorous PowerShell Engine Test Suite
$ErrorActionPreference = "Stop"

$PassCount = 0
$FailCount = 0

function Assert-Test {
    param(
        [string]$Name,
        [bool]$Condition,
        [string]$Details = ""
    )
    if ($Condition) {
        Write-Host "  [PASS] $Name" -ForegroundColor Green
        $script:PassCount++
    } else {
        Write-Host "  [FAIL] $Name : $Details" -ForegroundColor Red
        $script:FailCount++
    }
}

Write-Host "`n=== Testing Phantom Terminal PowerShell v4.2.3 Engine ===`n" -ForegroundColor Cyan

# Test 1: Syntax / AST Parsing
$scripts = @("PhantomStartup.ps1", "install.ps1", "tests\test_engine.ps1")
foreach ($s in $scripts) {
    $path = Join-Path $PSScriptRoot "..\$s"
    $errors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$errors)
    Assert-Test -Name "Syntax validation for $s" -Condition ($errors.Count -eq 0) -Details ($errors -join "; ")
}

# Dot-source production PhantomStartup.ps1 in quiet mode
$env:PHANTOM_QUIET = "1"
$env:PHANTOM_SESSION_ACTIVE = "1"
$startupScript = Join-Path $PSScriptRoot "..\PhantomStartup.ps1"
. $startupScript

# Test 2: Production SemVer Comparison Logic (Test-PhantomVersionGreater)
Assert-Test -Name "Production SemVer: 4.0.0 > 3.7.0" -Condition (Test-PhantomVersionGreater "4.0.0" "3.7.0")
Assert-Test -Name "Production SemVer: 3.10.0 > 3.9.0 (Double-digit minor bug fix)" -Condition (Test-PhantomVersionGreater "3.10.0" "3.9.0")
Assert-Test -Name "Production SemVer: 3.7.1 > 3.7.0" -Condition (Test-PhantomVersionGreater "3.7.1" "3.7.0")
Assert-Test -Name "Production SemVer: 3.7.0 not > 3.7.0" -Condition (-not (Test-PhantomVersionGreater "3.7.0" "3.7.0"))
Assert-Test -Name "Production SemVer with v prefix: v4.0.0 > v3.7.0" -Condition (Test-PhantomVersionGreater "v4.0.0" "v3.7.0")
Assert-Test -Name "Production SemVer: release 4.0.0 > pre-release 4.0.0-beta" -Condition (Test-PhantomVersionGreater "4.0.0" "4.0.0-beta")
Assert-Test -Name "Production SemVer: 4.0.0-beta not > 4.0.0" -Condition (-not (Test-PhantomVersionGreater "4.0.0-beta" "4.0.0"))
Assert-Test -Name "Production SemVer: 4.0.0-beta.2 > 4.0.0-beta.1" -Condition (Test-PhantomVersionGreater "4.0.0-beta.2" "4.0.0-beta.1")
Assert-Test -Name "Production SemVer: 4.0.0-beta.10 > 4.0.0-beta.2 (Numeric prerelease)" -Condition (Test-PhantomVersionGreater "4.0.0-beta.10" "4.0.0-beta.2")
Assert-Test -Name "Production SemVer: 4.0.0-beta.2 not > 4.0.0-beta.10" -Condition (-not (Test-PhantomVersionGreater "4.0.0-beta.2" "4.0.0-beta.10"))
Assert-Test -Name "Production SemVer: 4.0.0 > 4.0.0-beta.10" -Condition (Test-PhantomVersionGreater "4.0.0" "4.0.0-beta.10")

# Test 3: Production Secrets Persistence
$tempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid().ToString())
[System.IO.Directory]::CreateDirectory($tempDir) | Out-Null
$testSecretsFile = Join-Path $tempDir ".secrets"
$origSecretsFile = $Script:SecretsFile
$Script:SecretsFile = $testSecretsFile

try {
    Save-PhantomSecret "chosen"
    Save-PhantomSecret "2829"
    Save-PhantomSecret "chosen" # duplicate
    $loaded = Get-PhantomSecrets
    Assert-Test -Name "Production Secrets: JSON persistence saves, reloads, and de-duplicates" -Condition ($loaded -contains "chosen" -and $loaded -contains "2829" -and $loaded.Count -eq 2)
} finally {
    $Script:SecretsFile = $origSecretsFile
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}

# Test 4: Production AI Agent Guard Detection
$origQuiet    = $env:PHANTOM_QUIET
$origForce    = $env:PHANTOM_FORCE
$origUnkQuiet = $env:UNKNOWN_QUIET
$origUnkForce = $env:UNKNOWN_FORCE
$origCI       = $env:CI

try {
    $env:CI = "true"
    $env:PHANTOM_QUIET = $null
    $env:PHANTOM_FORCE = $null
    $env:UNKNOWN_QUIET = $null
    $env:UNKNOWN_FORCE = $null
    Assert-Test -Name "Production Agent Guard: Detects CI" -Condition (Test-PhantomAgentGuard)

    $env:CI = $null
    $env:PHANTOM_QUIET = "1"
    Assert-Test -Name "Production Agent Guard: Detects PHANTOM_QUIET=1" -Condition (Test-PhantomAgentGuard)

    $env:PHANTOM_QUIET = $null
    $env:UNKNOWN_QUIET = "1"
    Assert-Test -Name "Production Agent Guard: Detects UNKNOWN_QUIET=1" -Condition (Test-PhantomAgentGuard)

    $env:CI = "true"
    $env:UNKNOWN_QUIET = $null
    $env:PHANTOM_FORCE = "1"
    Assert-Test -Name "Production Agent Guard: PHANTOM_FORCE=1 overrides CI" -Condition (-not (Test-PhantomAgentGuard))

    $env:PHANTOM_FORCE = $null
    $env:UNKNOWN_FORCE = "1"
    Assert-Test -Name "Production Agent Guard: UNKNOWN_FORCE=1 overrides CI" -Condition (-not (Test-PhantomAgentGuard))
} finally {
    $env:PHANTOM_QUIET = $origQuiet
    $env:PHANTOM_FORCE = $origForce
    $env:UNKNOWN_QUIET = $origUnkQuiet
    $env:UNKNOWN_FORCE = $origUnkForce
    $env:CI = $origCI
}

# Test 5: Cyberpunk Stealth Mode
$origStealth = $Script:Config.StealthMode
$origTheme = $Script:Config.Theme
$origCurrTheme = $Script:CurrentTheme
try {
    $Script:Config.StealthMode = $true
    $Script:Config.Theme = "Phantom"
    $Script:CurrentTheme = $Script:Themes["Phantom"]
    $stealthSpecs = Get-SystemMetrics
    Assert-Test -Name "Stealth Mode: Spoofs Operator from Phantom theme list" -Condition ($stealthSpecs.Operator -in $Script:Themes["Phantom"].Operators)
    Assert-Test -Name "Stealth Mode: Spoofs Host from Phantom theme list" -Condition ($stealthSpecs.Host -in $Script:Themes["Phantom"].Hosts)
    Assert-Test -Name "Stealth Mode: Spoofs System from Phantom theme list" -Condition ($stealthSpecs.System -in $Script:Themes["Phantom"].Systems)

    $Script:Config.Theme = "Unknown"
    $Script:CurrentTheme = $Script:Themes["Unknown"]
    $unkSpecs = Get-SystemMetrics
    Assert-Test -Name "Stealth Mode: Spoofs Operator from Unknown theme list" -Condition ($unkSpecs.Operator -in $Script:Themes["Unknown"].Operators)
    Assert-Test -Name "Stealth Mode: Spoofs Host from Unknown theme list" -Condition ($unkSpecs.Host -in $Script:Themes["Unknown"].Hosts)
} finally {
    $Script:Config.StealthMode = $origStealth
    $Script:Config.Theme = $origTheme
    $Script:CurrentTheme = $origCurrTheme
}

# Test 6: Production Universal History Filter (Calling production Test-PhantomSensitiveCommand)
$historyTestCases = @(
    @{ Cmd = "git status"; ShouldPass = $true },
    @{ Cmd = "export AWS_SECRET_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE"; ShouldPass = $false },
    @{ Cmd = "npm run build"; ShouldPass = $true },
    @{ Cmd = "curl -u user:password123 https://example.com"; ShouldPass = $false },
    @{ Cmd = "cat ~/.ssh/id_rsa"; ShouldPass = $false },
    @{ Cmd = "git commit -m 'feat: auth login'"; ShouldPass = $true },
    @{ Cmd = "git commit -m 'give credit to author'"; ShouldPass = $true },
    @{ Cmd = "kubectl get secret my-secret"; ShouldPass = $true },
    @{ Cmd = "docker run -e API_KEY=xyz123"; ShouldPass = $false },
    @{ Cmd = "docker ps"; ShouldPass = $true }
)
$historyFilterPassed = $true
foreach ($tc in $historyTestCases) {
    $isSensitive = Test-PhantomSensitiveCommand -CommandLine $tc.Cmd
    if ($tc.ShouldPass -and $isSensitive) {
        $historyFilterPassed = $false
        Write-Warning "False positive: '$($tc.Cmd)' was incorrectly blocked!"
    } elseif (-not $tc.ShouldPass -and -not $isSensitive) {
        $historyFilterPassed = $false
        Write-Warning "False negative: '$($tc.Cmd)' was incorrectly permitted!"
    }
}
Assert-Test -Name "Universal History: Production credential filter blocks secrets & permits safe commands" -Condition $historyFilterPassed

# Test 7: Production Release Checksum Verification (SHA256SUMS)
$sumsPath = Join-Path $PSScriptRoot "..\SHA256SUMS"
$allSumsValid = $true
if (Test-Path $sumsPath) {
    Get-Content $sumsPath | ForEach-Object {
        $parts = $_ -split '\s+'
        if ($parts.Length -ge 2 -and $parts[0] -match '^[a-f0-9]{64}$') {
            $expected = $parts[0].Trim().ToLower()
            $fileName = $parts[1].Trim()
            $filePath = Join-Path $PSScriptRoot "..\$fileName"
            if (Test-Path $filePath) {
                $actual = (Get-FileHash -Path $filePath -Algorithm SHA256).Hash.ToLower()
                if ($actual -ne $expected) { $allSumsValid = $false }
            } else {
                $allSumsValid = $false
            }
        }
    }
} else {
    $allSumsValid = $false
}
Assert-Test -Name "Release Integrity: All release assets match SHA256SUMS manifest" -Condition $allSumsValid

# Test 8: Cross-Platform Path Resolution (Fix F-05)
$expectedConfigBase = Join-Path $Script:UserHome ".phantom-terminal"
Assert-Test -Name "Cross-Platform Path: Engine resolves config directory from user home without USERPROFILE dependency" -Condition ($Script:ConfigDir -eq $expectedConfigBase -and -not [string]::IsNullOrEmpty($Script:ConfigDir))

# Test 9: End-to-End Fail-Closed Installer Transactional Integration Tests (Fix F-01, F-02, F-03, F-04)
$testSandbox = Join-Path ([System.IO.Path]::GetTempPath()) "phantom_test_sandbox_$PID"
$fakeHome = Join-Path $testSandbox "home"
$fakeProfile = Join-Path $fakeHome "profile.ps1"
$fakeConfig = Join-Path $fakeHome ".phantom-terminal"
New-Item -ItemType Directory -Path $fakeConfig -Force | Out-Null

$activeEngine = Join-Path $fakeConfig "PhantomStartup.ps1"
Set-Content -Path $activeEngine -Value "# PHANTOM_ACTIVE_ENGINE_V4_ORIGINAL" -Encoding UTF8

$fakeRepo = Join-Path $testSandbox "repo"
New-Item -ItemType Directory -Path $fakeRepo -Force | Out-Null
Copy-Item (Join-Path $PSScriptRoot "..\install.ps1") (Join-Path $fakeRepo "install.ps1") -Force

# Integration Scenario A: Corrupted local payload must fail closed and leave active installation untouched
Set-Content -Path (Join-Path $fakeRepo "PhantomStartup.ps1") -Value "function BrokenSyntax { { { {" -Encoding UTF8

$origPhantomHome = $env:PHANTOM_HOME
$origPhantomProfile = $env:PHANTOM_PROFILE
$origCI = $env:CI
$installerFailedClosed = $false
try {
    $env:PHANTOM_HOME = $fakeHome
    $env:PHANTOM_PROFILE = $fakeProfile
    $env:CI = "true"
    & (Join-Path $fakeRepo "install.ps1") >$null 2>&1
    if ($LASTEXITCODE -ne 0) { $installerFailedClosed = $true }
} catch {
    $installerFailedClosed = $true
} finally {
    $env:PHANTOM_HOME = $origPhantomHome
    $env:PHANTOM_PROFILE = $origPhantomProfile
    $env:CI = $origCI
}

$enginePreservedAfterCorrupt = (Get-Content $activeEngine -Raw -ErrorAction SilentlyContinue) -match "PHANTOM_ACTIVE_ENGINE_V4_ORIGINAL"
$stagingCleanedUp = @(Get-ChildItem -Path $fakeConfig -Filter "*.stage.*" -ErrorAction SilentlyContinue).Count -eq 0

Assert-Test -Name "Installer Integrity: Real installer aborts on corrupt local payload and preserves active engine" -Condition ($installerFailedClosed -and $enginePreservedAfterCorrupt -and $stagingCleanedUp)

# Integration Scenario B: Valid local payload passes validation and promotes atomically
Copy-Item (Join-Path $PSScriptRoot "..\PhantomStartup.ps1") (Join-Path $fakeRepo "PhantomStartup.ps1") -Force
$installSuccess = $false
try {
    $env:PHANTOM_HOME = $fakeHome
    $env:PHANTOM_PROFILE = $fakeProfile
    $env:CI = "true"
    $LASTEXITCODE = 0
    & (Join-Path $fakeRepo "install.ps1") >$null 2>&1
    $installSuccess = ($LASTEXITCODE -eq 0)
} catch {
    $installSuccess = $false
} finally {
    $LASTEXITCODE = 0
    $env:PHANTOM_HOME = $origPhantomHome
    $env:PHANTOM_PROFILE = $origPhantomProfile
    $env:CI = $origCI
}

$enginePromoted = (Get-Content $activeEngine -Raw -ErrorAction SilentlyContinue) -match '\$Script:Version\s*=\s*"4\.2\.3"'
$profileConfigured = (Get-Content $fakeProfile -Raw -ErrorAction SilentlyContinue) -match "Phantom Terminal START"

Assert-Test -Name "Installer Integrity: Real installer validates and atomically promotes valid payload" -Condition ($installSuccess -and $enginePromoted -and $profileConfigured)

# Integration Scenario C: Strict fail-closed remote verification aborts on missing manifest and preserves active engine
$fakeRepoRemote = Join-Path $testSandbox "repo_remote"
New-Item -ItemType Directory -Path $fakeRepoRemote -Force | Out-Null
Copy-Item (Join-Path $PSScriptRoot "..\install.ps1") (Join-Path $fakeRepoRemote "install.ps1") -Force
$scriptRemoteContent = Get-Content (Join-Path $fakeRepoRemote "install.ps1") -Raw
$scriptRemoteContent = $scriptRemoteContent -replace '\$RepoUrl = .*', '$RepoUrl = "http://127.0.0.1:9"'
Set-Content -Path (Join-Path $fakeRepoRemote "install.ps1") -Value $scriptRemoteContent -Encoding UTF8

$remoteFailedClosed = $false
try {
    $env:PHANTOM_HOME = $fakeHome
    $env:PHANTOM_PROFILE = $fakeProfile
    $env:CI = "true"
    & (Join-Path $fakeRepoRemote "install.ps1") >$null 2>&1
    if ($LASTEXITCODE -ne 0) { $remoteFailedClosed = $true }
} catch {
    $remoteFailedClosed = $true
} finally {
    $env:PHANTOM_HOME = $origPhantomHome
    $env:PHANTOM_PROFILE = $origPhantomProfile
    $env:CI = $origCI
}

$engineIntactAfterRemoteFail = (Get-Content $activeEngine -Raw -ErrorAction SilentlyContinue) -match '\$Script:Version\s*=\s*"4\.2\.3"'
Assert-Test -Name "Installer Integrity: Real installer fails closed on remote manifest/network failure" -Condition ($remoteFailedClosed -and $engineIntactAfterRemoteFail)

# Integration Scenario D: Configuration recovery preserves malformed existing settings before rewriting
$corruptConfigPath = Join-Path $fakeConfig "config.json"
Set-Content -Path $corruptConfigPath -Value "{ `"Theme`": `"Unknown`", INVALID_JSON_GAP " -Encoding UTF8
$configRecoverySuccess = $false
try {
    $env:PHANTOM_HOME = $fakeHome
    $env:PHANTOM_PROFILE = $fakeProfile
    $env:CI = "true"
    $LASTEXITCODE = 0
    & (Join-Path $fakeRepo "install.ps1") >$null 2>&1
    $configRecoverySuccess = ($LASTEXITCODE -eq 0)
} catch {
    $configRecoverySuccess = $false
} finally {
    $env:PHANTOM_HOME = $origPhantomHome
    $env:PHANTOM_PROFILE = $origPhantomProfile
    $env:CI = $origCI
}
$corruptBackupExists = @(Get-ChildItem -Path $fakeConfig -Filter "config.json.corrupt.*" -ErrorAction SilentlyContinue).Count -gt 0
$newConfigValid = $false
try {
    $parsedNew = Get-Content $corruptConfigPath -Raw | ConvertFrom-Json
    if ($parsedNew -and $parsedNew.Theme) { $newConfigValid = $true }
} catch {}

Assert-Test -Name "Installer Recovery: Malformed existing config is backed up to .corrupt file before rewrite" -Condition ($configRecoverySuccess -and $corruptBackupExists -and $newConfigValid)

# Test 10: Unknown-Terminal Peer Parity and Codename Krypton
Assert-Test -Name "Codename: Script defines Krypton codename" -Condition ($Script:Codename -eq "Krypton")

$requiredAliases = @(
    "unknown-help", "unknown-dash", "unknown-theme", "unknown-stealth",
    "unknown-search", "unknown-history", "unknown-matrix", "phantom-live",
    "unknown-live", "phantom-top", "unknown-top", "unknown-reload",
    "unknown-config", "unknown-update", "unknown-changelog", "unknown-secrets",
    "unknown-chosen", "unknown-2829"
)
$allAliasesPresent = $true
foreach ($alias in $requiredAliases) {
    if (-not (Get-Command $alias -ErrorAction SilentlyContinue)) {
        $allAliasesPresent = $false
        Write-Warning "Missing alias or command: $alias"
    }
}
Assert-Test -Name "Unknown Parity: All 18 peer aliases and commands registered" -Condition $allAliasesPresent

Remove-Item -Recurse -Force $testSandbox -ErrorAction SilentlyContinue

Write-Host "`nResults: $script:PassCount Passed, $script:FailCount Failed`n"
if ($script:FailCount -gt 0) { exit 1 } else { exit 0 }
