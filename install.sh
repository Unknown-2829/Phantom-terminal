#!/usr/bin/env bash
#
# Phantom Terminal - Universal Native Installer v4.2.3
# Cross-platform installer with automatic platform detection and ZERO external dependencies.
# Supports: Linux, macOS, Termux (Android), BSD
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.2.3/install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/v4.2.3/install.sh | bash
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
    local u
    u="$(uname -s 2>/dev/null || echo "${OSTYPE:-}")"
    case "$u" in
        Darwin*|darwin*)
            echo "macos"
            ;;
        *Android*|*linux-android*|*android*)
            echo "termux"
            ;;
        FreeBSD*|OpenBSD*|NetBSD*|DragonFly*|*BSD*|*bsd*)
            echo "bsd"
            ;;
        Linux*|linux*)
            if [[ -n "${TERMUX_VERSION:-}" ]] || [[ "${PREFIX:-}" == *"com.termux"* ]]; then
                echo "termux"
            else
                echo "linux"
            fi
            ;;
        *)
            echo "linux"
            ;;
    esac
}

PLATFORM=$(detect_platform)

# ═══════════════════════════════════════════════════════════════════════════
# VARIABLES & PATHS
# ═══════════════════════════════════════════════════════════════════════════

INSTALL_VERSION="4.2.3"
INSTALL_CODENAME="Krypton"
RELEASE_TAG="v$INSTALL_VERSION"
REPO_URL="https://raw.githubusercontent.com/Unknown-2829/Phantom-terminal/$RELEASE_TAG"
ASSET_URL="https://github.com/Unknown-2829/Phantom-terminal/releases/download/$RELEASE_TAG"
[[ "$REPO_URL" != *"github"* ]] && ASSET_URL="$REPO_URL"
EXPECTED_SHA256="0149cc818a288dc7ca045cf872962377436b860c36f6181b499d21738b1cb39a"
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
        choices=("$TARGET_HOME/.zshrc" "$TARGET_HOME/.bash_profile" "$TARGET_HOME/.bashrc")
        labels=("Zsh (~/.zshrc)" "Bash login (~/.bash_profile)" "Bash interactive (~/.bashrc)")
    else
        choices=("$TARGET_HOME/.bashrc" "$TARGET_HOME/.zshrc" "$TARGET_HOME/.profile")
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

if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "${0}" ]]; then
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
    bsd)    echo "  ${GREEN}[+]${WHITE} Platform: BSD ($(uname -s 2>/dev/null))${R}" ;;
    linux)  echo "  ${GREEN}[+]${WHITE} Platform: Linux${R}" ;;
    *)      echo "  ${GOLD}[!]${WHITE} Platform: POSIX Generic${R}" ;;
esac

echo "  ${GREEN}[+]${WHITE} Shell: $SHELL_TYPE${R}"
echo "  ${GREEN}[+]${WHITE} Profile: $PROFILE${R}"

if [[ -f "$INSTALL_PATH" || -f "$LEGACY_PATH" ]]; then
    echo "  ${GOLD}[*]${GRAY} Detected existing installation (preserving active setup until verified)...${R}"
fi

if [[ ! -w "$HOME" ]]; then
    handle_error "Cannot write to home directory: $HOME"
    exit 1
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURATION & JSON VALIDATION
# ═══════════════════════════════════════════════════════════════════════════

