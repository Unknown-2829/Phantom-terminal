#!/usr/bin/env bash
#
# Phantom Terminal - Universal Native Installer v4.1.0
# Cross-platform installer with automatic platform detection and ZERO external dependencies.
# Supports: Linux, macOS, Termux (Android), BSD
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.1.0/install.sh | bash
#

set -u

# ═══════════════════════════════════════════════════════════════════════════
# ERROR HANDLING
# ═══════════════════════════════════════════════════════════════════════════

INSTALL_ERRORS=0

handle_error() {
    local msg="$1"
    echo "  ${RED}[ERROR]${R} $msg" >&2
    INSTALL_ERRORS=$((INSTALL_ERRORS + 1))
}

cleanup_on_error() {
    if [[ $INSTALL_ERRORS -gt 0 ]]; then
        echo ""
        echo "  ${RED}Installation encountered $INSTALL_ERRORS error(s).${R}"
        echo "  ${GOLD}Please check the messages above and try again.${R}"
        exit 1
    fi
}

trap cleanup_on_error EXIT

# ═══════════════════════════════════════════════════════════════════════════
# COLORS
# ═══════════════════════════════════════════════════════════════════════════

E=$'\e'
PURPLE="${E}[38;5;129m"
CYAN="${E}[38;5;87m"
GREEN="${E}[38;5;118m"
BLUE="${E}[38;5;39m"
GOLD="${E}[38;5;220m"
RED="${E}[38;5;196m"
WHITE="${E}[1;37m"
GRAY="${E}[38;5;244m"
DGRAY="${E}[38;5;240m"
R="${E}[0m"

# ═══════════════════════════════════════════════════════════════════════════
# PLATFORM DETECTION
# ═══════════════════════════════════════════════════════════════════════════

