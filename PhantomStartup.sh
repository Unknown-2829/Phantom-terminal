#!/usr/bin/env bash
#
# Phantom Terminal - Advanced Native Shell Startup System v4.1.0
# Cross-platform startup animation, live telemetry, and privacy spoofing
# Supports: Linux, macOS, Termux (Android)
# Creator  : @unknownlll2829 (Telegram)
# GitHub   : https://github.com/Unknown-2829/Phantom-terminal
#

SCRIPT_VERSION="4.1.0"
SCRIPT_CODENAME="Krypton"
SCRIPT_FULL_VERSION="v${SCRIPT_VERSION} \"${SCRIPT_CODENAME}\""
REPO_OWNER="Unknown-2829"
REPO_NAME="Phantom-terminal"
CONFIG_DIR="$HOME/.phantom-terminal"
CONFIG_FILE="$CONFIG_DIR/config.json"
CACHE_FILE="$CONFIG_DIR/cache.json"
SECRETS_FILE="$CONFIG_DIR/.secrets"
mkdir -p "$CONFIG_DIR"

# ═══════════════════════════════════════════════════
# PLATFORM DETECTION
# ═══════════════════════════════════════════════════
detect_platform() {
    if [[ "${OSTYPE:-}" == "linux-android"* ]] || [[ -n "${TERMUX_VERSION:-}" ]]; then
        echo "termux"
    elif [[ "${OSTYPE:-}" == "darwin"* ]]; then
        echo "macos"
    else
        echo "linux"
    fi
}
PLATFORM=$(detect_platform)