_validate_json_file() {
    local target="$1"
    [[ ! -f "$target" ]] && return 1
    [[ ! -s "$target" ]] && return 1

    # Tier 1: Real JSON engines if available
    if command -v jq &>/dev/null; then
        jq empty "$target" 2>/dev/null && return 0 || return 1
    fi
    if command -v python3 &>/dev/null; then
        python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$target" 2>/dev/null && return 0 || return 1
    fi
    if command -v python &>/dev/null; then
        python -c "import json, sys; json.load(open(sys.argv[1]))" "$target" 2>/dev/null && return 0 || return 1
    fi
    if command -v node &>/dev/null; then
        node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "$target" 2>/dev/null && return 0 || return 1
    fi
    if command -v perl &>/dev/null; then
        perl -MJSON::PP -e "JSON::PP::decode_json(do { local \$/; <> })" "$target" 2>/dev/null && return 0 || return 1
    fi

    # Tier 2: POSIX structural JSON validator using awk
    awk '
    BEGIN {
        brace_count = 0;
        bracket_count = 0;
        in_string = 0;
        escape = 0;
        first_char = "";
        last_char = "";
        valid = 1;
    }
    {
        line = $0;
        len = length(line);
        for (i = 1; i <= len; i++) {
            c = substr(line, i, 1);
            if (first_char == "" && c ~ /[^ \t\r\n]/) {
                first_char = c;
            }
            if (c ~ /[^ \t\r\n]/) {
                last_char = c;
            }
            if (in_string) {
                if (escape) {
                    escape = 0;
                } else if (c == "\\") {
                    escape = 1;
                } else if (c == "\"") {
                    in_string = 0;
                }
            } else {
                if (c == "\"") {
                    in_string = 1;
                } else if (c == "{") {
                    brace_count++;
                } else if (c == "}") {
                    brace_count--;
                    if (brace_count < 0) { valid = 0; exit; }
                } else if (c == "[") {
                    bracket_count++;
                } else if (c == "]") {
                    bracket_count--;
                    if (bracket_count < 0) { valid = 0; exit; }
                }
            }
        }
    }
    END {
        if (!valid || in_string || brace_count != 0 || bracket_count != 0 || first_char != "{" || last_char != "}") {
            exit 1;
        }
        exit 0;
    }
    ' "$target" 2>/dev/null
    return $?
}

# ═══════════════════════════════════════════════════════════════════════════
# CONFIG LOAD & PRESERVATION
# ═══════════════════════════════════════════════════════════════════════════

ANIMATION_ENABLED=true
THEME="Phantom"
MATRIX_MODE="Letters"
SHOW_FULL_PATH=true
GRADIENT_TEXT=true
AUTO_UPDATE=true
SHOW_SYSTEM_INFO=true
SMART_SUGGESTIONS=true
STEALTH_MODE=false
STEALTH_MASK_PATH=false
AI_BYPASS=true
ALLOW_VSCODE_ANIMATIONS=true
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
    if ! _validate_json_file "$CONFIG_FILE"; then
        ts=$(date +%Y%m%d%H%M%S 2>/dev/null || echo "$$")
        corrupt_backup="${CONFIG_FILE}.corrupt.$ts"
        cp -f "$CONFIG_FILE" "$corrupt_backup" 2>/dev/null || true
        echo "  ${RED}[!] Warning: Malformed configuration detected. Backed up to ${corrupt_backup}. Loading defaults.${R}"
        echo ""
    else
        echo "  ${GOLD}[*]${GRAY} Preserving existing configuration...${R}"
        if command -v jq &> /dev/null; then
            ANIMATION_ENABLED=$(to_bool "$(jq -r '.AnimationEnabled // true' "$CONFIG_FILE" 2>/dev/null)")
            THEME=$(jq -r '.Theme // "Phantom"' "$CONFIG_FILE" 2>/dev/null || echo "Phantom")
            MATRIX_MODE=$(jq -r '.MatrixMode // "Letters"' "$CONFIG_FILE" 2>/dev/null || echo "Letters")
            SHOW_FULL_PATH=$(to_bool "$(jq -r '.ShowFullPath // true' "$CONFIG_FILE" 2>/dev/null)")
            GRADIENT_TEXT=$(to_bool "$(jq -r '.GradientText // true' "$CONFIG_FILE" 2>/dev/null)")
            AUTO_UPDATE=$(to_bool "$(jq -r '.AutoCheckUpdates // true' "$CONFIG_FILE" 2>/dev/null)")
            SHOW_SYSTEM_INFO=$(to_bool "$(jq -r '.ShowSystemInfo // true' "$CONFIG_FILE" 2>/dev/null)")
            SMART_SUGGESTIONS=$(to_bool "$(jq -r '.SmartSuggestions // true' "$CONFIG_FILE" 2>/dev/null)")
            STEALTH_MODE=$(to_bool "$(jq -r '.StealthMode // false' "$CONFIG_FILE" 2>/dev/null)")
            STEALTH_MASK_PATH=$(to_bool "$(jq -r '.StealthMaskPath // false' "$CONFIG_FILE" 2>/dev/null)")
            AI_BYPASS=$(to_bool "$(jq -r '.AIBypass // true' "$CONFIG_FILE" 2>/dev/null)")
            ALLOW_VSCODE_ANIMATIONS=$(to_bool "$(jq -r '.AllowVSCodeAnimations // true' "$CONFIG_FILE" 2>/dev/null)")
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
            ANIMATION_ENABLED=$(to_bool "$(parse_cfg "AnimationEnabled" "true")")
            THEME=$(parse_cfg "Theme" "Phantom")
            MATRIX_MODE=$(parse_cfg "MatrixMode" "Letters")
            SHOW_FULL_PATH=$(to_bool "$(parse_cfg "ShowFullPath" "true")")
            GRADIENT_TEXT=$(to_bool "$(parse_cfg "GradientText" "true")")
            AUTO_UPDATE=$(to_bool "$(parse_cfg "AutoCheckUpdates" "true")")
            SHOW_SYSTEM_INFO=$(to_bool "$(parse_cfg "ShowSystemInfo" "true")")
            SMART_SUGGESTIONS=$(to_bool "$(parse_cfg "SmartSuggestions" "true")")
            STEALTH_MODE=$(to_bool "$(parse_cfg "StealthMode" "false")")
            STEALTH_MASK_PATH=$(to_bool "$(parse_cfg "StealthMaskPath" "false")")
            AI_BYPASS=$(to_bool "$(parse_cfg "AIBypass" "true")")
            ALLOW_VSCODE_ANIMATIONS=$(to_bool "$(parse_cfg "AllowVSCodeAnimations" "true")")
            LIVE_STATS=$(to_bool "$(parse_cfg "LiveStats" "false")")
            SHOW_USAGE_BARS=$(to_bool "$(parse_cfg "ShowUsageBars" "true")")
        fi

        echo "  ${GREEN}[+]${WHITE} Settings preserved${R}"
        echo ""
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# INSTALLATION WIZARD & MODE SELECTION
# ═══════════════════════════════════════════════════════════════════════════