detect_platform() {
    if [[ "$OSTYPE" == "linux-android"* ]] || [[ -n "${TERMUX_VERSION:-}" ]]; then
        echo "termux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

PLATFORM=$(detect_platform)

# ═══════════════════════════════════════════════════════════════════════════
# VARIABLES & PATHS
# ═══════════════════════════════════════════════════════════════════════════

INSTALL_VERSION="4.1.0"
INSTALL_CODENAME="Krypton"
RELEASE_TAG="v$INSTALL_VERSION"
REPO_URL="https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/$RELEASE_TAG"
EXPECTED_SHA256="4adf4188a5155d4726f70079922d53aa21cec7477a65abb1f9b40f4ceecb1f1b"
TARGET_HOME="${PHANTOM_HOME:-${UNKNOWN_HOME:-$HOME}}"
CONFIG_DIR="$TARGET_HOME/.phantom-terminal"
CONFIG_FILE="$CONFIG_DIR/config.json"
INSTALL_PATH="$CONFIG_DIR/PhantomStartup.sh"
LEGACY_PATH="$TARGET_HOME/PhantomStartup.sh"

detect_shell_profile() {
    if [[ -n "${PHANTOM_PROFILE:-}" ]]; then
        PROFILE="$PHANTOM_PROFILE"
        SHELL_TYPE="custom"
        return
    elif [[ -n "${UNKNOWN_PROFILE:-}" ]]; then
        PROFILE="$UNKNOWN_PROFILE"
        SHELL_TYPE="custom"
        return
    fi
    local login_shell="${SHELL##*/}"
    if [[ "$login_shell" == "zsh" ]] || [[ -n "${ZSH_VERSION:-}" ]]; then
        SHELL_TYPE="zsh"
        PROFILE="$TARGET_HOME/.zshrc"
    elif [[ "$login_shell" == "bash" ]] || [[ -n "${BASH_VERSION:-}" ]]; then
        SHELL_TYPE="bash"
        if [[ "$PLATFORM" == "macos" ]]; then
            [[ -f "$TARGET_HOME/.bash_profile" ]] && PROFILE="$TARGET_HOME/.bash_profile" || PROFILE="$TARGET_HOME/.bashrc"
        else
            PROFILE="$TARGET_HOME/.bashrc"
        fi
    else
        SHELL_TYPE="sh"
        PROFILE="$TARGET_HOME/.profile"
    fi
}

detect_shell_profile

# Safe profile cleaner: only removes delimited markers and exact legacy injection lines
clean_profile_entries() {
    local target_profile="$1"
    [[ ! -f "$target_profile" ]] && return 0

    local ts; ts=$(date +%Y%m%d%H%M%S 2>/dev/null || echo "$$")
    cp "$target_profile" "${target_profile}.phantom-backup.${ts}" 2>/dev/null || true

    local tmp="${target_profile}.tmp.$$"
    awk '
    BEGIN { in_phantom = 0; in_legacy = 0; buf_len = 0 }
    /# >>> Phantom Terminal START >>>/ { in_phantom = 1; next }
    /# <<< Phantom Terminal END <<</ { in_phantom = 0; next }
    in_phantom { next }

    in_legacy == 1 {
        if ($0 ~ /(source|\.)[[:space:]]+.*PhantomStartup\.sh/) {
            buf[2] = $0; in_legacy = 2; buf_len = 2; next
        } else {
            for (i = 1; i <= buf_len; i++) print buf[i]
            in_legacy = 0; buf_len = 0
        }
    }
    in_legacy == 2 {
        if ($0 ~ /^[[:space:]]*fi[[:space:]]*$/) {
            in_legacy = 0; buf_len = 0; next
        } else {
            for (i = 1; i <= buf_len; i++) print buf[i]
            in_legacy = 0; buf_len = 0
        }
    }

    /^[[:space:]]*if[[:space:]]+[[]+[[:space:]]+-[fs][[:space:]]+.*PhantomStartup\.sh/ {
        in_legacy = 1; buf[1] = $0; buf_len = 1; next
    }
    /^[[:space:]]*(source|\.)[[:space:]]+.*PhantomStartup\.sh/ { next }
    /^[[:space:]]*#[[:space:]]*Phantom Terminal[[:space:]]*$/ { next }

    { print }
    END { if (in_legacy > 0) { for (i = 1; i <= buf_len; i++) print buf[i] } }
    ' "$target_profile" > "$tmp" 2>/dev/null

    if [[ -s "$tmp" || ! -s "$target_profile" ]]; then
        mv -f "$tmp" "$target_profile"
    else
        rm -f "$tmp"
    fi
}
choose_shell_profile() {
    [[ "$NON_INTERACTIVE" == "true" ]] && return 0
    [[ ! -t 0 ]] && return 0

    local default_choice="1"
    local profile_choice
    local choices=()
    local labels=()

    if [[ "$PLATFORM" == "macos" ]]; then
        choices=("$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc")
        labels=("Zsh (~/.zshrc)" "Bash login (~/.bash_profile)" "Bash interactive (~/.bashrc)")
    else
        choices=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
        labels=("Bash (~/.bashrc)" "Zsh (~/.zshrc)" "POSIX shell (~/.profile)")
    fi

    local i=0
    for p in "${choices[@]}"; do
        i=$((i + 1))
        if [[ "$p" == "$PROFILE" ]]; then
            default_choice="$i"
            break
        fi
    done
    local default_label="${labels[$((default_choice - 1))]}"

    echo ""
    echo "  ${GOLD}[0] INSTALL TARGET${R}"
    i=0
    for lbl in "${labels[@]}"; do
        i=$((i + 1))
        echo "  ${CYAN}[$i]${R} $lbl"
    done

    if ! read -r -p "  Choose shell/profile [Enter: $default_label]: " profile_choice; then
        profile_choice=""
    fi
    profile_choice=${profile_choice:-$default_choice}

    if [[ "$profile_choice" =~ ^[1-9][0-9]*$ ]] && [[ "$profile_choice" -le "${#choices[@]}" ]]; then
        PROFILE="${choices[$((profile_choice - 1))]}"
        case "$PROFILE" in
            *".zshrc") SHELL_TYPE="zsh" ;;
            *".bash_profile"|*".bashrc") SHELL_TYPE="bash" ;;
            *) SHELL_TYPE="sh" ;;
        esac
        echo "  ${GREEN}[+]${WHITE} Target: $PROFILE${R}"
    else
        echo "  ${GOLD}[!]${WHITE} Using detected profile: $PROFILE${R}"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
# HEADER
# ═══════════════════════════════════════════════════════════════════════════

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    return 0 2>/dev/null || true
fi