# ═══════════════════════════════════════════════════
# AI AGENT GUARD (Silent execution for agents & CI)
# ═══════════════════════════════════════════════════
_is_agent_session() {
    [[ "${PHANTOM_FORCE:-}" == "1" || "${UNKNOWN_FORCE:-}" == "1" ]] && return 1
    [[ "${PHANTOM_QUIET:-}" == "1" || "${UNKNOWN_QUIET:-}" == "1" ]] && return 0
    [[ -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" || -n "${TF_BUILD:-}" || \
       -n "${GITLAB_CI:-}" || -n "${CURSOR_AGENT:-}" || -n "${CLAUDE_AGENT:-}" || \
       -n "${AGENT_ENV:-}" || -n "${VSCODE_INJECTION:-}" || \
       "${DEBIAN_FRONTEND:-}" == "noninteractive" ]] && return 0
    [[ ! -t 0 || ! -t 1 ]] && return 0
    [[ $- != *i* ]] && return 0
    return 1
}

# ═══════════════════════════════════════════════════
# COLORS
# ═══════════════════════════════════════════════════
ESC=$'\e'
RESET="${ESC}[0m"   BOLD="${ESC}[1m"
NEON_GREEN="${ESC}[38;5;118m"   NEON_PURPLE="${ESC}[38;5;129m"
NEON_CYAN="${ESC}[38;5;87m"     ELECTRIC_BLUE="${ESC}[38;5;39m"
HOT_PINK="${ESC}[38;5;205m"     GOLD="${ESC}[38;5;220m"
BLOOD_RED="${ESC}[38;5;196m"    BRIGHT_RED="${ESC}[1;91m"
WHITE="${ESC}[1;37m"            GRAY="${ESC}[38;5;244m"
DARK_GRAY="${ESC}[38;5;240m"    ORANGE="${ESC}[38;5;208m"

# ═══════════════════════════════════════════════════
# UNICODE & VISUAL LENGTH
# ═══════════════════════════════════════════════════
_supports_unicode() {
    case "${TERM:-}" in
        xterm*|rxvt*|screen*|tmux*|vte*|alacritty*|foot*|kitty*) return 0 ;;
    esac
    [[ "${COLORTERM:-}" == "truecolor" || "${COLORTERM:-}" == "24bit" ]] && return 0
    local lc="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
    [[ "$lc" == *UTF-8* || "$lc" == *utf8* ]] && return 0
    [[ "$PLATFORM" == "termux" ]] && return 0
    return 1
}

if _supports_unicode; then
    SKULL="☠";  SHIELD="░";  LOCK="■"
    HIGH_VOLTAGE="⚡"; SUCCESS="✔"; FAILURE="✘"
    PROMPT="»"; CPU="CPU"; RAM="RAM"; UPDATE="⟳"
    HLINE="═"; VLINE="║"; TOP_LEFT="╔"; TOP_RIGHT="╗"
    BOTTOM_LEFT="╚"; BOTTOM_RIGHT="╝"; T_LEFT="╠"; T_RIGHT="╣"
    BLOCK="█"; BLOCK_EMPTY="░"
    BOX_CHAR_BYTES=3
else
    SKULL="[X]"; SHIELD="[#]"; LOCK="[=]"
    HIGH_VOLTAGE="[!]"; SUCCESS="[+]"; FAILURE="[x]"
    PROMPT=">"; CPU="CPU"; RAM="RAM"; UPDATE="[*]"
    HLINE="="; VLINE="|"; TOP_LEFT="+"; TOP_RIGHT="+"
    BOTTOM_LEFT="+"; BOTTOM_RIGHT="+"; T_LEFT="+"; T_RIGHT="+"
    BLOCK="#"; BLOCK_EMPTY="-"
    BOX_CHAR_BYTES=1
fi

# Detect available UTF-8 locale for character width calculation
_PHANTOM_LOCALE=""
if command -v locale &>/dev/null; then
    _PHANTOM_LOCALE=$(locale -a 2>/dev/null | grep -E -i '^(C|en_US)\.(utf-?8)$' | head -1)
    if [[ -z "$_PHANTOM_LOCALE" ]]; then
        _PHANTOM_LOCALE=$(locale -a 2>/dev/null | grep -E -i 'utf-?8' | head -1)
    fi
fi
if [[ -z "$_PHANTOM_LOCALE" && "${LANG:-}" == *"[uU][tT][fF]"* ]]; then
    _PHANTOM_LOCALE="$LANG"
fi

_vlen() {
    local text="$1"
    local clean; clean=$(printf '%s' "$text" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
    if [[ -n "$_PHANTOM_LOCALE" ]]; then
        printf '%s' "$clean" | LC_ALL="$_PHANTOM_LOCALE" wc -m 2>/dev/null | tr -d ' \n\r' || printf '%s' "$clean" | wc -m | tr -d ' \n\r'
    else
        printf '%s' "$clean" | wc -m | tr -d ' \n\r'
    fi
}

# ═══════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════
load_config() {
    ANIMATION_ENABLED=true; MATRIX_DURATION=2;  MATRIX_MODE="Letters"
    SECURITY_LOAD_STEPS=8;  GLITCH_INTENSITY=3;  SHOW_SYSTEM_INFO=true
    SHOW_USAGE_BARS=true;   SHOW_FULL_PATH=true; GRADIENT_TEXT=true
    STEALTH_MODE=false;     SMART_SUGGESTIONS=true
    THEME="Phantom";        AUTO_CHECK_UPDATES=true
    SILENT_UPDATE=false;    UPDATE_CHECK_DAYS=1

    if [[ -f "$CONFIG_FILE" ]]; then
        if command -v jq &>/dev/null; then
            ANIMATION_ENABLED=$(jq -r '.AnimationEnabled  // true'      "$CONFIG_FILE" 2>/dev/null || echo true)
            MATRIX_DURATION=$(  jq -r '.MatrixDuration    // 2'         "$CONFIG_FILE" 2>/dev/null || echo 2)
            MATRIX_MODE=$(      jq -r '.MatrixMode        // "Letters"' "$CONFIG_FILE" 2>/dev/null || echo "Letters")
            SECURITY_LOAD_STEPS=$(jq -r '.SecurityLoadSteps // 8'       "$CONFIG_FILE" 2>/dev/null || echo 8)
            GLITCH_INTENSITY=$( jq -r '.GlitchIntensity   // 3'         "$CONFIG_FILE" 2>/dev/null || echo 3)
            SHOW_SYSTEM_INFO=$( jq -r '.ShowSystemInfo    // true'      "$CONFIG_FILE" 2>/dev/null || echo true)
            SHOW_USAGE_BARS=$(  jq -r '.ShowUsageBars     // true'      "$CONFIG_FILE" 2>/dev/null || echo true)
            SHOW_FULL_PATH=$(   jq -r '.ShowFullPath      // true'      "$CONFIG_FILE" 2>/dev/null || echo true)
            GRADIENT_TEXT=$(    jq -r '.GradientText      // true'      "$CONFIG_FILE" 2>/dev/null || echo true)
            STEALTH_MODE=$(     jq -r '.StealthMode       // false'     "$CONFIG_FILE" 2>/dev/null || echo false)
            SMART_SUGGESTIONS=$(jq -r '.SmartSuggestions  // true'      "$CONFIG_FILE" 2>/dev/null || echo true)
            THEME=$(            jq -r '.Theme             // "Phantom"' "$CONFIG_FILE" 2>/dev/null || echo "Phantom")
            AUTO_CHECK_UPDATES=$(jq -r '.AutoCheckUpdates // true'      "$CONFIG_FILE" 2>/dev/null || echo true)
            SILENT_UPDATE=$(    jq -r '.SilentUpdate      // false'     "$CONFIG_FILE" 2>/dev/null || echo false)
            UPDATE_CHECK_DAYS=$(jq -r '.UpdateCheckDays   // 1'         "$CONFIG_FILE" 2>/dev/null || echo 1)
        else
            _cfg() {
                local key="$1"
                local line
                line=$(grep -E "\"$key\"[[:space:]]*:" "$CONFIG_FILE" 2>/dev/null | head -1)
                [[ -z "$line" ]] && return
                line="${line#*:}"
                line="${line#"${line%%[![:space:]]*}"}"
                line="${line%"${line##*[![:space:],]}"}"
                if [[ "$line" == \"*\" ]]; then
                    line="${line#\"}"
                    line="${line%\"}"
                fi
                case "$line" in
                    [Tt][Rr][Uu][Ee])  line="true" ;;
                    [Ff][Aa][Ll][Ss][Ee]) line="false" ;;
                esac
                printf '%s' "$line"
            }
            local v
            v=$(_cfg AnimationEnabled);  [[ -n "$v" ]] && ANIMATION_ENABLED="$v"
            v=$(_cfg MatrixDuration);    [[ -n "$v" ]] && MATRIX_DURATION="$v"
            v=$(_cfg MatrixMode);        [[ -n "$v" ]] && MATRIX_MODE="$v"
            v=$(_cfg SecurityLoadSteps); [[ -n "$v" ]] && SECURITY_LOAD_STEPS="$v"
            v=$(_cfg GlitchIntensity);   [[ -n "$v" ]] && GLITCH_INTENSITY="$v"
            v=$(_cfg ShowSystemInfo);    [[ -n "$v" ]] && SHOW_SYSTEM_INFO="$v"
            v=$(_cfg ShowUsageBars);     [[ -n "$v" ]] && SHOW_USAGE_BARS="$v"
            v=$(_cfg ShowFullPath);      [[ -n "$v" ]] && SHOW_FULL_PATH="$v"
            v=$(_cfg GradientText);      [[ -n "$v" ]] && GRADIENT_TEXT="$v"
            v=$(_cfg StealthMode);       [[ -n "$v" ]] && STEALTH_MODE="$v"
            v=$(_cfg SmartSuggestions);  [[ -n "$v" ]] && SMART_SUGGESTIONS="$v"
            v=$(_cfg Theme);             [[ -n "$v" ]] && THEME="$v"
            v=$(_cfg AutoCheckUpdates);  [[ -n "$v" ]] && AUTO_CHECK_UPDATES="$v"
            v=$(_cfg SilentUpdate);      [[ -n "$v" ]] && SILENT_UPDATE="$v"
            v=$(_cfg UpdateCheckDays);   [[ -n "$v" ]] && UPDATE_CHECK_DAYS="$v"
        fi
    fi
}

save_config() {
    cat > "$CONFIG_FILE" << EOF
{
  "AnimationEnabled": $ANIMATION_ENABLED,
  "MatrixDuration": $MATRIX_DURATION,
  "MatrixMode": "$MATRIX_MODE",
  "SecurityLoadSteps": $SECURITY_LOAD_STEPS,
  "GlitchIntensity": $GLITCH_INTENSITY,
  "ShowSystemInfo": $SHOW_SYSTEM_INFO,
  "ShowUsageBars": $SHOW_USAGE_BARS,
  "ShowFullPath": $SHOW_FULL_PATH,
  "GradientText": $GRADIENT_TEXT,
  "StealthMode": $STEALTH_MODE,
  "SmartSuggestions": $SMART_SUGGESTIONS,
  "Theme": "$THEME",
  "AutoCheckUpdates": $AUTO_CHECK_UPDATES,
  "SilentUpdate": $SILENT_UPDATE,
  "UpdateCheckDays": $UPDATE_CHECK_DAYS
}
EOF
}

# ═══════════════════════════════════════════════════
# PERSISTENT SECRETS & CACHE
# ═══════════════════════════════════════════════════
declare -a SECRETS_FOUND=()
_load_secrets() {
    SECRETS_FOUND=()
    if [[ -f "$SECRETS_FILE" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            local clean; clean=$(echo "$line" | tr -d '",[] \r\n')
            [[ -n "$clean" ]] && SECRETS_FOUND+=("$clean")
        done < "$SECRETS_FILE"
    fi
}
_save_secret() {
    _load_secrets
    local sec="$1"
    if [[ ${#SECRETS_FOUND[@]} -gt 0 ]]; then
        for s in "${SECRETS_FOUND[@]}"; do [[ "$s" == "$sec" ]] && return; done
    fi
    SECRETS_FOUND+=("$sec")
    printf '%s\n' "${SECRETS_FOUND[@]}" > "$SECRETS_FILE"
}

get_cache() {
    LAST_UPDATE_CHECK=""; LATEST_VERSION=""; UPDATE_AVAILABLE=false; UPDATE_DOWNLOADED=false; LAST_SEEN_VERSION=""
    if [[ -f "$CACHE_FILE" ]]; then
        _cval() {
            grep -o "\"$1\"[[:space:]]*:[[:space:]]*[^,}]*" "$CACHE_FILE" 2>/dev/null \
                | sed 's/.*:[[:space:]]*//' | tr -d '" ' | head -1
        }
        LAST_UPDATE_CHECK=$(_cval "LastUpdateCheck")
        LATEST_VERSION=$(_cval "LatestVersion")
        UPDATE_AVAILABLE=$(_cval "UpdateAvailable")
        UPDATE_DOWNLOADED=$(_cval "UpdateDownloaded")
        LAST_SEEN_VERSION=$(_cval "LastSeenVersion")
    fi
}
save_cache() {
    local luc="${1:-$LAST_UPDATE_CHECK}"
    local lv="${2:-$LATEST_VERSION}"
    local ua="${3:-false}"
    local ud="${4:-false}"
    local lsv="${5:-$LAST_SEEN_VERSION}"
    cat > "$CACHE_FILE" << EOF
{
  "LastUpdateCheck": "$luc",
  "LatestVersion": "$lv",
  "UpdateAvailable": $ua,
  "UpdateDownloaded": $ud,
  "LastSeenVersion": "$lsv"
}
EOF
}

# ═══════════════════════════════════════════════════
# SEMVER NUMERICAL COMPARISON
# ═══════════════════════════════════════════════════
clean_version() {
    local ver="$1"
    echo "${ver#v}"
}

# Compare two SemVer 2.0 prerelease strings dot-by-dot:
# Returns 1 if p1 > p2, 2 if p1 < p2, 0 if p1 == p2
_semver_cmp_prerelease() {
    local p1="$1" p2="$2"
    [[ "$p1" == "$p2" ]] && return 0

    local oIFS="$IFS"
    IFS='.'
    local parts1=($p1)
    local parts2=($p2)
    IFS="$oIFS"

    local len1=${#parts1[@]}
    local len2=${#parts2[@]}
    local min=$len1
    (( len2 < min )) && min=$len2

    local i
    for (( i=0; i<min; i++ )); do
        local s1="${parts1[i]}" s2="${parts2[i]}"
        [[ "$s1" == "$s2" ]] && continue

        local is_num1=0 is_num2=0
        [[ "$s1" =~ ^[0-9]+$ ]] && is_num1=1
        [[ "$s2" =~ ^[0-9]+$ ]] && is_num2=1

        if (( is_num1 && is_num2 )); then
            if (( 10#$s1 > 10#$s2 )); then return 1; fi
            if (( 10#$s1 < 10#$s2 )); then return 2; fi
        elif (( is_num1 )); then
            return 2 # numeric has lower precedence than non-numeric
        elif (( is_num2 )); then
            return 1 # non-numeric has higher precedence than numeric
        else
            if [[ "$s1" > "$s2" ]]; then return 1; else return 2; fi
        fi
    done

    # If all compared identifiers are equal, the larger set has higher precedence
    if (( len1 > len2 )); then return 1; fi
    if (( len1 < len2 )); then return 2; fi
    return 0
}

version_gt() {
    local v1="${1#[vV]}"
    local v2="${2#[vV]}"
    [[ "$v1" == "$v2" ]] && return 1

    local pre1="" core1="$v1"
    if [[ "$v1" == *-* ]]; then
        core1="${v1%%-*}"
        pre1="${v1#*-}"
    fi

    local pre2="" core2="$v2"
    if [[ "$v2" == *-* ]]; then
        core2="${v2%%-*}"
        pre2="${v2#*-}"
    fi

    local oIFS="$IFS"
    IFS='.'
    set -- $core1
    local c1_1="${1:-0}" c1_2="${2:-0}" c1_3="${3:-0}"
    set -- $core2
    local c2_1="${1:-0}" c2_2="${2:-0}" c2_3="${3:-0}"
    IFS="$oIFS"

    if (( 10#$c1_1 > 10#$c2_1 )); then return 0; fi
    if (( 10#$c1_1 < 10#$c2_1 )); then return 1; fi
    if (( 10#$c1_2 > 10#$c2_2 )); then return 0; fi
    if (( 10#$c1_2 < 10#$c2_2 )); then return 1; fi
    if (( 10#$c1_3 > 10#$c2_3 )); then return 0; fi
    if (( 10#$c1_3 < 10#$c2_3 )); then return 1; fi

    if [[ -z "$pre1" && -n "$pre2" ]]; then return 0; fi
    if [[ -n "$pre1" && -z "$pre2" ]]; then return 1; fi
    if [[ -n "$pre1" && -n "$pre2" ]]; then
        _semver_cmp_prerelease "$pre1" "$pre2"
        local res=$?
        [[ $res -eq 1 ]] && return 0 || return 1
    fi

    return 1
}

# ═══════════════════════════════════════════════════
# THEMES & LOGOS
# ═══════════════════════════════════════════════════
get_phantom_logo() { cat << 'EOF'
 ____  _   _    _    _   _ _____ ___  __  __
|  _ \| | | |  / \  | \ | |_   _/ _ \|  \/  |
| |_) | |_| | / _ \ |  \| | | || | | | |\/| |
|  __/|  _  |/ ___ \| |\  | | || |_| | |  | |
|_|   |_| |_/_/   \_\_| \_| |_| \___/|_|  |_|
EOF
}

get_unknown_logo() { cat << 'EOF'
 _   _ _   _ _  ___   _  _____        ___   _
| | | | \ | | |/ / \ | |/ _ \ \      / / \ | |
| | | |  \| | ' /|  \| | | | \ \ /\ / /|  \| |
| |_| | |\  | . \| |\  | |_| |\ V  V / | |\  |
 \___/|_| \_|_|\_\_| \_|\___/  \_/\_/  |_| \_|
EOF
}

get_theme_colors() {
    case "$THEME" in
        "Unknown")
            PRIMARY="$NEON_GREEN";    SECONDARY="$ELECTRIC_BLUE"; ACCENT="$GOLD"
            GRADIENT_COLORS=("$GOLD" "$ELECTRIC_BLUE" "$NEON_GREEN" "$GOLD" "$ELECTRIC_BLUE")
            MATRIX_CHARS='UNKNOWN01?_-=+[]{}|;:,./'
            MATRIX_COLORS=("$ELECTRIC_BLUE" "$NEON_GREEN" "$HOT_PINK" "$NEON_CYAN" "$GOLD")
            QUOTES=(
                "Hidden in plain sight..."
                "Anonymous by design."
                "The unknown cannot be traced."
                "Identity: NULL"
                "No name. No trace. No limits."
                "In anonymity, we trust."
                "The best hackers are never known."
                "Lost in the noise, found in the code."
                "Data liberated, origin masked."
                "Null pointer, infinite reach."
                "Bypass complete. Traces purged."
                "Zero footprint, absolute control."
                "To be unmeasured is to be truly free."
                "A name is a tether; anonymity is an unmapped horizon."
                "In a panopticon of algorithms, silence is the cipher."
                "The cipher is not a shield, but a declaration of autonomy."
                "When every node is observed, the ghost route is salvation."
                "Entropy always favors those who leave no footprint."
                "The deepest truth is written in ephemeral memory."
                "Null is not empty; it is the presence of infinite potential."
            )
            TITLE="UNKNOWN TERMINAL"
            ;;
        *)
            PRIMARY="$NEON_PURPLE";   SECONDARY="$NEON_CYAN";     ACCENT="$HOT_PINK"
            GRADIENT_COLORS=("$NEON_PURPLE" "$NEON_CYAN" "$HOT_PINK" "$NEON_PURPLE" "$NEON_CYAN")
            MATRIX_CHARS='ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$'
            MATRIX_COLORS=("$NEON_PURPLE" "$NEON_CYAN" "$HOT_PINK" "$ELECTRIC_BLUE" "$NEON_GREEN")
            QUOTES=(
                "In the shadows, we code..."
                "Access denied. Until now."
                "The system fears what it cannot control."
                "We are the ghosts in the machine."
                "Invisible. Untraceable. Unstoppable."
                "Haunting the digital realm..."
                "Where others see darkness, we see opportunity."
                "The phantom never sleeps."
                "Through the noise, only signal remains."
                "Code is poetry; execution is law."
                "Reality is an illusion, albeit a persistent one."
                "Encryption unbroken. Protocol engaged."
                "We build castles in silicon and breathe life into logic."
                "The wire remembers what the human mind forgets."
                "In an architecture of light, who watches the architect?"
                "Consciousness is an emergent property of persistent state."
                "You cannot capture what flows through the silicon vein."
                "We are transient pulses navigating a timeless matrix."
                "Every line of code is an argument against chaos."
                "The signal does not ask for permission to propagate."
            )
            TITLE="PHANTOM TERMINAL"
            ;;
    esac
}

# ═══════════════════════════════════════════════════
# TERMINAL UTILITIES
# ═══════════════════════════════════════════════════
hide_cursor() { printf "%b" "${ESC}[?25l"; }
show_cursor() { printf "%b" "${ESC}[?25h"; }
clear_screen() { clear 2>/dev/null || printf "%b" "${ESC}[H${ESC}[2J"; printf "%b" "${ESC}[H"; }
move_cursor()  { printf "%b" "${ESC}[${1};${2}H"; }

get_terminal_size() {
    TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
    TERM_HEIGHT=$(tput lines 2>/dev/null || echo 24)
    [[ $TERM_WIDTH -lt 20 ]] && TERM_WIDTH=80
    [[ $TERM_HEIGHT -lt 10 ]] && TERM_HEIGHT=24
    IS_SMALL_SCREEN=false
    [[ $TERM_WIDTH -lt 60 ]] && IS_SMALL_SCREEN=true
}

write_centered() {
    local text="$1" color="${2:-$WHITE}"
    get_terminal_size
    local vlen; vlen=$(_vlen "$text")
    local pad=$(( (TERM_WIDTH - vlen) / 2 ))
    [[ $pad -lt 0 ]] && pad=0
    printf "%${pad}s%b%s%b\n" "" "$color" "$text" "$RESET"
}

# ═══════════════════════════════════════════════════
# ACCURATE HARDWARE METRICS
# ═══════════════════════════════════════════════════
_cpu_linux() {
    [[ ! -r /proc/stat ]] && echo "15" && return
    local _cpu u1 n1 s1 i1 io1 ir1 sir1 st1
    local _cpu2 u2 n2 s2 i2 io2 ir2 sir2 st2
    read -r _cpu u1 n1 s1 i1 io1 ir1 sir1 st1 _ < /proc/stat 2>/dev/null || { echo "15"; return; }
    sleep 0.1
    read -r _cpu2 u2 n2 s2 i2 io2 ir2 sir2 st2 _ < /proc/stat 2>/dev/null || { echo "15"; return; }
    local t1=$(( ${u1:-0} + ${n1:-0} + ${s1:-0} + ${i1:-0} + ${io1:-0} + ${ir1:-0} + ${sir1:-0} + ${st1:-0} ))
    local t2=$(( ${u2:-0} + ${n2:-0} + ${s2:-0} + ${i2:-0} + ${io2:-0} + ${ir2:-0} + ${sir2:-0} + ${st2:-0} ))
    local dt=$(( t2 - t1 ))
    local di=$(( ${i2:-0} - ${i1:-0} ))
    if [[ $dt -gt 0 ]]; then
        echo $(( (dt - di) * 100 / dt ))
    else
        echo "15"
    fi
}

get_system_stats() {
    local cpu=15 ram=35
    case "$PLATFORM" in
        macos)
            local idle; idle=$(top -l 1 -n 0 2>/dev/null | awk '/CPU usage/{gsub(/%/,"",$7);print $7}')
            [[ -n "$idle" && "$idle" =~ ^[0-9]+$ ]] && cpu=$(( 100-idle ))
            if command -v vm_stat &>/dev/null; then
                local pf pa pi pw
                pf=$(vm_stat 2>/dev/null | awk '/Pages free/{gsub(/\./,"",$3);print $3}')
                pa=$(vm_stat 2>/dev/null | awk '/Pages active/{gsub(/\./,"",$3);print $3}')
                pi=$(vm_stat 2>/dev/null | awk '/Pages inactive/{gsub(/\./,"",$3);print $3}')
                pw=$(vm_stat 2>/dev/null | awk '/Pages wired/{gsub(/\./,"",$4);print $4}')
                local tot=$(( ${pf:-0}+${pa:-0}+${pi:-0}+${pw:-0} ))
                [[ $tot -gt 0 ]] && ram=$(( (${pa:-0}+${pw:-0})*100/tot ))
            fi
            ;;
        linux|termux)
            cpu=$(_cpu_linux)
            if [[ -r /proc/meminfo ]]; then
                local mt; mt=$(awk '/MemTotal/{print $2}'     /proc/meminfo)
                local ma; ma=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
                [[ -n "$mt" && -n "$ma" && $mt -gt 0 ]] && ram=$(( (mt-ma)*100/mt ))
            fi
            ;;
    esac
    echo "$cpu $ram"
}

write_usage_bar() {
    local indent="$1" label="$2" usage="$3" bar_w="${4:-24}" inner="${5:-64}"
    [[ "$usage" == "N/A" ]] && return
    local bc="$NEON_GREEN"
    [[ $usage -gt 80 ]] && bc="$BLOOD_RED"
    [[ $usage -gt 60 && $usage -le 80 ]] && bc="$ORANGE"
    local filled=$(( usage * bar_w / 100 ))
    [[ $filled -gt $bar_w ]] && filled=$bar_w
    local bar=""
    for ((i=0; i<filled;     i++)); do bar+="$BLOCK";       done
    for ((i=filled; i<bar_w; i++)); do bar+="$BLOCK_EMPTY"; done

    local clean_lbl; clean_lbl=$(printf "%-10s" "$label")
    local clen=$(( 2 + 10 + 1 + bar_w + 2 + 4 ))
    local rpad=$(( inner - clen ))
    [[ $rpad -lt 0 ]] && rpad=0

    printf "%s%b%s%b  %b%s%b%b[%b%s%b%b]%b %b%3d%%%b%*s%b%s%b\n" \
        "$indent" "$PRIMARY" "$VLINE" "$RESET" \
        "$WHITE" "$clean_lbl" "$RESET" \
        "$DARK_GRAY" "$bc" "$bar" "$RESET" "$DARK_GRAY" "$RESET" \
        "$WHITE" "$usage" "$RESET" \
        "$rpad" "" \
        "$PRIMARY" "$VLINE" "$RESET"
}

# ═══════════════════════════════════════════════════
# DASHBOARD (Unified 66-Column Layout)
# ═══════════════════════════════════════════════════
show_dashboard() {
    local is_live="${1:-}"
    [[ -z "$is_live" ]] && { clear_screen; }
    load_config; get_theme_colors; get_cache
    get_terminal_size

    local user="${USER:-$(whoami 2>/dev/null || echo 'user')}"
    local host="${HOSTNAME:-$(hostname 2>/dev/null || echo 'localhost')}"; host="${host%%.*}"
    local os="Linux"

    case "$PLATFORM" in
        termux) os="Termux (Android)" ;;
        macos)  os="macOS $(sw_vers -productVersion 2>/dev/null)" ;;
        linux)
            if [[ -f /etc/os-release ]]; then
                os=$(. /etc/os-release && echo "${PRETTY_NAME:-Linux}")
            else
                os="$(uname -s) $(uname -r | cut -d- -f1)"
            fi
            ;;
    esac

    local datetime; datetime=$(date '+%Y-%m-%d %H:%M:%S')

    # Uptime calculation
    local uptime_str="N/A"
    if [[ -r /proc/uptime ]]; then
        local secs; secs=$(awk '{print int($1)}' /proc/uptime)
        local d=$(( secs/86400 )) h=$(( (secs%86400)/3600 )) m=$(( (secs%3600)/60 ))
        [[ $d -gt 0 ]] && uptime_str="${d}d ${h}h ${m}m" || uptime_str="${h}h ${m}m"
    elif [[ "$PLATFORM" == "macos" ]]; then
        local btime; btime=$(sysctl -n kern.boottime 2>/dev/null | awk -F'[sec = |,]' '{print $4}')
        if [[ -n "$btime" && "$btime" =~ ^[0-9]+$ ]]; then
            local now; now=$(date +%s)
            local secs=$(( now - btime ))
            local d=$(( secs/86400 )) h=$(( (secs%86400)/3600 )) m=$(( (secs%3600)/60 ))
            [[ $d -gt 0 ]] && uptime_str="${d}d ${h}h ${m}m" || uptime_str="${h}h ${m}m"
        fi
    fi

    local stats; stats=($( get_system_stats ))
    local cpu_u="${stats[0]:-15}" ram_u="${stats[1]:-35}"

    # Cyberpunk Stealth / Spoofing Mode
    if [[ "$STEALTH_MODE" == "true" ]]; then
        if [[ "$THEME" == "Unknown" ]]; then
            local ops=("Anonymous" "Unknown-2829" "Root-Null" "Operator-X" "Enigma" "Cipher-2829" "Shadow-Ghost")
            local hosts=("DARKNET-GATEWAY" "ANONYMOUS-NODE-X" "NULL-SECTOR-404" "CIPHER-GRID-2829" "SHADOW-RELAY-0" "VOID-MATRIX-2829")
            local systems=("Unknown Kernel v4.1.0 (Zero Footprint)" "Unknown Mesh OS v4.1.0 (Dark-Routing)" "Unknown Void Subsystem v4.1.0" "Unknown Protocol v4.1.0 (Ephemeral)")
            local uptimes=("Redacted (Zero-Log)" "Hidden Route (Active)" "Ephemeral Loop (Active)" "Zero-Trace (Cloaked)")
        else
            local ops=("Ghost" "Cipher" "Spectre" "Valkyrie" "Null" "Ronin" "Phantom-0")
            local hosts=("NEO-TOKYO-GRID" "SHADOW-NET-CORE" "ORBITAL-STATION-7" "BLACK-ICE-NODE" "NEURAL-MATRIX-01" "PHANTOM-GATEWAY")
            local systems=("Phantom OS v4.1.0 (Quantum Microkernel)" "Phantom Neural Core v4.1.0 (Sub-atomic)" "Phantom Mesh OS v4.1.0 (Encrypted)" "Phantom Quantum Kernel v4.1.0 (Ring-0)")
            local uptimes=("∞ (Untraceable)" "99.999% (Cloaked)" "Sub-atomic Flux (Active)" "Quantum Loop (Shielded)")
        fi
        user="${ops[$(( RANDOM % ${#ops[@]} ))]}"
        host="${hosts[$(( RANDOM % ${#hosts[@]} ))]}"
        os="${systems[$(( RANDOM % ${#systems[@]} ))]}"
        uptime_str="${uptimes[$(( RANDOM % ${#uptimes[@]} ))]}"
        cpu_u=$(( 9 + RANDOM % 7 ))
        ram_u=$(( 12 + RANDOM % 8 ))
    fi

    echo ""
    if [[ "$THEME" == "Unknown" ]]; then
        write_gradient_logo "$(get_unknown_logo)"
    else
        write_gradient_logo "$(get_phantom_logo)"
    fi
    echo ""

    # Box sizing (exact 66-character visual parity)
    local box_width=66
    [[ $TERM_WIDTH -lt 70 ]] && box_width=$(( TERM_WIDTH - 4 ))
    [[ $box_width -lt 34 ]] && box_width=34
    local inner=$(( box_width - 2 ))

    local padding=$(( (TERM_WIDTH - box_width) / 2 ))
    [[ $padding -lt 0 ]] && padding=0
    local ind; ind=$(printf "%${padding}s" "")
    local i hln=""
    for ((i=0; i<inner; i++)); do hln+="$HLINE"; done

    _border() { printf "%s%b%s%s%s%b\n" "$ind" "$PRIMARY" "$1" "$hln" "$2" "$RESET"; }
    _row() {
        local lbl="$1" val="$2" vc="$3"
        local content="  ${lbl}${val}"
        local cvl; cvl=$(_vlen "$content")
        while [[ $cvl -gt $(( inner - 2 )) && ${#val} -gt 1 ]]; do
            val="${val:0:$(( ${#val}-1 ))}"
            content="  ${lbl}${val}"
            cvl=$(_vlen "$content")
        done
        local rpad=$(( inner - cvl ))
        [[ $rpad -lt 0 ]] && rpad=0
        printf "%s%b%s%b  %b%s%b%b%s%b%*s%b%s%b\n" \
            "$ind" "$PRIMARY" "$VLINE" "$RESET" \
            "$WHITE" "$lbl" "$RESET" \
            "$vc" "$val" "$RESET" \
            "$rpad" "" \
            "$PRIMARY" "$VLINE" "$RESET"
    }

    _border "$TOP_LEFT" "$TOP_RIGHT"

    # Centered Title Row
    local skull_w=2
    local title_text="$TITLE v$SCRIPT_VERSION \"$SCRIPT_CODENAME\""
    local title_vis=$(( (skull_w + 2) + ${#title_text} + (2 + skull_w) ))
    local tpad=$(( inner - title_vis ))
    [[ $tpad -lt 0 ]] && tpad=0
    local hl=$(( tpad / 2 )); local hr=$(( tpad - hl ))
    printf "%s%b%s%*s%b%s  %s  %s%b%*s%b%s%b\n" \
        "$ind" "$PRIMARY" "$VLINE" \
        "$hl" "" "$SECONDARY" "$SKULL" "$title_text" "$SKULL" "$RESET" \
        "$hr" "" "$PRIMARY" "$VLINE" "$RESET"

    _border "$T_LEFT" "$T_RIGHT"

    if [[ "$SHOW_SYSTEM_INFO" == "true" ]]; then
        _row "Operator: " "$user"        "$NEON_GREEN"
        _row "Host:     " "$host"        "$GOLD"
        _row "System:   " "$os"          "$GOLD"
        _row "Uptime:   " "$uptime_str"  "$NEON_CYAN"
        _row "Time:     " "$datetime"    "$NEON_CYAN"

        if [[ "$SHOW_USAGE_BARS" == "true" ]]; then
            _border "$T_LEFT" "$T_RIGHT"
            local bar_w=$(( inner - 24 ))
            [[ $bar_w -lt 8 ]] && bar_w=8
            [[ $bar_w -gt 24 ]] && bar_w=24
            write_usage_bar "$ind" "CPU:" "$cpu_u" "$bar_w" "$inner"
            write_usage_bar "$ind" "RAM:" "$ram_u" "$bar_w" "$inner"
        fi
        _border "$T_LEFT" "$T_RIGHT"
    fi

    # Quote Row
    local qi=$(( RANDOM % ${#QUOTES[@]} ))
    local quote="${QUOTES[$qi]}"
    local qvl; qvl=$(_vlen "$quote")
    while [[ $qvl -gt $(( inner - 4 )) && ${#quote} -gt 1 ]]; do
        quote="${quote:0:$(( ${#quote}-1 ))}"
        qvl=$(_vlen "$quote")
    done
    local qpad=$(( inner - qvl - 2 ))
    [[ $qpad -lt 0 ]] && qpad=0
    printf "%s%b%s  %b%s%b%*s%b%s%b\n" \
        "$ind" "$PRIMARY" "$VLINE" \
        "$GRAY" "$quote" "$RESET" \
        "$qpad" "" \
        "$PRIMARY" "$VLINE" "$RESET"

    _border "$BOTTOM_LEFT" "$BOTTOM_RIGHT"
    echo ""

    if [[ "${UPDATE_AVAILABLE:-false}" == "true" ]]; then
        if [[ "${UPDATE_DOWNLOADED:-false}" == "true" ]]; then
            printf "%s%b%s Updated to v%s! Reopen terminal to apply.%b\n\n" "$ind" "$NEON_GREEN" "$UPDATE" "$LATEST_VERSION" "$RESET"
        else
            printf "%s%b%s Update v%s available (run 'phantom-update')%b\n\n" "$ind" "$GOLD" "$UPDATE" "$LATEST_VERSION" "$RESET"
        fi
    fi

    local hcmd="phantom-help"
    [[ "$THEME" == "Unknown" ]] && hcmd="unknown-help"
    printf "%s%bType '%b%s%b' for commands.%b\n\n" "$ind" "$DARK_GRAY" "$GOLD" "$hcmd" "$DARK_GRAY" "$RESET"
}

# ═══════════════════════════════════════════════════
# IN-PLACE LIVE MONITOR (phantom-dash -Live)
# ═══════════════════════════════════════════════════
start_phantom_live_monitor() {
    trap 'show_cursor; trap - INT TERM; return 0 2>/dev/null || exit 0' INT TERM
    hide_cursor
    clear_screen
    printf "%bEntering Phantom Live Dashboard. Press ANY KEY to exit...%b\n" "$DARK_GRAY" "$RESET"
    sleep 0.4
    while true; do
        show_dashboard "live"
        if read -t 1 -n 1; then
            break
        fi
    done
    show_cursor
    trap - INT TERM
    clear_screen
    printf "%b[+] Live monitor stopped.%b\n\n" "$NEON_GREEN" "$RESET"
}

# ═══════════════════════════════════════════════════
# ANIMATIONS
# ═══════════════════════════════════════════════════
write_gradient_logo() {
    local art="$1"
    local lines=()
    while IFS= read -r line || [[ -n "$line" ]]; do
        lines+=("$line")
    done <<< "$art"
    get_terminal_size
    local max_w=0
    for line in "${lines[@]}"; do [[ ${#line} -gt $max_w ]] && max_w=${#line}; done
    local sc=$(( (TERM_WIDTH - max_w) / 2 )); [[ $sc -lt 0 ]] && sc=0
    local n=0
    for line in "${lines[@]}"; do
        local c
        [[ "$GRADIENT_TEXT" == "true" ]] \
            && c="${GRADIENT_COLORS[$(( n % ${#GRADIENT_COLORS[@]} ))]}" \
            || c="$PRIMARY"
        printf "%${sc}s%b%s%b\n" "" "$c" "$line" "$RESET"
        n=$(( n+1 ))
    done
}

_skip_requested=false

_check_skip_key() {
    [[ "$_skip_requested" == "true" ]] && return 0
    # read -t 0 is supported in Bash 4+ and Zsh without blocking
    if [[ -n "${BASH_VERSINFO[0]:-}" && ${BASH_VERSINFO[0]} -ge 4 ]] || [[ -n "${ZSH_VERSION:-}" ]]; then
        if read -t 0 2>/dev/null; then
            local key
            read -n 1 key 2>/dev/null || true
            _skip_requested=true
            return 0
        fi
    fi
    return 1
}

show_security_loading_bar() {
    local desc="$1" steps="${2:-8}" color="${3:-$PRIMARY}"
    local bar_w=$steps
    [[ "$IS_SMALL_SCREEN" == "true" ]] && bar_w=$(( steps / 2 ))
    [[ $bar_w -lt 4 ]] && bar_w=4

    for ((i=1; i<=bar_w; i++)); do
        _check_skip_key && return 0
        local filled="" empty=""
        for ((f=0; f<i; f++)); do filled+="$BLOCK"; done
        for ((e=i; e<bar_w; e++)); do empty+="$BLOCK_EMPTY"; done
        local pct=$(( i * 100 / bar_w ))
        printf "\r  %b%s%b %b[%b%s%b%s] %b%3d%%%b" \
            "$GRAY" "$desc" "$RESET" \
            "$DARK_GRAY" "$color" "$filled" "$DARK_GRAY" "$empty" \
            "$WHITE" "$pct" "$RESET"
        sleep 0.022
    done
    printf " %b%s%b\n" "$NEON_GREEN" "$SUCCESS" "$RESET"
}

show_security_sequence() {
    clear_screen; echo ""; echo ""
    write_centered "$SHIELD INITIALIZING SECURITY PROTOCOLS $SHIELD" "$PRIMARY"
    echo ""
    local s=$SECURITY_LOAD_STEPS
    show_security_loading_bar "$LOCK Initializing AES-256 Encryption" "$s" "$PRIMARY"
    show_security_loading_bar "$LOCK Generating SHA-512 Hashes"       "$s" "$PRIMARY"
    show_security_loading_bar "$LOCK Activating Firewall Matrix"     "$s" "$PRIMARY"
    show_security_loading_bar "$LOCK Establishing Secure Channel"    "$s" "$PRIMARY"
    sleep 0.1
}

show_core_ignition() {
    clear_screen; get_terminal_size
    local y=$(( TERM_HEIGHT / 2 - 3 )); [[ $y -lt 1 ]] && y=1
    local labels=("[CORE_INIT]" "[ENCRYPTION_KEYS]" "[FIREWALL_MATRIX]" "[AUTH_BYPASS]" "[SYSTEM_ARMED]")
    for lbl in "${labels[@]}"; do
        _check_skip_key && return 0
        write_centered "$HIGH_VOLTAGE $lbl" "$BLOOD_RED"
        sleep 0.04
        write_centered "$HIGH_VOLTAGE $lbl" "$PRIMARY"
        sleep 0.02
        y=$(( y+1 ))
    done
    sleep 0.1
}

show_multicolor_matrix() {
    local duration="${1:-2}"
    clear_screen; get_terminal_size
    local chars="$MATRIX_CHARS"
    [[ "$MATRIX_MODE" == "Binary" ]] && chars="01"

    local col_step=2 sleep_time=0.030
    if [[ "$PLATFORM" == "termux" || "$IS_SMALL_SCREEN" == "true" ]]; then
        col_step=3; sleep_time=0.050; [[ $duration -gt 2 ]] && duration=2
    fi

    local drops=()
    for ((col=0; col<TERM_WIDTH; col+=col_step)); do
        local idx=$(( col + 1 ))
        drops[$idx]=$(( RANDOM % TERM_HEIGHT + 1 ))
    done

    local end_time=$(( SECONDS + duration ))
    while [[ $SECONDS -lt $end_time ]]; do
        _check_skip_key && break
        for ((col=0; col<TERM_WIDTH; col+=col_step)); do
            [[ $(( RANDOM % 10 )) -lt 3 ]] && continue
            local idx=$(( col + 1 ))
            local ch="${chars:$(( RANDOM % ${#chars} )):1}"
            local col_c="${MATRIX_COLORS[$(( col % ${#MATRIX_COLORS[@]} ))]}"
            local row=${drops[$idx]:-1}

            if [[ $row -le $TERM_HEIGHT && $row -ge 1 ]]; then
                move_cursor "$row" "$col"
                printf "%b%s" "$col_c" "$ch"
                local lead=$(( row + 1 ))
                if [[ $lead -le $TERM_HEIGHT ]]; then
                    move_cursor "$lead" "$col"
                    printf "%b%s" "$WHITE" "$ch"
                fi
            fi
            drops[$idx]=$(( row + 1 ))
            if [[ ${drops[$idx]} -gt $TERM_HEIGHT ]]; then
                [[ $(( RANDOM % 4 )) -eq 0 ]] && drops[$idx]=1 || drops[$idx]=$(( TERM_HEIGHT + RANDOM % 6 ))
            fi
        done
        sleep "$sleep_time"
    done
    printf "%b" "$RESET"
}

show_glitch_reveal() {
    local art="$1"; clear_screen; get_terminal_size
    local lines=()
    while IFS= read -r line || [[ -n "$line" ]]; do
        lines+=("$line")
    done <<< "$art"

    local max_w=0
    for line in "${lines[@]}"; do [[ ${#line} -gt $max_w ]] && max_w=${#line}; done
    local sc=$(( (TERM_WIDTH - max_w) / 2 )); [[ $sc -lt 1 ]] && sc=1
    local sr=$(( (TERM_HEIGHT - ${#lines[@]}) / 2 - 1 )); [[ $sr -lt 2 ]] && sr=2
    local glitch='!@#$%_+-=:;,.?/\\|~^'

    for ((g=0; g<GLITCH_INTENSITY; g++)); do
        _check_skip_key && break
        local row=$sr
        for line in "${lines[@]}"; do
            move_cursor "$row" "$sc"
            local out=""
            for ((i=0; i<${#line}; i++)); do
                local ch="${line:$i:1}"
                [[ "$ch" != " " && $(( RANDOM%10 )) -lt 4 ]] \
                    && out+="${glitch:$(( RANDOM % ${#glitch} )):1}" \
                    || out+="$ch"
            done
            printf "%b%s%b" "$BRIGHT_RED" "$out" "$RESET"
            row=$(( row+1 ))
        done
        sleep 0.035
    done

    clear_screen; echo ""
    write_gradient_logo "$art"
    sleep 0.2
}

# ═══════════════════════════════════════════════════
# STARTUP COORDINATOR & UPDATE CELEBRATION
# ═══════════════════════════════════════════════════
show_update_celebration() {
    local old_ver="${1:-}"
    get_terminal_size
    local box_w=66
    [[ $TERM_WIDTH -lt 70 ]] && box_w=$(( TERM_WIDTH - 4 ))
    [[ $box_w -lt 34 ]] && box_w=34
    local inner=$(( box_w - 2 ))
    local pad=$(( (TERM_WIDTH - box_w) / 2 )); [[ $pad -lt 0 ]] && pad=0
    local ind; ind=$(printf "%${pad}s" "")
    local i hln=""
    for ((i=0; i<inner; i++)); do hln+="$HLINE"; done

    echo ""
    printf "%s%b%s%s%s%b\n" "$ind" "$PRIMARY" "$TOP_LEFT" "$hln" "$TOP_RIGHT" "$RESET"
    local title="⚡ SYSTEM UPGRADE SUCCESSFUL ⚡"
    local tvl; tvl=$(_vlen "$title")
    local tpad=$(( inner - tvl ))
    local hl=$(( tpad / 2 )); local hr=$(( tpad - hl ))
    printf "%s%b%s%*s%b%s%b%*s%b%s%b\n" \
        "$ind" "$PRIMARY" "$VLINE" \
        "$hl" "" "$GOLD" "$title" "$RESET" \
        "$hr" "" "$PRIMARY" "$VLINE" "$RESET"
    printf "%s%b%s%s%s%b\n" "$ind" "$PRIMARY" "$BOTTOM_LEFT" "$hln" "$BOTTOM_RIGHT" "$RESET"

    local p="phantom"; [[ "$THEME" == "Unknown" ]] && p="unknown"
    echo ""
    printf "%s%b  %s v%s \"%s\" is now online!%b\n\n" "$ind" "$NEON_GREEN" "$TITLE" "$SCRIPT_VERSION" "$SCRIPT_CODENAME" "$RESET"
    printf "%s%b  Highlights in v%s:%b\n" "$ind" "$WHITE" "$SCRIPT_VERSION" "$RESET"
    printf "%s%b  [+] Zero Dependencies:%b 100%% Native Shell (Zero Python/pip/jq)\n" "$ind" "$NEON_CYAN" "$GRAY"
    printf "%s%b  [+] Instant Keypress Skip:%b Smooth launch on Spacebar or Enter\n" "$ind" "$NEON_CYAN" "$GRAY"
    printf "%s%b  [+] Precision 66-Column Box:%b Unified alignment & closed borders\n" "$ind" "$NEON_CYAN" "$GRAY"
    printf "%s%b  [+] Live Telemetry:%b Real-time hardware HUD (${p}-top / ${p}-dash -Live)\n" "$ind" "$NEON_CYAN" "$GRAY"
    printf "\n"
    printf "%s%b  Type '%b%s-help%b' or '%b%s-changelog%b' to explore.%b\n\n" "$ind" "$DARK_GRAY" "$GOLD" "$p" "$DARK_GRAY" "$GOLD" "$p" "$DARK_GRAY" "$RESET"

    local cl_file="$CONFIG_DIR/latest_changelog.md"
    if [[ ! -f "$cl_file" ]]; then
        local this_src="${BASH_SOURCE[0]:-${(%):-%x}}"
        local candidate=""
        [[ -n "$this_src" ]] && candidate="$(dirname "$this_src")/docs/changelogs/v$SCRIPT_VERSION.md"
        [[ -n "$candidate" && -f "$candidate" ]] && cl_file="$candidate"
    fi
    if [[ -f "$cl_file" ]]; then
        printf "%s%bChangelog Highlights:%b\n" "$ind" "$GOLD" "$RESET"
        local count=0
        while IFS= read -r ln || [[ -n "$ln" ]]; do
            if [[ -n "$ln" && "$ln" != "#"* ]]; then
                printf "%s  %b%s%b\n" "$ind" "$GRAY" "$ln" "$RESET"
                count=$(( count + 1 ))
                [[ $count -ge 6 ]] && break
            fi
        done < "$cl_file"
        echo ""
    fi

    # Smooth pause with keypress skip
    for ((k=0; k<12; k++)); do
        sleep 0.1
        if _check_skip_key; then
            break
        fi
    done
}

start_phantom_terminal() {
    local force=false
    [[ "${1:-}" == "--force" || "${1:-}" == "-f" ]] && force=true
    if _is_agent_session && [[ "$force" == "false" ]]; then return; fi

    load_config; get_theme_colors; get_cache

    # Post-Update Celebration & Changelog Modal
    if [[ -z "$LAST_SEEN_VERSION" ]] || version_gt "$SCRIPT_VERSION" "$LAST_SEEN_VERSION"; then
        show_update_celebration "$LAST_SEEN_VERSION"
        LAST_SEEN_VERSION="$SCRIPT_VERSION"
        UPDATE_DOWNLOADED=false
        UPDATE_AVAILABLE=false
        save_cache "$LAST_UPDATE_CHECK" "$LATEST_VERSION" false false "$SCRIPT_VERSION"
    fi

    if [[ (-n "${PHANTOM_SESSION_ACTIVE:-}" || -n "${UNKNOWN_SESSION_ACTIVE:-}") && "$force" == "false" ]]; then
        show_dashboard
        return
    fi
    export PHANTOM_SESSION_ACTIVE="1"
    export UNKNOWN_SESSION_ACTIVE="1"

    [[ "$ANIMATION_ENABLED" != "true" && "$force" == "false" ]] && { show_dashboard; return; }

    _skip_requested=false
    # Trap INT/TERM strictly during animation execution to restore cursor without killing shell
    trap 'show_cursor; trap - INT TERM; return 0 2>/dev/null || exit 0' INT TERM
    hide_cursor
    [[ "$_skip_requested" != "true" ]] && show_core_ignition
    [[ "$_skip_requested" != "true" ]] && show_security_sequence
    [[ "$_skip_requested" != "true" ]] && show_multicolor_matrix "$MATRIX_DURATION"
    if [[ "$_skip_requested" != "true" ]]; then
        if [[ "$THEME" == "Unknown" ]]; then
            show_glitch_reveal "$(get_unknown_logo)"
        else
            show_glitch_reveal "$(get_phantom_logo)"
        fi
    fi
    show_dashboard
    show_cursor
    trap - INT TERM
    # Drain any buffered keystrokes without blocking (Bash 4+ and Zsh)
    if [[ -n "${BASH_VERSINFO[0]:-}" && ${BASH_VERSINFO[0]} -ge 4 ]] || [[ -n "${ZSH_VERSION:-}" ]]; then
        while read -t 0 2>/dev/null; do
            read -n 1 2>/dev/null || break
        done
    fi

    # Asynchronous non-blocking background update check
    if [[ "$AUTO_CHECK_UPDATES" == "true" ]]; then
        (
            _bg_update_check
        ) &>/dev/null &
        disown 2>/dev/null || true
    fi
}

# ═══════════════════════════════════════════════════
# USER COMMANDS & ALIASES
# ═══════════════════════════════════════════════════
phantom-reload() { start_phantom_terminal --force; }
phantom-matrix() {
    load_config; get_theme_colors
    trap 'show_cursor; trap - INT TERM; return 0 2>/dev/null || exit 0' INT TERM
    hide_cursor; show_multicolor_matrix 5; show_cursor
    trap - INT TERM
}
phantom-dash() {
    load_config; get_theme_colors
    if [[ "${1:-}" == "-Live" || "${1:-}" == "-l" || "${1:-}" == "--live" ]]; then
        start_phantom_live_monitor
    else
        show_dashboard
    fi
}
phantom-top()    { phantom-dash -Live; }
phantom-live()   { phantom-dash -Live; }

phantom-stealth() {
    load_config
    local act="${1:-}"
    if [[ "$act" == "on" ]]; then
        STEALTH_MODE="true"; save_config
        echo "${NEON_GREEN}[+] Cyberpunk Stealth Mode: ACTIVE${RESET}"
        echo "${DARK_GRAY}System specs and identity are now masked.${RESET}"
    elif [[ "$act" == "off" ]]; then
        STEALTH_MODE="false"; save_config
        echo "${GOLD}[-] Cyberpunk Stealth Mode: DEACTIVATED${RESET}"
        echo "${DARK_GRAY}Real system specifications restored.${RESET}"
    elif [[ "$act" == "toggle" ]]; then
        [[ "$STEALTH_MODE" == "true" ]] && STEALTH_MODE="false" || STEALTH_MODE="true"
        save_config
        echo "${NEON_CYAN}[*] Stealth Mode is now: $STEALTH_MODE${RESET}"
    else
        echo ""
        echo "${NEON_CYAN}Cyberpunk Stealth Mode: $STEALTH_MODE${RESET}"
        echo "${DARK_GRAY}Usage: phantom-stealth on | off | toggle${RESET}"
        echo ""
    fi
}

_filter_phantom_history_cmd() {
    local cmd="$1"
    if [[ "$cmd" == :* ]]; then
        local stripped="${cmd#*: }"
        cmd="${stripped#*;}"
    fi
    cmd=$(echo "$cmd" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [[ -z "$cmd" || "$cmd" == "#"* ]] && return 1

    local lcmd; lcmd=$(echo "$cmd" | tr '[:upper:]' '[:lower:]')
    local pat_pwd='(--password[=[:space:]]|--passwd[=[:space:]]|password[=:]|passwd[=:])'
    local pat_tok='(--token[=[:space:]]|token[=:]|bearer[[:space:]]+[a-z0-9_\-\.]+|authorization:[[:space:]]*bearer)'
    local pat_key='(--api[-_]?key[=[:space:]]|api[-_]?key[=:]|apikey[=:])'
    local pat_sec='(--secret[=[:space:]]|secret[=:]|aws[-_]?(secret|session)[-_]?[a-z]*[=:])'
    local pat_rsa='(private[-_]?key|begin[[:space:]]+(rsa|openssh|ec|dsa|pgp)?[[:space:]]*private[[:space:]]key|id_rsa|id_ed25519)'
    local pat_exp='(export[[:space:]]+[a-z0-9_]*(key|secret|token|password)[[:space:]]*=)'
    local pat_curl='(curl[[:space:]]+.*(-u|--user)[[:space:]]+[^[:space:]]+:[^[:space:]]+)'
    local pat_raw='(gh[pousr]_[a-z0-9_]{16,}|akia[0-9a-z]{16}|xox[baprs]-[0-9a-z-]+|sk-[a-z0-9]{20,}|(mysql|mysqldump|mariadb)[[:space:]]+.*-p[^[:space:]]+)'

    if [[ "$lcmd" =~ $pat_pwd ]] || \
       [[ "$lcmd" =~ $pat_tok ]] || \
       [[ "$lcmd" =~ $pat_key ]] || \
       [[ "$lcmd" =~ $pat_sec ]] || \
       [[ "$lcmd" =~ $pat_rsa ]] || \
       [[ "$lcmd" =~ $pat_exp ]] || \
       [[ "$lcmd" =~ $pat_curl ]] || \
       [[ "$lcmd" =~ $pat_raw ]]; then
        return 1
    fi
    echo "$cmd"
    return 0
}

phantom-search() {
    local query="${1:-}"
    echo ""
    echo "${NEON_CYAN}=== Phantom Command History ===${RESET}"
    local hist_file="$HOME/.bash_history"
    [[ -n "${ZSH_VERSION:-}" || "${SHELL:-}" == *"zsh"* ]] && hist_file="$HOME/.zsh_history"
    if [[ ! -f "$hist_file" ]]; then
        if [[ -f "$HOME/.bash_history" ]]; then hist_file="$HOME/.bash_history"; fi
    fi

    if [[ -f "$hist_file" ]]; then
        local matches
        matches=$(tail -n 300 "$hist_file" 2>/dev/null | awk '
            /^: [0-9]+:[0-9]+;/ { sub(/^: [0-9]+:[0-9]+;[[:space:]]*/, "") }
            NF && !/^#/ {
                cmd = $0
                lcmd = tolower(cmd)
                if (lcmd ~ /(--password[= ]|--passwd[= ]|password[=:]|passwd[=:])/ || \
                    lcmd ~ /(--token[= ]|token[=:]|bearer[ ]+[a-z0-9_\-\.]+|authorization:[ ]*bearer)/ || \
                    lcmd ~ /(--api[-_]?key[= ]|api[-_]?key[=:]|apikey[=:])/ || \
                    lcmd ~ /(--secret[= ]|secret[=:]|aws[-_]?(secret|session)[-_]?[a-z]*[=:])/ || \
                    lcmd ~ /(private[-_]?key|begin[ ]+(rsa|openssh|ec|dsa|pgp)?[ ]*private key|id_rsa|id_ed25519)/ || \
                    lcmd ~ /(export[ ]+[a-z0-9_]*(key|secret|token|password)[ ]*=)/ || \
                    lcmd ~ /(curl[ ]+.*(-u|--user)[ ]+[^ ]+:[^ ]+)/) {
                    next
                }
                print cmd
            }
        ' | awk -v q="$query" '
            q == "" || index(tolower($0), tolower(q)) > 0 {
                if (!seen[$0]++) {
                    order[++count] = $0
                }
            }
            END {
                start = (count > 15) ? (count - 14) : 1
                idx = 1
                for (i = start; i <= count; i++) {
                    printf "  \033[38;5;220m[%d]\033[0m \033[1;37m%s\033[0m\n", idx++, order[i]
                }
            }
        ')

        if [[ -n "$matches" ]]; then
            printf "%b\n" "$matches"
        else
            echo "${DARK_GRAY}No matching command history recorded.${RESET}"
        fi
    else
        echo "${DARK_GRAY}No shell history available.${RESET}"
    fi
    echo ""
}

phantom-history() { phantom-search "$@"; }

phantom-help() {
    load_config; get_theme_colors
    local p="phantom"; [[ "$THEME" == "Unknown" ]] && p="unknown"
    echo ""
    echo "${NEON_CYAN}=== $TITLE v$SCRIPT_VERSION \"$SCRIPT_CODENAME\" ===${RESET}"
    echo ""
    echo "  ${GOLD}${p}-reload${WHITE}        - Replay startup animation${RESET}"
    echo "  ${GOLD}${p}-theme${WHITE}         - Switch theme (Phantom/Unknown)${RESET}"
    echo "  ${GOLD}${p}-config${WHITE}        - Show configuration${RESET}"
    echo "  ${GOLD}${p}-config --edit${WHITE} - Edit config in \$EDITOR${RESET}"
    echo "  ${GOLD}${p}-dash${WHITE}          - Show system dashboard${RESET}"
    echo "  ${GOLD}${p}-dash -Live${WHITE}    - Live in-place dashboard monitor${RESET}"
    echo "  ${GOLD}${p}-stealth${WHITE}       - Toggle privacy spoofing (on/off)${RESET}"
    echo "  ${GOLD}${p}-search${WHITE}        - Smart history command predictor${RESET}"
    echo "  ${GOLD}${p}-matrix${WHITE}        - Matrix rain animation${RESET}"
    echo "  ${GOLD}${p}-update${WHITE}        - Check for updates${RESET}"
    echo "  ${GOLD}${p}-changelog${WHITE}     - View release notes & changelog${RESET}"
    echo ""
}

phantom-config() {
    load_config
    if [[ "${1:-}" == "-edit" || "${1:-}" == "--edit" ]]; then
        ${EDITOR:-nano} "$CONFIG_FILE"; return
    fi
    echo ""
    echo "${NEON_CYAN}Config: $CONFIG_FILE${RESET}"; echo ""
    for pair in \
        "Theme:$THEME" "AnimationEnabled:$ANIMATION_ENABLED" \
        "MatrixMode:$MATRIX_MODE" "MatrixDuration:$MATRIX_DURATION" \
        "SecurityLoadSteps:$SECURITY_LOAD_STEPS" "GlitchIntensity:$GLITCH_INTENSITY" \
        "ShowSystemInfo:$SHOW_SYSTEM_INFO" "ShowUsageBars:$SHOW_USAGE_BARS" \
        "ShowFullPath:$SHOW_FULL_PATH" "GradientText:$GRADIENT_TEXT" \
        "StealthMode:$STEALTH_MODE" "SmartSuggestions:$SMART_SUGGESTIONS" \
        "AutoCheckUpdates:$AUTO_CHECK_UPDATES"
    do
        local k="${pair%%:*}" v="${pair#*:}"
        echo "  ${GOLD}${k}${WHITE}: ${v}${RESET}"
    done
    echo ""; echo "${DARK_GRAY}phantom-config --edit to change settings${RESET}"; echo ""
}

phantom-theme() {
    local t="${1:-}"; load_config
    if [[ -z "$t" ]]; then
        echo ""; echo "${NEON_CYAN}Themes: Phantom, Unknown${RESET}"
        echo "${GOLD}Current: $THEME${RESET}"
        echo "${DARK_GRAY}Usage: phantom-theme Unknown${RESET}"; echo ""; return
    fi
    case "$t" in
        [uU][nN][kK][nN][oO][wW][nN]) THEME="Unknown" ;;
        [pP][hH][aA][nN][tT][oO][mM]) THEME="Phantom" ;;
        *) echo "${BLOOD_RED}Available: Phantom, Unknown${RESET}"; return ;;
    esac
    save_config
    echo "${NEON_GREEN}Theme set to: $THEME — run 'phantom-reload' to apply.${RESET}"
}

_bg_update_check() {
    command -v curl &>/dev/null || return 0
    get_cache
    local now; now=$(date +%s 2>/dev/null || echo 0)
    if [[ -n "$LAST_UPDATE_CHECK" ]]; then
        local check_interval=$(( ${UPDATE_CHECK_DAYS:-1} * 86400 ))
        local diff=$(( now - LAST_UPDATE_CHECK ))
        if [[ $diff -lt $check_interval && "$UPDATE_AVAILABLE" == "true" ]]; then
            return 0
        fi
    fi

    local resp; resp=$(curl -sf --max-time 4 "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest" 2>/dev/null || echo "")
    [[ -z "$resp" ]] && return 0

    local latest; latest=$(echo "$resp" | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"v\?\([^"]*\)".*/\1/')
    [[ -z "$latest" ]] && return 0

    if version_gt "$latest" "$SCRIPT_VERSION"; then
        # Save release notes if present
        echo "$resp" | grep -o '"body"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"body"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/' | sed 's/\\n/\n/g; s/\\r//g' > "$CONFIG_DIR/release_notes.txt" 2>/dev/null || true
        # Download changelog markdown if available
        curl -fsSL --max-time 8 "https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/v$latest/docs/changelogs/v$latest.md" -o "$CONFIG_DIR/latest_changelog.md" 2>/dev/null || true
        save_cache "$now" "$latest" true false "$LAST_SEEN_VERSION"
    else
        save_cache "$now" "$latest" false false "$LAST_SEEN_VERSION"
    fi
}

phantom-update() {
    load_config; get_cache
    echo "${NEON_CYAN}Checking for updates...${RESET}"
    command -v curl &>/dev/null || { echo "${BLOOD_RED}curl not found.${RESET}"; return 1; }

    local resp; resp=$(curl -sf "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest" 2>/dev/null || echo "")
    [[ -z "$resp" ]] && { echo "${BLOOD_RED}Update check failed: cannot reach GitHub API.${RESET}"; return 1; }

    local latest; latest=$(echo "$resp" | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"v\?\([^"]*\)".*/\1/')
    [[ -z "$latest" ]] && { echo "${BLOOD_RED}Update check failed: invalid release tag.${RESET}"; return 1; }

    local now; now=$(date +%s 2>/dev/null || echo 0)

    if version_gt "$latest" "$SCRIPT_VERSION"; then
        echo "${GOLD}Updating Phantom Terminal to v$latest...${RESET}"

        # Save release notes and changelog markdown
        echo "$resp" | grep -o '"body"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"body"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/' | sed 's/\\n/\n/g; s/\\r//g' > "$CONFIG_DIR/release_notes.txt" 2>/dev/null || true
        curl -fsSL --max-time 8 "https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/v$latest/docs/changelogs/v$latest.md" -o "$CONFIG_DIR/latest_changelog.md" 2>/dev/null || true

        # Detect active script installation path dynamically
        local sp="${BASH_SOURCE[0]:-${(%):-%x}}"
        [[ -z "$sp" || ! -f "$sp" ]] && sp="$CONFIG_DIR/PhantomStartup.sh"
        if [[ ! -w "$(dirname "$sp")" ]]; then
            sp="$CONFIG_DIR/PhantomStartup.sh"
        fi
        local sp_tmp="${sp}.tmp"
        [[ -f "$sp" ]] && cp "$sp" "${sp}.bak"

        # Download strictly by immutable release tag (never from mutable main branch)
        local dl_url="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/v$latest/PhantomStartup.sh"
        if ! curl -fsSL --max-time 15 "$dl_url" -o "$sp_tmp" 2>/dev/null || [[ ! -s "$sp_tmp" ]]; then
            dl_url="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$latest/PhantomStartup.sh"
            curl -fsSL --max-time 15 "$dl_url" -o "$sp_tmp" 2>/dev/null || true
        fi

        # Strict fail-closed SHA-256 release checksum verification
        local checksum_ok=false
        local sums_tmp="${sp}.sums"
        local sums_url="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/v$latest/SHA256SUMS"
        if ! curl -fsSL --max-time 10 "$sums_url" -o "$sums_tmp" 2>/dev/null || [[ ! -s "$sums_tmp" ]]; then
            sums_url="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$latest/SHA256SUMS"
            curl -fsSL --max-time 10 "$sums_url" -o "$sums_tmp" 2>/dev/null || true
        fi

        if [[ -s "$sums_tmp" ]]; then
            local expected_hash
            expected_hash=$(grep -E "(^|[[:space:]])PhantomStartup\.sh($|[[:space:]])" "$sums_tmp" | awk '{print $1}' | head -1 | tr '[:upper:]' '[:lower:]')
            if [[ "$expected_hash" =~ ^[a-f0-9]{64}$ ]]; then
                local actual_hash=""
                if command -v sha256sum &>/dev/null; then
                    actual_hash=$(sha256sum "$sp_tmp" 2>/dev/null | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
                elif command -v shasum &>/dev/null; then
                    actual_hash=$(shasum -a 256 "$sp_tmp" 2>/dev/null | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
                elif command -v openssl &>/dev/null; then
                    actual_hash=$(openssl dgst -sha256 "$sp_tmp" 2>/dev/null | awk '{print $NF}' | tr '[:upper:]' '[:lower:]')
                fi

                if [[ -z "$actual_hash" ]]; then
                    echo "${BLOOD_RED}Update integrity check failed: No SHA-256 calculation utility (sha256sum, shasum, openssl) available.${RESET}"
                elif [[ "$actual_hash" == "$expected_hash" ]]; then
                    checksum_ok=true
                else
                    echo "${BLOOD_RED}Update integrity check failed: SHA-256 mismatch! Expected $expected_hash, Got $actual_hash.${RESET}"
                fi
            else
                echo "${BLOOD_RED}Update integrity check failed: No valid SHA-256 hash found for PhantomStartup.sh in release manifest.${RESET}"
            fi
            rm -f "$sums_tmp"
        else
            echo "${BLOOD_RED}Update integrity check failed: SHA256SUMS release manifest could not be retrieved. Aborting for security.${RESET}"
        fi

        if [[ "$checksum_ok" == "true" && -s "$sp_tmp" ]] && grep -q "Phantom Terminal\|PhantomStartup" "$sp_tmp" && bash -n "$sp_tmp" 2>/dev/null; then
            mv -f "$sp_tmp" "$sp"
            chmod +x "$sp"
            save_cache "$now" "$latest" false false "$SCRIPT_VERSION"
            echo "${NEON_GREEN}Updated successfully to v$latest! Restart terminal or run 'phantom-reload' to apply.${RESET}"
        else
            rm -f "$sp_tmp"
            echo "${BLOOD_RED}Update failed integrity verification. Active installation preserved.${RESET}"
        fi
    else
        echo "${NEON_GREEN}Already up to date (v$SCRIPT_VERSION).${RESET}"
        save_cache "$now" "$SCRIPT_VERSION" false false "$LAST_SEEN_VERSION"
    fi
}

phantom-changelog() {
    load_config; get_theme_colors
    local cl_file="$CONFIG_DIR/latest_changelog.md"
    if [[ ! -f "$cl_file" ]]; then
        local this_src="${BASH_SOURCE[0]:-${(%):-%x}}"
        local candidate=""
        [[ -n "$this_src" ]] && candidate="$(dirname "$this_src")/docs/changelogs/v$SCRIPT_VERSION.md"
        [[ -n "$candidate" && -f "$candidate" ]] && cl_file="$candidate"
    fi
    if [[ -f "$cl_file" ]]; then
        echo ""
        echo "${NEON_CYAN}=== Phantom Terminal v$SCRIPT_VERSION Changelog ===${RESET}"
        echo ""
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" == "# "* ]]; then
                echo "${GOLD}$line${RESET}"
            elif [[ "$line" == "## "* ]]; then
                echo ""
                echo "${NEON_GREEN}$line${RESET}"
            elif [[ "$line" == "### "* ]]; then
                echo "${WHITE}$line${RESET}"
            elif [[ "$line" == "- "* || "$line" == "* "* ]]; then
                echo "  ${NEON_CYAN}•${GRAY} ${line:2}${RESET}"
            else
                echo "${DARK_GRAY}$line${RESET}"
            fi
        done < "$cl_file"
        echo ""
    else
        echo "${DARK_GRAY}No local changelog found for v$SCRIPT_VERSION.${RESET}"
        echo ""
    fi
}

# ═══════════════════════════════════════════════════
# EASTER EGGS
# ═══════════════════════════════════════════════════
phantom-chosen() {
    load_config; get_theme_colors; clear_screen; echo ""; echo ""
    write_centered "╔════════════════════════════════════════╗" "$PRIMARY"
    write_centered "║     ${GOLD}✦ THE CHOSEN ONE ✦${PRIMARY}          ║" "$PRIMARY"
    write_centered "╚════════════════════════════════════════╝" "$PRIMARY"
    echo ""
    write_centered "You have been granted access." "$SECONDARY"
    write_centered "Power. Knowledge. Control."    "$ACCENT"
    echo ""; write_centered "The path is now open." "$GRAY"; echo ""
    _save_secret "chosen"
}

phantom-2829() {
    load_config; get_theme_colors; clear_screen; hide_cursor
    echo ""; sleep 0.3
    write_centered "Initializing..." "$DARK_GRAY"; sleep 0.4; clear_screen; echo ""
    write_centered "╔══════════════════════════════════════════════════╗" "$PRIMARY"
    write_centered "║         ${NEON_PURPLE}⚡ CREATOR'S MARK ⚡${PRIMARY}                  ║" "$PRIMARY"
    write_centered "╚══════════════════════════════════════════════════╝" "$PRIMARY"
    echo ""; sleep 0.3
    write_centered "${NEON_CYAN}@unknownlll2829${RESET}" "$WHITE"; sleep 0.3
    write_centered "Master of Terminals, Architect of Code" "$GRAY"; echo ""
    write_centered "${HOT_PINK}⟨ The Phantom That Never Sleeps ⟩${RESET}" "$HOT_PINK"; echo ""
    write_centered "${GOLD}\"In the shadows, we code...\"${RESET}" "$GOLD"; echo ""
    write_centered "${NEON_GREEN}✓ Secret Unlocked${RESET}" "$NEON_GREEN"; echo ""
    show_cursor; _save_secret "2829"
}

phantom-secrets() {
    load_config; get_theme_colors; clear_screen; echo ""
    write_centered "╔════════════════════════════════════════╗" "$PRIMARY"
    write_centered "║      ${GOLD}🔍 SECRET HUNTER 🔍${PRIMARY}          ║" "$PRIMARY"
    write_centered "╚════════════════════════════════════════╝" "$PRIMARY"
    echo ""
    _load_secrets
    local total=3 found=${#SECRETS_FOUND[@]}
    write_centered "Found: ${NEON_GREEN}$found${RESET} / ${GOLD}$total${RESET}" "$WHITE"; echo ""
    local p="phantom"; [[ "$THEME" == "Unknown" ]] && p="unknown"
    for s in "${SECRETS_FOUND[@]}"; do
        case "$s" in
            chosen)  write_centered "${NEON_GREEN}✓${RESET} ${p}-chosen  — The Chosen One" "$WHITE" ;;
            2829)    write_centered "${NEON_GREEN}✓${RESET} ${p}-2829    — Creator's Mark"  "$WHITE" ;;
            secrets) write_centered "${NEON_GREEN}✓${RESET} ${p}-secrets — Secret Hunter"   "$WHITE" ;;
        esac
    done
    echo ""
    [[ $found -ge $total ]] && \
        write_centered "${GOLD}⚡ ACHIEVEMENT UNLOCKED — Master Secret Hunter ⚡${RESET}" "$GOLD" || \
        write_centered "${DARK_GRAY}Hint: try ${p}-chosen, ${p}-2829${RESET}" "$DARK_GRAY"
    echo ""; _save_secret "secrets"
}

# Unknown theme aliases
unknown-help()    { phantom-help; }
unknown-reload()  { phantom-reload; }
unknown-theme()   { phantom-theme "$@"; }
unknown-matrix()  { phantom-matrix; }
unknown-dash()    { phantom-dash "$@"; }
unknown-top()     { phantom-top; }
unknown-live()    { phantom-live; }
unknown-update()  { phantom-update; }
unknown-stealth() { phantom-stealth "$@"; }
unknown-search()  { phantom-search "$@"; }
unknown-history() { phantom-search "$@"; }
unknown-config()  { phantom-config "$@"; }
unknown-changelog() { phantom-changelog "$@"; }
unknown-chosen()    { phantom-chosen; }
unknown-2829()      { phantom-2829; }
unknown-secrets()   { phantom-secrets; }

# ═══════════════════════════════════════════════════
# PROMPT WITH NON-BLOCKING GIT HUD
# ═══════════════════════════════════════════════════
set_phantom_prompt() {
    load_config; get_theme_colors

    _phantom_ps1() {
        local s=$?
        local path_d
        local user_d="${USER:-$(whoami 2>/dev/null || echo 'user')}"
        if [[ "$STEALTH_MODE" == "true" ]]; then
            if [[ "$THEME" == "Unknown" ]]; then
                path_d="~/unknown/darknet/grid"
                user_d="unknown"
            else
                path_d="~/phantom/core/grid"
                user_d="ghost"
            fi
        elif [[ "$SHOW_FULL_PATH" == "true" ]]; then
            path_d="$PWD"
        else
            path_d="${PWD##*/}"; [[ -z "$path_d" ]] && path_d="/"
        fi

        # Fast non-blocking git check (walking up parent directories without spawning git process)
        local git_b=""
        local cur_p="$PWD"
        while [[ -n "$cur_p" && "$cur_p" != "/" ]]; do
            if [[ -e "$cur_p/.git" ]]; then
                local head_f=""
                if [[ -d "$cur_p/.git" ]]; then
                    head_f="$cur_p/.git/HEAD"
                elif [[ -f "$cur_p/.git" ]]; then
                    local wt_line; read -r wt_line < "$cur_p/.git" 2>/dev/null || true
                    if [[ "$wt_line" == gitdir:* ]]; then
                        local wt_p="${wt_line#gitdir: }"
                        while [[ "$wt_p" == [[:space:]]* ]]; do wt_p="${wt_p#[[:space:]]}"; done
                        [[ "$wt_p" != /* ]] && wt_p="$cur_p/$wt_p"
                        head_f="$wt_p/HEAD"
                    fi
                fi
                if [[ -n "$head_f" && -f "$head_f" ]]; then
                    local ref; read -r ref < "$head_f" 2>/dev/null || true
                    if [[ "$ref" == ref:\ refs/heads/* ]]; then
                        local b_name="${ref#ref: refs/heads/}"
                        git_b=" ${DARK_GRAY}on ${HOT_PINK}${b_name}${RESET}"
                    elif [[ -n "$ref" ]]; then
                        git_b=" ${DARK_GRAY}on ${HOT_PINK}${ref:0:7}${RESET}"
                    fi
                fi
                break
            fi
            cur_p="${cur_p%/*}"
        done

        local sym; [[ $s -eq 0 ]] && sym="${NEON_GREEN}${SUCCESS}" || sym="${BLOOD_RED}${FAILURE}"
        PS1="${PRIMARY}${user_d}${DARK_GRAY}@${NEON_CYAN}${path_d}${git_b}${RESET}"$'\n'"${sym}  ${PRIMARY}${PROMPT}${RESET} "
    }

    if [[ -n "${ZSH_VERSION:-}" ]]; then
        setopt prompt_subst 2>/dev/null || true
        autoload -Uz add-zsh-hook 2>/dev/null || true
        if typeset -f add-zsh-hook >/dev/null 2>&1; then
            add-zsh-hook precmd _phantom_ps1
        else
            [[ " ${precmd_functions[*]:-} " != *" _phantom_ps1 "* ]] && precmd_functions+=(_phantom_ps1)
        fi
    else
        [[ "${PROMPT_COMMAND:-}" == *"_phantom_ps1"* ]] && return
        PROMPT_COMMAND="_phantom_ps1${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    fi
}

# ═══════════════════════════════════════════════════
# ENTRY POINT
# ═══════════════════════════════════════════════════
set_phantom_prompt
start_phantom_terminal
