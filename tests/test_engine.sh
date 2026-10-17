#!/usr/bin/env bash
# Phantom Terminal v4.0.0 - Rigorous Bash Engine Test Suite
set -u

PASS_COUNT=0
FAIL_COUNT=0

assert_test() {
    local name="$1"
    local condition="$2"
    local details="${3:-}"
    if [[ "$condition" == "true" ]]; then
        printf "  \e[32m[PASS]\e[0m %s\n" "$name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        printf "  \e[31m[FAIL]\e[0m %s : %s\n" "$name" "$details"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

echo ""
echo "=== Testing Phantom Terminal Bash v4.0.0 Engine ==="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")/.." && pwd)"

# Test 1: Syntax Checks
if bash -n "$SCRIPT_DIR/PhantomStartup.sh" 2>/dev/null; then
    assert_test "Syntax check: PhantomStartup.sh" "true"
else
    assert_test "Syntax check: PhantomStartup.sh" "false" "bash -n returned error"
fi

if bash -n "$SCRIPT_DIR/install.sh" 2>/dev/null; then
    assert_test "Syntax check: install.sh" "true"
else
    assert_test "Syntax check: install.sh" "false" "bash -n returned error"
fi

if bash -n "$SCRIPT_DIR/tests/test_engine.sh" 2>/dev/null; then
    assert_test "Syntax check: test_engine.sh" "true"
else
    assert_test "Syntax check: test_engine.sh" "false" "bash -n returned error"
fi

# Load production script in quiet mode
export PHANTOM_QUIET=1
export PHANTOM_SESSION_ACTIVE=1
export HOME="${HOME:-/tmp}"
# Sourcing PhantomStartup.sh to get actual production functions
# shellcheck disable=SC1090
. "$SCRIPT_DIR/PhantomStartup.sh"

# Sourcing install.sh to get clean_profile_entries function
# shellcheck disable=SC1090
. "$SCRIPT_DIR/install.sh"

# Test 2: Production Visual Length Function (_vlen)
plain_len=$(_vlen "Hello World")
[[ "$plain_len" -eq 11 ]] && assert_test "Production _vlen: plain ASCII length (11)" "true" || assert_test "Production _vlen: plain ASCII" "false" "got $plain_len"

ansi_text=$'\e[38;5;129mPhantom\e[0m \e[1;37mTerminal\e[0m'
ansi_len=$(_vlen "$ansi_text")
[[ "$ansi_len" -eq 16 ]] && assert_test "Production _vlen: strips ANSI escape codes (16)" "true" || assert_test "Production _vlen: strips ANSI" "false" "got $ansi_len"

box_text="╔══════╗"
box_len=$(_vlen "$box_text")
[[ "$box_len" -eq 8 ]] && assert_test "Production _vlen: counts UTF-8 box characters as single visual cells (8)" "true" || assert_test "Production _vlen: box chars" "false" "got $box_len"

# Test under LC_ALL=C locale
c_len=$(LC_ALL=C _vlen "╔══════╗")
[[ "$c_len" -eq 8 ]] && assert_test "Production _vlen: preserves visual width in LC_ALL=C (8)" "true" || assert_test "Production _vlen: LC_ALL=C" "false" "got $c_len"

# Test 3: Production SemVer Comparison (version_gt)
version_gt "4.0.0" "3.7.0" && assert_test "Production SemVer: 4.0.0 > 3.7.0" "true" || assert_test "Production SemVer: 4.0.0 > 3.7.0" "false"
version_gt "3.10.0" "3.9.0" && assert_test "Production SemVer: 3.10.0 > 3.9.0 (Double-digit minor bug fix)" "true" || assert_test "Production SemVer: 3.10.0 > 3.9.0" "false"
version_gt "3.7.1" "3.7.0" && assert_test "Production SemVer: 3.7.1 > 3.7.0" "true" || assert_test "Production SemVer: 3.7.1 > 3.7.0" "false"
version_gt "3.7.0" "3.7.0" && assert_test "Production SemVer: 3.7.0 not > 3.7.0" "false" || assert_test "Production SemVer: 3.7.0 not > 3.7.0" "true"
version_gt "v4.0.0" "v3.7.0" && assert_test "Production SemVer with v prefix: v4.0.0 > v3.7.0" "true" || assert_test "Production SemVer with v prefix" "false"
version_gt "4.0.0" "4.0.0-beta" && assert_test "Production SemVer: release 4.0.0 > pre-release 4.0.0-beta" "true" || assert_test "Production SemVer: 4.0.0 > 4.0.0-beta" "false"
version_gt "4.0.0-beta" "4.0.0" && assert_test "Production SemVer: 4.0.0-beta not > 4.0.0" "false" || assert_test "Production SemVer: 4.0.0-beta not > 4.0.0" "true"
version_gt "4.0.0-beta.2" "4.0.0-beta.1" && assert_test "Production SemVer: 4.0.0-beta.2 > 4.0.0-beta.1" "true" || assert_test "Production SemVer: 4.0.0-beta.2 > 4.0.0-beta.1" "false"
version_gt "4.0.0-beta.10" "4.0.0-beta.2" && assert_test "Production SemVer: 4.0.0-beta.10 > 4.0.0-beta.2 (Numeric prerelease)" "true" || assert_test "Production SemVer: 4.0.0-beta.10 > 4.0.0-beta.2" "false"
version_gt "4.0.0-beta.2" "4.0.0-beta.10" && assert_test "Production SemVer: 4.0.0-beta.2 not > 4.0.0-beta.10" "false" || assert_test "Production SemVer: 4.0.0-beta.2 not > 4.0.0-beta.10" "true"
version_gt "4.0.0" "4.0.0-beta.10" && assert_test "Production SemVer: 4.0.0 > 4.0.0-beta.10" "true" || assert_test "Production SemVer: 4.0.0 > 4.0.0-beta.10" "false"

# Test 4: Production Profile Cleanup Idempotency
temp_profile=$(mktemp)
cat > "$temp_profile" << 'EOF'
# User custom line before
export FOO="bar"
alias my_custom_command="echo hello"

# >>> Phantom Terminal START >>>
# Phantom Terminal
if [ -f "$HOME/.phantom-terminal/PhantomStartup.sh" ]; then
    source "$HOME/.phantom-terminal/PhantomStartup.sh"
fi
# <<< Phantom Terminal END <<<

# Legacy block to clean:
if [ -f "$HOME/.phantom-terminal/PhantomStartup.sh" ]; then
    source "$HOME/.phantom-terminal/PhantomStartup.sh"
fi

# User custom line after (MUST NOT BE DELETED)
alias phantom_notes="cat ~/notes.txt"
EOF

# Call production clean_profile_entries function from install.sh
clean_profile_entries "$temp_profile"

if grep -q 'alias phantom_notes="cat ~/notes.txt"' "$temp_profile"; then
    assert_test "Production Profile cleanup: Preserves user comments containing 'phantom'" "true"
else
    assert_test "Production Profile cleanup: Preserves user comments containing 'phantom'" "false" "user line was deleted"
fi

if grep -q 'PhantomStartup.sh' "$temp_profile"; then
    assert_test "Production Profile cleanup: Removed delimited and legacy blocks" "false" "block still present"
else
    assert_test "Production Profile cleanup: Removed delimited and legacy blocks" "true"
fi

if grep -q 'export FOO="bar"' "$temp_profile"; then
    assert_test "Production Profile cleanup: Preserves unrelated user environment variables" "true"
else
    assert_test "Production Profile cleanup: Preserves unrelated user environment variables" "false"
fi
rm -f "$temp_profile" "${temp_profile}.phantom-backup."*

# Test 5: Production AI Agent Guard Detection
(
    export CI="true"
    unset PHANTOM_FORCE PHANTOM_QUIET UNKNOWN_FORCE UNKNOWN_QUIET
    _is_agent_session
) && assert_test "Production Agent Guard: Detects CI" "true" || assert_test "Production Agent Guard: Detects CI" "false"

(
    export PHANTOM_QUIET="1"
    unset CI PHANTOM_FORCE UNKNOWN_FORCE UNKNOWN_QUIET
    _is_agent_session
) && assert_test "Production Agent Guard: Detects PHANTOM_QUIET=1" "true" || assert_test "Production Agent Guard: Detects PHANTOM_QUIET=1" "false"

(
    export UNKNOWN_QUIET="1"
    unset CI PHANTOM_FORCE PHANTOM_QUIET UNKNOWN_FORCE
    _is_agent_session
) && assert_test "Production Agent Guard: Detects UNKNOWN_QUIET=1" "true" || assert_test "Production Agent Guard: Detects UNKNOWN_QUIET=1" "false"

(
    unset CI PHANTOM_QUIET PHANTOM_FORCE UNKNOWN_QUIET UNKNOWN_FORCE GITHUB_ACTIONS CURSOR_TRACE CLAUDE_CODE
    _is_agent_session
) && assert_test "Production Agent Guard: Detects non-interactive pipe/script" "true" || assert_test "Production Agent Guard: Detects non-interactive pipe/script" "false"

(
    export CI="true"
    export PHANTOM_FORCE="1"
    unset UNKNOWN_FORCE
    _is_agent_session
) && assert_test "Production Agent Guard: PHANTOM_FORCE=1 overrides guard" "false" || assert_test "Production Agent Guard: PHANTOM_FORCE=1 overrides guard" "true"

(
    export CI="true"
    export UNKNOWN_FORCE="1"
    unset PHANTOM_FORCE
    _is_agent_session
) && assert_test "Production Agent Guard: UNKNOWN_FORCE=1 overrides guard" "false" || assert_test "Production Agent Guard: UNKNOWN_FORCE=1 overrides guard" "true"

# Test 6: Production Secrets Persistence
TEST_SECRETS_FILE=$(mktemp)
SECRETS_FILE="$TEST_SECRETS_FILE"
SECRETS_FOUND=()
_save_secret "test_secret_1"
_save_secret "test_secret_2"
_save_secret "test_secret_1" # duplicate
_load_secrets
[[ "${#SECRETS_FOUND[@]}" -eq 2 ]] && assert_test "Production Secrets: Persisted and de-duplicated" "true" || assert_test "Production Secrets" "false" "count=${#SECRETS_FOUND[@]}"
rm -f "$TEST_SECRETS_FILE"

# Test 7: Production Universal History Search & Sanitization (Testing production _filter_phantom_history_cmd)
TEST_HIST_DIR=$(mktemp -d)
cat > "$TEST_HIST_DIR/.bash_history" << 'EOF'
: 1729158000:0;git status
: 1729158001:0;export AWS_SECRET_ACCESS_KEY="AKIAIOSFODNN7EXAMPLE"
: 1729158002:0;cat ~/.ssh/id_rsa
: 1729158003:0;git commit -m "feat: auth login"
: 1729158004:0;echo "password=supersecret"
: 1729158005:0;docker ps
: 1729158006:0;curl -H "Authorization: Bearer sec-token-123" https://example.com
: 1729158007:0;git commit -m "give credit to author"
: 1729158008:0;kubectl get secret my-secret
: 1729158009:0;git status
EOF

(
    export HOME="$TEST_HIST_DIR"
    search_out=$(phantom-search "git")
    [[ "$search_out" == *"git status"* && "$search_out" == *"git commit"* ]] && \
    [[ "$search_out" != *"AKIAIOSFODNN7EXAMPLE"* && "$search_out" != *"id_rsa"* && "$search_out" != *"supersecret"* && "$search_out" != *"sec-token-123"* ]] && \
    [[ "$search_out" != *": 172915800"* ]]
) && assert_test "Universal History: Query filter matches, strips zsh prefixes, and masks credentials" "true" || assert_test "Universal History" "false" "output: $search_out"

# Test 7b: False-positive and false-negative tests using production _filter_phantom_history_cmd
hist_test_ok=true
if ! _filter_phantom_history_cmd 'git commit -m "feat: auth login"' &>/dev/null; then
    hist_test_ok=false
fi
if ! _filter_phantom_history_cmd 'git commit -m "give credit to author"' &>/dev/null; then
    hist_test_ok=false
fi
if ! _filter_phantom_history_cmd 'kubectl get secret my-secret' &>/dev/null; then
    hist_test_ok=false
fi
if _filter_phantom_history_cmd 'export AWS_SECRET_ACCESS_KEY=secretval123' &>/dev/null; then
    hist_test_ok=false
fi
if _filter_phantom_history_cmd 'cat ~/.ssh/id_rsa' &>/dev/null; then
    hist_test_ok=false
fi
if _filter_phantom_history_cmd 'curl -u user:pass123 https://example.com' &>/dev/null; then
    hist_test_ok=false
fi
assert_test "Universal History: Production filter permits safe commands & blocks credentials" "$hist_test_ok"

rm -rf "$TEST_HIST_DIR"

# Test 8: Production Release Checksum Verification (SHA256SUMS)
if command -v sha256sum &>/dev/null; then
    (cd "$SCRIPT_DIR" && sha256sum -c SHA256SUMS &>/dev/null) && \
        assert_test "Release Integrity: All release assets match SHA256SUMS manifest" "true" || \
        assert_test "Release Integrity" "false"
elif command -v shasum &>/dev/null; then
    (cd "$SCRIPT_DIR" && shasum -a 256 -c SHA256SUMS &>/dev/null) && \
        assert_test "Release Integrity: All release assets match SHA256SUMS manifest" "true" || \
        assert_test "Release Integrity" "false"
fi

# Test 9: End-to-End Fail-Closed Installer Transactional Integration Tests (Fix F-01, F-02, F-03, F-04)
SANDBOX_DIR=$(mktemp -d)
mkdir -p "$SANDBOX_DIR/home/.phantom-terminal"
ACTIVE_ENGINE="$SANDBOX_DIR/home/.phantom-terminal/PhantomStartup.sh"
echo "# PHANTOM_ACTIVE_ENGINE_V4_ORIGINAL" > "$ACTIVE_ENGINE"

mkdir -p "$SANDBOX_DIR/repo"
cp "$SCRIPT_DIR/install.sh" "$SANDBOX_DIR/repo/install.sh"

# Integration Scenario A: Corrupted local payload must fail closed and leave active installation untouched
echo "if broken syntax { {" > "$SANDBOX_DIR/repo/PhantomStartup.sh"

(HOME="$SANDBOX_DIR/home" CI=true bash "$SANDBOX_DIR/repo/install.sh" &>/dev/null)
exit_corrupt=$?

preserved_corrupt=false
if grep -q "PHANTOM_ACTIVE_ENGINE_V4_ORIGINAL" "$ACTIVE_ENGINE" 2>/dev/null; then
    preserved_corrupt=true
fi
stages_cleaned=$(find "$SANDBOX_DIR/home/.phantom-terminal" -name "*.stage.*" 2>/dev/null | wc -l)

[[ $exit_corrupt -ne 0 && "$preserved_corrupt" == "true" && $stages_cleaned -eq 0 ]] && \
    assert_test "Installer Integrity: Real installer aborts on corrupt local payload and preserves active engine" "true" || \
    assert_test "Installer Integrity" "false" "corrupted local install did not abort safely"

# Integration Scenario B: Valid local payload passes validation and promotes atomically
cp "$SCRIPT_DIR/PhantomStartup.sh" "$SANDBOX_DIR/repo/PhantomStartup.sh"

(HOME="$SANDBOX_DIR/home" CI=true bash "$SANDBOX_DIR/repo/install.sh" &>/dev/null)
exit_valid=$?

promoted_valid=false
if grep -q 'SCRIPT_VERSION="4.0.0"' "$ACTIVE_ENGINE" 2>/dev/null; then
    promoted_valid=true
fi
profile_configured=false
if grep -q "Phantom Terminal START" "$SANDBOX_DIR/home/.bashrc" 2>/dev/null; then
    profile_configured=true
fi

[[ $exit_valid -eq 0 && "$promoted_valid" == "true" && "$profile_configured" == "true" ]] && \
    assert_test "Installer Integrity: Real installer validates and atomically promotes valid payload" "true" || \
    assert_test "Installer Integrity" "false" "valid local install failed to deploy"

# Integration Scenario C: Strict fail-closed remote verification aborts on network/manifest failure
mkdir -p "$SANDBOX_DIR/repo_remote"
cp "$SCRIPT_DIR/install.sh" "$SANDBOX_DIR/repo_remote/install.sh"
# Change REPO_URL to an unreachable local address to test remote failure
sed -i.bak 's|^REPO_URL=.*|REPO_URL="http://127.0.0.1:9"|' "$SANDBOX_DIR/repo_remote/install.sh" 2>/dev/null || \
    sed -i 's|^REPO_URL=.*|REPO_URL="http://127.0.0.1:9"|' "$SANDBOX_DIR/repo_remote/install.sh" 2>/dev/null || true

(HOME="$SANDBOX_DIR/home" CI=true bash "$SANDBOX_DIR/repo_remote/install.sh" &>/dev/null)
exit_remote_fail=$?

remote_preserved=false
if grep -q 'SCRIPT_VERSION="4.0.0"' "$ACTIVE_ENGINE" 2>/dev/null; then
    remote_preserved=true
fi

[[ $exit_remote_fail -ne 0 && "$remote_preserved" == "true" ]] && \
    assert_test "Installer Integrity: Real installer fails closed on remote manifest/network failure" "true" || \
    assert_test "Installer Integrity" "false" "remote failure did not abort safely"

# Test 10: Unknown-Terminal Peer Parity and Codename Krypton
[[ "$SCRIPT_CODENAME" == "Krypton" ]] &&     assert_test "Codename: Script defines Krypton codename" "true" ||     assert_test "Codename: Script defines Krypton codename" "false"

required_commands=(
    unknown-help unknown-dash unknown-theme unknown-stealth
    unknown-search unknown-history unknown-matrix phantom-live
    unknown-live phantom-top unknown-top unknown-reload
    unknown-config unknown-update unknown-changelog unknown-secrets
    unknown-chosen unknown-2829
)
all_cmds_present=true
for cmd in "${required_commands[@]}"; do
    if ! type "$cmd" &>/dev/null; then
        all_cmds_present=false
        break
    fi
done
assert_test "Unknown Parity: All 18 peer aliases and commands registered" "$all_cmds_present"

rm -rf "$SANDBOX_DIR"

echo ""
printf "Results: %d Passed, %d Failed\n\n" "$PASS_COUNT" "$FAIL_COUNT"
[[ $FAIL_COUNT -eq 0 ]] && exit 0 || exit 1