clear 2>/dev/null || true
echo ""
title="PHANTOM TERMINAL INSTALLER v$INSTALL_VERSION \"$INSTALL_CODENAME\""
box_inner=56
pad=$(( box_inner - ${#title} ))
hl=$(( pad / 2 ))
hr=$(( pad - hl ))
hln=""
for ((i=0; i<box_inner; i++)); do hln+="═"; done
echo "${PURPLE}  ╔${hln}╗${R}"
printf "${PURPLE}  ║${CYAN}%*s%s%*s${PURPLE}║${R}\n" "$hl" "" "$title" "$hr" ""
echo "${PURPLE}  ╚${hln}╝${R}"
echo ""

case "$PLATFORM" in
    termux) echo "  ${GREEN}[+]${WHITE} Platform: Termux (Android)${R}" ;;
    macos)  echo "  ${GREEN}[+]${WHITE} Platform: macOS${R}" ;;
    linux)  echo "  ${GREEN}[+]${WHITE} Platform: Linux${R}" ;;
    *)      echo "  ${GOLD}[!]${WHITE} Platform: POSIX Generic${R}" ;;
esac

echo "  ${GREEN}[+]${WHITE} Shell: $SHELL_TYPE${R}"
echo "  ${GREEN}[+]${WHITE} Profile: $PROFILE${R}"

if [[ ! -w "$HOME" ]]; then
    handle_error "Cannot write to home directory: $HOME"
    exit 1
fi

echo ""

# Interactive confirmation
if [[ -t 0 ]]; then
    read -r -p "  ${GOLD}Continue installation? [Y/n]:${R} " confirm
    confirm=${confirm:-Y}
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "  ${RED}Installation cancelled.${R}"
        exit 0
    fi
else
    echo "  ${GOLD}Non-interactive session detected (proceeding)${R}"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# CONFIG LOAD & PRESERVATION
# ═══════════════════════════════════════════════════════════════════════════

THEME="Phantom"
MATRIX_MODE="Letters"
SHOW_FULL_PATH=true
GRADIENT_TEXT=true
AUTO_UPDATE=true
SHOW_SYSTEM_INFO=true
SMART_SUGGESTIONS=true
STEALTH_MODE=false
LIVE_STATS=false
SHOW_USAGE_BARS=true

# Helper to normalize boolean strings
to_bool() {
    local val="${1:-true}"
    case "$val" in
        1|[tT][rR][uU][eE]|[yY][eE][sS]|[yY]) echo "true" ;;
        0|[fF][aA][lL][sS][eE]|[nN][oO]|[nN]) echo "false" ;;
        *) echo "true" ;;
    esac
}