NON_INTERACTIVE=false
if [[ ! -t 0 || -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" ]]; then
    NON_INTERACTIVE=true
fi

INSTALL_MODE="1"
if [[ "$NON_INTERACTIVE" == "false" ]]; then
    echo "  ${GOLD}[?] CHOOSE INSTALLATION MODE:${R}"
    echo "  ${CYAN}[1] Express Install (Recommended)${R}  ${GRAY}- Instant setup with defaults / preserved settings${R}"
    echo "  ${PURPLE}[2] Custom / Interactive Setup${R}    ${GRAY}- Step-by-step configuration wizard${R}"
    echo ""
    read -r -p "  Choice [Enter=1]: " mode_choice
    mode_choice=${mode_choice:-1}
    [[ "$mode_choice" == "2" ]] && INSTALL_MODE="2" || INSTALL_MODE="1"
    echo ""
else
    echo "  ${GREEN}[+] Running in non-interactive/Express mode with default configuration${R}"
    echo ""
fi

if [[ "$INSTALL_MODE" == "2" ]]; then
    echo "  ${GOLD}─── CUSTOM CONFIGURATION WIZARD ───${R}"
    echo ""

    # Step 1: Shell Profile
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

    # Step 2: Theme
    echo "  ${GOLD}[1] THEME${R}"
    d1="1"
    [[ "$THEME" == "Unknown" ]] && d1="2"
    echo "  ${PURPLE}[1] Phantom${R}  ${GREEN}[2] Unknown${R}  ${DGRAY}(current: $THEME)${R}"
    read -r -p "  Choice [Enter=$d1]: " choice
    choice=${choice:-$d1}
    [[ "$choice" == "2" ]] && THEME="Unknown" || THEME="Phantom"
    echo "  ${GREEN}→ $THEME${R}"
    echo ""

    # Step 3: Matrix Mode
    echo "  ${GOLD}[2] MATRIX RAIN${R}"
    d2="1"
    [[ "$MATRIX_MODE" == "Binary" ]] && d2="2"
    echo "  ${CYAN}[1] Letters${R}  ${GREEN}[2] Binary${R}  ${DGRAY}(current: $MATRIX_MODE)${R}"
    read -r -p "  Choice [Enter=$d2]: " choice
    choice=${choice:-$d2}
    [[ "$choice" == "2" ]] && MATRIX_MODE="Binary" || MATRIX_MODE="Letters"
    echo "  ${GREEN}→ $MATRIX_MODE${R}"
    echo ""

    # Step 4: Prompt Path
    echo "  ${GOLD}[3] PROMPT PATH${R}"
    d3="1"
    [[ "$SHOW_FULL_PATH" == "false" ]] && d3="2"
    echo "  ${CYAN}[1] Full path${R}  ${BLUE}[2] Folder only${R}  ${DGRAY}(current: $([ "$SHOW_FULL_PATH" == "true" ] && echo "Full" || echo "Folder"))${R}"
    read -r -p "  Choice [Enter=$d3]: " choice
    choice=${choice:-$d3}
    [[ "$choice" == "2" ]] && SHOW_FULL_PATH=false || SHOW_FULL_PATH=true
    echo "  ${GREEN}→ $([ "$SHOW_FULL_PATH" == "true" ] && echo "Full path" || echo "Folder only")${R}"
    echo ""

    # Step 5: Animations & Visuals
    echo "  ${GOLD}[4] ANIMATIONS & VISUALS${R}"
    dAni="Y"
    [[ "$ANIMATION_ENABLED" == "false" ]] && dAni="n"
    read -r -p "  Enable startup animations? [Y/n, Enter=$dAni]: " choice
    choice=${choice:-$dAni}
    [[ "$choice" =~ ^[Nn]$ ]] && ANIMATION_ENABLED=false || ANIMATION_ENABLED=true

    dG="Y"
    [[ "$GRADIENT_TEXT" == "false" ]] && dG="n"
    read -r -p "  Gradient logo colors? [Y/n, Enter=$dG]: " choice
    choice=${choice:-$dG}
    [[ "$choice" =~ ^[Nn]$ ]] && GRADIENT_TEXT=false || GRADIENT_TEXT=true
    echo ""

    # Step 6: AI Guard & Developer Settings
    echo "  ${GOLD}[5] AI GUARD & DEVELOPER SETTINGS${R}"
    dAI="Y"
    [[ "$AI_BYPASS" == "false" ]] && dAI="n"
    read -r -p "  Auto-bypass in AI coding agents / CI? [Y/n, Enter=$dAI]: " choice
    choice=${choice:-$dAI}
    [[ "$choice" =~ ^[Nn]$ ]] && AI_BYPASS=false || AI_BYPASS=true

    dVSC="Y"
    [[ "$ALLOW_VSCODE_ANIMATIONS" == "false" ]] && dVSC="n"
    read -r -p "  Allow animations in VS Code terminal? [Y/n, Enter=$dVSC]: " choice
    choice=${choice:-$dVSC}
    [[ "$choice" =~ ^[Nn]$ ]] && ALLOW_VSCODE_ANIMATIONS=false || ALLOW_VSCODE_ANIMATIONS=true
    echo ""

    # Step 7: Telemetry & Extras
    echo "  ${GOLD}[6] TELEMETRY & FEATURES${R}"
    dS="Y"
    [[ "$SHOW_SYSTEM_INFO" == "false" ]] && dS="n"
    read -r -p "  Show system info on dashboard? [Y/n, Enter=$dS]: " choice
    choice=${choice:-$dS}
    [[ "$choice" =~ ^[Nn]$ ]] && SHOW_SYSTEM_INFO=false || SHOW_SYSTEM_INFO=true

    dUB="Y"
    [[ "$SHOW_USAGE_BARS" == "false" ]] && dUB="n"
    read -r -p "  Show real-time CPU & RAM usage bars? [Y/n, Enter=$dUB]: " choice
    choice=${choice:-$dUB}
    [[ "$choice" =~ ^[Nn]$ ]] && SHOW_USAGE_BARS=false || SHOW_USAGE_BARS=true

    dSS="Y"
    [[ "$SMART_SUGGESTIONS" == "false" ]] && dSS="n"
    read -r -p "  Predictive smart suggestions? [Y/n, Enter=$dSS]: " choice
    choice=${choice:-$dSS}
    [[ "$choice" =~ ^[Nn]$ ]] && SMART_SUGGESTIONS=false || SMART_SUGGESTIONS=true

    dA="Y"
    [[ "$AUTO_UPDATE" == "false" ]] && dA="n"
    read -r -p "  Auto-check for updates? [Y/n, Enter=$dA]: " choice
    choice=${choice:-$dA}
    [[ "$choice" =~ ^[Nn]$ ]] && AUTO_UPDATE=false || AUTO_UPDATE=true
    echo ""
else
    p_str="Full"
    [[ "$SHOW_FULL_PATH" == "false" ]] && p_str="Folder"
    echo "  ${GREEN}[+] Express mode active:${WHITE} Using configuration ($THEME | $MATRIX_MODE | $p_str)${R}"
    echo ""
fi
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

SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
fi
stage_path="${INSTALL_PATH}.stage.$$.$RANDOM"
if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/PhantomStartup.sh" ]]; then
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
        if curl -fsSL --connect-timeout 10 --max-time 30 "$ASSET_URL/PhantomStartup.sh" -o "$stage_path" 2>/dev/null || \
           curl -fsSL --connect-timeout 10 --max-time 30 "$REPO_URL/PhantomStartup.sh" -o "$stage_path" 2>/dev/null; then
            DOWNLOAD_SUCCESS=true
            curl -fsSL --connect-timeout 10 --max-time 15 "$ASSET_URL/SHA256SUMS" -o "$sums_file" 2>/dev/null || \
            curl -fsSL --connect-timeout 10 --max-time 15 "$REPO_URL/SHA256SUMS" -o "$sums_file" 2>/dev/null || true
        fi
    elif command -v wget &> /dev/null; then
        if wget -qO "$stage_path" --timeout=30 "$ASSET_URL/PhantomStartup.sh" 2>/dev/null || \
           wget -qO "$stage_path" --timeout=30 "$REPO_URL/PhantomStartup.sh" 2>/dev/null; then
            DOWNLOAD_SUCCESS=true
            wget -qO "$sums_file" --timeout=15 "$ASSET_URL/SHA256SUMS" 2>/dev/null || \
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
if ! touch "$PROFILE" 2>/dev/null; then
    handle_error "Failed to create or touch profile at $PROFILE (permission denied)."
    exit 1
fi
clean_profile_entries "$PROFILE"

if ! cat >> "$PROFILE" <<EOF

# >>> Phantom Terminal START >>>
if [ -n "\${BASH_VERSION:-}" ] || [ -n "\${ZSH_VERSION:-}" ]; then
    if [ -f "$INSTALL_PATH" ]; then
        . "$INSTALL_PATH"
    fi
fi
# <<< Phantom Terminal END <<<
EOF
then
    handle_error "Failed to write startup block to $PROFILE."
    exit 1
fi

if ! grep -q "# >>> Phantom Terminal START >>>" "$PROFILE" 2>/dev/null; then
    handle_error "Verification failed: Phantom Terminal startup block not found in $PROFILE."
    exit 1
fi

echo "  ${GREEN}[+] Profile updated safely${R}"

# Save Config
echo "  ${CYAN}[4/4]${WHITE} Saving config...${R}"
cat > "$CONFIG_FILE" <<EOF
{
  "AnimationEnabled": $ANIMATION_ENABLED,
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
  "StealthMaskPath": $STEALTH_MASK_PATH,
  "AIBypass": $AI_BYPASS,
  "AllowVSCodeAnimations": $ALLOW_VSCODE_ANIMATIONS,
  "LiveStats": $LIVE_STATS,
  "ShowUsageBars": $SHOW_USAGE_BARS
}
EOF

echo "  ${GREEN}[+] Config saved to $CONFIG_FILE${R}"

# Initialize cache for fresh installs (so upgrade modal is NOT shown on new installs)
CACHE_FILE="$CONFIG_DIR/cache.json"
if [[ ! -f "$CACHE_FILE" ]]; then
    now_epoch=$(date +%s 2>/dev/null || echo 0)
    cat > "$CACHE_FILE" <<EOF
{
  "LastUpdateCheck": "$now_epoch",
  "LatestVersion": "$INSTALL_VERSION",
  "UpdateAvailable": false,
  "UpdateDownloaded": false,
  "LastSeenVersion": "$INSTALL_VERSION"
}
EOF
fi
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
    bsd)
        echo "  ${CYAN}[BSD] Compatible with FreeBSD, OpenBSD, NetBSD, and DragonFly BSD${R}"
        ;;
    linux)
        echo "  ${CYAN}[Linux] Works across all POSIX shells and terminal emulators${R}"
        ;;
esac