if [[ -f "$CONFIG_FILE" ]]; then
    echo "  ${GOLD}[*]${GRAY} Preserving existing configuration...${R}"
    if command -v jq &> /dev/null; then
        THEME=$(jq -r '.Theme // "Phantom"' "$CONFIG_FILE" 2>/dev/null || echo "Phantom")
        MATRIX_MODE=$(jq -r '.MatrixMode // "Letters"' "$CONFIG_FILE" 2>/dev/null || echo "Letters")
        SHOW_FULL_PATH=$(to_bool "$(jq -r '.ShowFullPath // true' "$CONFIG_FILE" 2>/dev/null)")
        GRADIENT_TEXT=$(to_bool "$(jq -r '.GradientText // true' "$CONFIG_FILE" 2>/dev/null)")
        AUTO_UPDATE=$(to_bool "$(jq -r '.AutoCheckUpdates // true' "$CONFIG_FILE" 2>/dev/null)")
        SHOW_SYSTEM_INFO=$(to_bool "$(jq -r '.ShowSystemInfo // true' "$CONFIG_FILE" 2>/dev/null)")
        SMART_SUGGESTIONS=$(to_bool "$(jq -r '.SmartSuggestions // true' "$CONFIG_FILE" 2>/dev/null)")
        STEALTH_MODE=$(to_bool "$(jq -r '.StealthMode // false' "$CONFIG_FILE" 2>/dev/null)")
        LIVE_STATS=$(to_bool "$(jq -r '.LiveStats // false' "$CONFIG_FILE" 2>/dev/null)")
        SHOW_USAGE_BARS=$(to_bool "$(jq -r '.ShowUsageBars // true' "$CONFIG_FILE" 2>/dev/null)")
    else
        # Pure Bash regex parser - zero dependencies!
        parse_cfg() {
            local key="$1"
            local default="$2"
            local line
            line=$(grep -E "\"$key\"[[:space:]]*:" "$CONFIG_FILE" 2>/dev/null | head -1)
            if [[ -n "$line" ]]; then
                local val
                val=$(echo "$line" | sed -E 's/.*:[[:space:]]*"?([^",]*)"?.*/\1/' | tr -d ' \r\t')
                echo "$val"
            else
                echo "$default"
            fi
        }
        THEME=$(parse_cfg "Theme" "Phantom")
        MATRIX_MODE=$(parse_cfg "MatrixMode" "Letters")
        SHOW_FULL_PATH=$(to_bool "$(parse_cfg "ShowFullPath" "true")")
        GRADIENT_TEXT=$(to_bool "$(parse_cfg "GradientText" "true")")
        AUTO_UPDATE=$(to_bool "$(parse_cfg "AutoCheckUpdates" "true")")
        SHOW_SYSTEM_INFO=$(to_bool "$(parse_cfg "ShowSystemInfo" "true")")
        SMART_SUGGESTIONS=$(to_bool "$(parse_cfg "SmartSuggestions" "true")")
        STEALTH_MODE=$(to_bool "$(parse_cfg "StealthMode" "false")")
        LIVE_STATS=$(to_bool "$(parse_cfg "LiveStats" "false")")
        SHOW_USAGE_BARS=$(to_bool "$(parse_cfg "ShowUsageBars" "true")")
    fi

    echo "  ${GREEN}[+]${WHITE} Settings preserved${R}"
    echo ""
fi

# ═══════════════════════════════════════════════════════════════════════════
# INSTALLATION WIZARD
# ═══════════════════════════════════════════════════════════════════════════

NON_INTERACTIVE=false
if [[ ! -t 0 ]]; then
    NON_INTERACTIVE=true
    echo "  ${GOLD}[i] Non-interactive mode: using defaults / existing settings${R}"
    echo ""
fi

if [[ "$SHELL_TYPE" == "sh" ]]; then
    if [[ "${SHELL:-}" == *"zsh"* ]]; then
        SHELL_TYPE="zsh"
        PROFILE="$HOME/.zshrc"
    elif [[ "${SHELL:-}" == *"bash"* ]]; then
        SHELL_TYPE="bash"
        if [[ "$PLATFORM" == "macos" ]]; then
            [[ -f "$HOME/.bash_profile" ]] && PROFILE="$HOME/.bash_profile" || PROFILE="$HOME/.bashrc"
        else
            PROFILE="$HOME/.bashrc"
        fi
    fi
fi

choose_shell_profile
echo "  ${GREEN}[+]${WHITE} Shell: $SHELL_TYPE${R}"
echo "  ${GREEN}[+]${WHITE} Profile: $PROFILE${R}"
echo ""

# Theme selection
echo "  ${GOLD}[1] THEME${R}"
d1="1"
[[ "$THEME" == "Unknown" ]] && d1="2"
echo "  ${PURPLE}[1] Phantom${R}  ${GREEN}[2] Unknown${R}  ${DGRAY}(current: $THEME)${R}"
if [[ "$NON_INTERACTIVE" == "false" ]]; then
    read -r -p "  Choice [Enter=$d1]: " choice
    choice=${choice:-$d1}
else
    choice=$d1
fi
[[ "$choice" == "2" ]] && THEME="Unknown" || THEME="Phantom"
echo "  ${GREEN}→ $THEME${R}"
echo ""

# Matrix Mode
echo "  ${GOLD}[2] MATRIX RAIN${R}"
d2="1"
[[ "$MATRIX_MODE" == "Binary" ]] && d2="2"
echo "  ${CYAN}[1] Letters${R}  ${GREEN}[2] Binary${R}  ${DGRAY}(current: $MATRIX_MODE)${R}"
if [[ "$NON_INTERACTIVE" == "false" ]]; then
    read -r -p "  Choice [Enter=$d2]: " choice
    choice=${choice:-$d2}
else
    choice=$d2
fi
[[ "$choice" == "2" ]] && MATRIX_MODE="Binary" || MATRIX_MODE="Letters"
echo "  ${GREEN}→ $MATRIX_MODE${R}"
echo ""

# Prompt Path
echo "  ${GOLD}[3] PROMPT PATH${R}"
d3="1"
[[ "$SHOW_FULL_PATH" == "false" ]] && d3="2"
echo "  ${CYAN}[1] Full path${R}  ${BLUE}[2] Folder only${R}  ${DGRAY}(current: $([ "$SHOW_FULL_PATH" == "true" ] && echo "Full" || echo "Folder"))${R}"
if [[ "$NON_INTERACTIVE" == "false" ]]; then
    read -r -p "  Choice [Enter=$d3]: " choice
    choice=${choice:-$d3}
else
    choice=$d3
fi
[[ "$choice" == "2" ]] && SHOW_FULL_PATH=false || SHOW_FULL_PATH=true
echo "  ${GREEN}→ $([ "$SHOW_FULL_PATH" == "true" ] && echo "Full path" || echo "Folder only")${R}"
echo ""

# Options
echo "  ${GOLD}[4] OPTIONS${R}"

dS="Y"
[[ "$SHOW_SYSTEM_INFO" == "false" ]] && dS="n"
if [[ "$NON_INTERACTIVE" == "false" ]]; then
    read -r -p "  Show system info? [Y/n, Enter=$dS]: " choice
    choice=${choice:-$dS}
else
    choice=$dS
fi
[[ "$choice" =~ ^[Nn]$ ]] && SHOW_SYSTEM_INFO=false || SHOW_SYSTEM_INFO=true

dG="Y"
[[ "$GRADIENT_TEXT" == "false" ]] && dG="n"
if [[ "$NON_INTERACTIVE" == "false" ]]; then
    read -r -p "  Gradient logo? [Y/n, Enter=$dG]: " choice
    choice=${choice:-$dG}
else
    choice=$dG
fi
[[ "$choice" =~ ^[Nn]$ ]] && GRADIENT_TEXT=false || GRADIENT_TEXT=true

dA="Y"
[[ "$AUTO_UPDATE" == "false" ]] && dA="n"
if [[ "$NON_INTERACTIVE" == "false" ]]; then
    read -r -p "  Auto-update check? [Y/n, Enter=$dA]: " choice
    choice=${choice:-$dA}
else
    choice=$dA
fi
[[ "$choice" =~ ^[Nn]$ ]] && AUTO_UPDATE=false || AUTO_UPDATE=true

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# INSTALLATION (ZERO-DEPENDENCY)
# ═══════════════════════════════════════════════════════════════════════════

echo "  ${GOLD}═══ INSTALLING ═══${R}"
echo ""

# Dependency Check: Zero-dependency mode!
echo "  ${CYAN}[1/4]${WHITE} Verifying zero-dependency environment...${R}"
echo "  ${GREEN}[+] Native shell mode ready (zero external packages required)${R}"

# Deploy script
echo "  ${CYAN}[2/4]${WHITE} Deploying PhantomStartup.sh...${R}"
mkdir -p "$CONFIG_DIR" 2>/dev/null || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
stage_path="${INSTALL_PATH}.stage.$$.$RANDOM"
if [[ -f "$SCRIPT_DIR/PhantomStartup.sh" ]]; then
    # Isolated staging & syntax validation for local deployment
    cp -f "$SCRIPT_DIR/PhantomStartup.sh" "$stage_path"
    if [[ ! -s "$stage_path" ]] || [[ $(wc -c < "$stage_path" 2>/dev/null || echo 0) -lt 1000 ]] || ! grep -q "Phantom Terminal\|PhantomStartup" "$stage_path" 2>/dev/null || ! bash -n "$stage_path" 2>/dev/null; then
        rm -f "$stage_path" 2>/dev/null || true
        handle_error "Local PhantomStartup.sh failed integrity check (corrupted or invalid syntax). Aborting installation."
        exit 1
    fi
    if ! mv -f "$stage_path" "$INSTALL_PATH"; then
        rm -f "$stage_path" 2>/dev/null || true
        handle_error "Failed to promote staged file to $INSTALL_PATH."
        exit 1
    fi
    rm -f "$LEGACY_PATH" 2>/dev/null || true
    chmod +x "$INSTALL_PATH" 2>/dev/null || true
    echo "  ${GREEN}[+] Deployed and validated from local repository${R}"
else
    DOWNLOAD_SUCCESS=false
    sums_file="${INSTALL_PATH}.stage.$$.sums"
    if command -v curl &> /dev/null; then
        if curl -fsSL --connect-timeout 10 --max-time 30 "$REPO_URL/PhantomStartup.sh" -o "$stage_path" 2>/dev/null; then
            DOWNLOAD_SUCCESS=true
            curl -fsSL --connect-timeout 10 --max-time 15 "$REPO_URL/SHA256SUMS" -o "$sums_file" 2>/dev/null || true
        fi
    elif command -v wget &> /dev/null; then
        if wget -qO "$stage_path" --timeout=30 "$REPO_URL/PhantomStartup.sh" 2>/dev/null; then
            DOWNLOAD_SUCCESS=true
            wget -qO "$sums_file" --timeout=15 "$REPO_URL/SHA256SUMS" 2>/dev/null || true
        fi
    fi

    if [[ "$DOWNLOAD_SUCCESS" != "true" || ! -s "$stage_path" ]]; then
        rm -f "$stage_path" "$sums_file" 2>/dev/null || true
        handle_error "Failed to download PhantomStartup.sh from $RELEASE_TAG. Ensure curl or wget is installed."
        exit 1
    fi

    # Mandatory fail-closed SHA-256 release checksum verification
    actual_hash=""
    if command -v sha256sum &>/dev/null; then
        actual_hash=$(sha256sum "$stage_path" 2>/dev/null | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
    elif command -v shasum &>/dev/null; then
        actual_hash=$(shasum -a 256 "$stage_path" 2>/dev/null | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
    elif command -v openssl &>/dev/null; then
        actual_hash=$(openssl dgst -sha256 "$stage_path" 2>/dev/null | awk '{print $NF}' | tr '[:upper:]' '[:lower:]')
    fi

    manifest_hash=""
    if [[ -s "$sums_file" ]]; then
        manifest_hash=$(grep -E "(^|[[:space:]])PhantomStartup\.sh($|[[:space:]])" "$sums_file" | awk '{print $1}' | head -1 | tr '[:upper:]' '[:lower:]')
        rm -f "$sums_file"
    fi

    if [[ -z "$actual_hash" ]]; then
        rm -f "$stage_path" "$sums_file" 2>/dev/null || true
        handle_error "Security verification failed: Unable to compute SHA-256 checksum (missing sha256sum/shasum/openssl)."
        exit 1
    fi

    # Strict fail-closed verification: manifest MUST exist and contain target hash
    if [[ -z "$manifest_hash" || ! "$manifest_hash" =~ ^[a-f0-9]{64}$ ]]; then
        rm -f "$stage_path" "$sums_file" 2>/dev/null || true
        handle_error "Security verification failed: SHA256SUMS release manifest is missing, invalid, or does not contain PhantomStartup.sh. Aborting for security."
        exit 1
    fi

    # Manifest hash MUST match embedded root-of-trust digest
    if [[ -n "$EXPECTED_SHA256" && "$manifest_hash" != "$EXPECTED_SHA256" ]]; then
        rm -f "$stage_path" "$sums_file" 2>/dev/null || true
        handle_error "Security verification failed: Manifest checksum does not match embedded root-of-trust digest."
        exit 1
    fi

    expected_hash="$manifest_hash"
    if [[ "$actual_hash" != "$expected_hash" ]]; then
        rm -f "$stage_path" "$sums_file" 2>/dev/null || true
        handle_error "Security verification failed: SHA-256 checksum mismatch for PhantomStartup.sh (expected: $expected_hash, got: $actual_hash)."
        exit 1
    fi

    if ! bash -n "$stage_path" 2>/dev/null || ! grep -q "Phantom Terminal\|PhantomStartup" "$stage_path" 2>/dev/null; then
        rm -f "$stage_path"
        handle_error "Downloaded PhantomStartup.sh failed integrity check (corrupted or invalid syntax)."
        exit 1
    fi

    # Staging passed all checks: promote staged file to active installation path
    if ! mv -f "$stage_path" "$INSTALL_PATH"; then
        rm -f "$stage_path" 2>/dev/null || true
        handle_error "Failed to promote staged file to $INSTALL_PATH."
        exit 1
    fi
    rm -f "$LEGACY_PATH" 2>/dev/null || true
    echo "  ${GREEN}[+] Downloaded from $RELEASE_TAG and verified SHA-256 integrity${R}"
fi

chmod +x "$INSTALL_PATH" 2>/dev/null || true

# Profile setup
echo "  ${CYAN}[3/4]${WHITE} Configuring profile ($PROFILE)...${R}"
touch "$PROFILE" 2>/dev/null || true
clean_profile_entries "$PROFILE"

cat >> "$PROFILE" <<EOF

# >>> Phantom Terminal START >>>
if [ -f "$INSTALL_PATH" ]; then
    source "$INSTALL_PATH"
fi
# <<< Phantom Terminal END <<<
EOF

echo "  ${GREEN}[+] Profile updated safely${R}"

# Save Config
echo "  ${CYAN}[4/4]${WHITE} Saving config...${R}"
cat > "$CONFIG_FILE" <<EOF
{
  "AnimationEnabled": true,
  "MatrixDuration": 2,
  "MatrixMode": "$MATRIX_MODE",
  "SecurityLoadSteps": 8,
  "GlitchIntensity": 3,
  "ShowSystemInfo": $SHOW_SYSTEM_INFO,
  "ShowFullPath": $SHOW_FULL_PATH,
  "GradientText": $GRADIENT_TEXT,
  "SmartSuggestions": $SMART_SUGGESTIONS,
  "Theme": "$THEME",
  "AutoCheckUpdates": $AUTO_UPDATE,
  "SilentUpdate": false,
  "UpdateCheckDays": 1,
  "StealthMode": $STEALTH_MODE,
  "LiveStats": $LIVE_STATS,
  "ShowUsageBars": $SHOW_USAGE_BARS
}
EOF

echo "  ${GREEN}[+] Config saved to $CONFIG_FILE${R}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# SUCCESS
# ═══════════════════════════════════════════════════════════════════════════

trap - EXIT
INSTALL_ERRORS=0

c_title="INSTALLATION COMPLETE! (v$INSTALL_VERSION \"$INSTALL_CODENAME\")"
c_inner=52
c_pad=$(( c_inner - ${#c_title} ))
c_left=$(( c_pad / 2 ))
c_right=$(( c_pad - c_left ))
c_hln=""
for ((i=0; i<c_inner; i++)); do c_hln+="═"; done
echo "  ${GREEN}╔${c_hln}╗${R}"
printf "  ${GREEN}║${WHITE}%*s%s%*s${GREEN}║${R}\n" "$c_left" "" "$c_title" "$c_right" ""
echo "  ${GREEN}╚${c_hln}╝${R}"
echo ""
echo "  ${CYAN}Restart your terminal or run:${R}"
echo "  ${WHITE}source $PROFILE${R}"
echo ""
echo "  ${GOLD}Settings:${WHITE} $THEME | $MATRIX_MODE | $([ "$SHOW_FULL_PATH" == "true" ] && echo "Full" || echo "Folder")${R}"
cmd_p="phantom"
    [[ "$THEME" == "Unknown" ]] && cmd_p="unknown"
    echo "  ${GOLD}Commands:${WHITE} ${GOLD}${cmd_p}-help${GRAY} | ${GOLD}${cmd_p}-dash -Live${GRAY} | ${GOLD}${cmd_p}-stealth${GRAY} | ${GOLD}${cmd_p}-search${R}"
echo ""

case "$PLATFORM" in
    termux)
        echo "  ${CYAN}[Termux] Optimized for mobile touch screens and proot${R}"
        ;;
    macos)
        echo "  ${CYAN}[macOS] Compatible with Terminal.app, iTerm2, Kitty, and Ghostty${R}"
        ;;
    linux)
        echo "  ${CYAN}[Linux] Works across all POSIX shells and terminal emulators${R}"
        ;;
esac
