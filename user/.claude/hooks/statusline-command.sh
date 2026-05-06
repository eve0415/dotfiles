#!/usr/bin/env bash
# Enhanced Claude Code statusline: 3-line display with context, cost, compact count
# Inspired by loadbalance-sudachi-kun/claude-code-statusline

set -euo pipefail

INPUT=$(cat)

# --- Parse stdin JSON ---
parse_json() {
  echo "$INPUT" | jq -r "$1 // empty" 2>/dev/null || true
}

CWD=$(parse_json '.cwd')
MODEL=$(parse_json '.model.display_name')
CTX_PCT=$(parse_json '.context_window.used_percentage')
CTX_SIZE=$(parse_json '.context_window.context_window_size')
SESSION_ID=$(parse_json '.session_id')
TOTAL_COST=$(parse_json '.cost.total_cost_usd')
RATE_5H=$(parse_json '.rate_limits.five_hour.used_percentage')
RATE_5H_RESET=$(parse_json '.rate_limits.five_hour.resets_at')
RATE_7D=$(parse_json '.rate_limits.seven_day.used_percentage')
RATE_7D_RESET=$(parse_json '.rate_limits.seven_day.resets_at')

# --- True-color ANSI palette ---
C_GREEN='\033[38;2;151;201;195m'
C_YELLOW='\033[38;2;229;192;123m'
C_RED='\033[38;2;224;108;117m'
C_GRAY='\033[38;2;74;88;92m'
C_MAGENTA='\033[38;2;198;120;221m'
C_BLUE='\033[38;2;97;175;239m'
C_WHITE='\033[38;2;220;223;228m'
C_DIM='\033[38;2;128;138;145m'
RESET='\033[0m'
BOLD='\033[1m'

# --- Color by percentage ---
color_by_pct() {
  local pct="${1:-0}"
  pct="${pct%.*}"
  if [[ -z "$pct" ]] || [[ "$pct" -lt 50 ]]; then
    echo "$C_GREEN"
  elif [[ "$pct" -lt 80 ]]; then
    echo "$C_YELLOW"
  else
    echo "$C_RED"
  fi
}

# --- Progress bar (10 segments) ---
progress_bar() {
  local pct="${1:-0}"
  pct="${pct%.*}"
  [[ -z "$pct" ]] && pct=0
  local filled=$(( pct / 10 ))
  local empty=$(( 10 - filled ))
  local color
  color=$(color_by_pct "$pct")
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="▰"; done
  local dim_part=""
  for ((i=0; i<empty; i++)); do dim_part+="▱"; done
  echo "${color}${bar}${C_GRAY}${dim_part}${RESET}"
}

# --- Format tokens (K/M notation) ---
format_tokens() {
  local n="${1:-0}"
  [[ -z "$n" ]] && { echo "?"; return; }
  if [[ "$n" -ge 1000000 ]]; then
    echo "$(awk "BEGIN{printf \"%.1f\", $n/1000000}")M"
  elif [[ "$n" -ge 1000 ]]; then
    echo "$(( n / 1000 ))K"
  else
    echo "$n"
  fi
}

# --- Time until reset ---
time_until() {
  local reset_ts="${1:-}"
  [[ -z "$reset_ts" ]] && return
  local now
  now=$(date +%s)
  local diff=$(( reset_ts - now ))
  [[ "$diff" -le 0 ]] && { echo "now"; return; }
  local hours=$(( diff / 3600 ))
  local mins=$(( (diff % 3600) / 60 ))
  if [[ "$hours" -gt 0 ]]; then
    echo "${hours}h${mins}m"
  else
    echo "${mins}m"
  fi
}

# --- Git branch ---
GIT_BRANCH=""
if [[ -n "$CWD" ]]; then
  BRANCH=$(git -C "$CWD" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  if [[ -n "$BRANCH" ]]; then
    GIT_BRANCH="$BRANCH"
  fi
fi

# --- Compact count ---
COMPACT_COUNT=""
if [[ -n "$SESSION_ID" ]]; then
  FILE="/home/node/.claude/statusline/compact/$SESSION_ID"
  if [[ -f "$FILE" ]]; then
    COMPACT_COUNT=$(cat "$FILE" 2>/dev/null || echo "")
  fi
fi

# --- Build separator ---
SEP="${C_GRAY} │ ${RESET}"

# =====================
# LINE 1: Model | ctx% | branch | compact:N
# =====================
LINE1=""

if [[ -n "$MODEL" ]]; then
  LINE1+="${C_WHITE}🤖 ${BOLD}${MODEL}${RESET}"
fi

if [[ -n "$CTX_PCT" ]]; then
  _color=$(color_by_pct "${CTX_PCT%.*}")
  [[ -n "$LINE1" ]] && LINE1+="$SEP"
  LINE1+="${_color}📊 ${CTX_PCT}%${RESET}"
fi

if [[ -n "$GIT_BRANCH" ]]; then
  [[ -n "$LINE1" ]] && LINE1+="$SEP"
  LINE1+="${C_BLUE}🔀 ${GIT_BRANCH}${RESET}"
fi

_compact_display="${COMPACT_COUNT:-0}"
[[ -n "$LINE1" ]] && LINE1+="$SEP"
LINE1+="${C_MAGENTA}🗜  compact:${_compact_display}${RESET}"

# =====================
# LINE 2: Context window progress bar
# =====================
LINE2=""
if [[ -n "$CTX_PCT" ]]; then
  _pct="${CTX_PCT%.*}"
  _bar=$(progress_bar "$_pct")
  _used=0
  if [[ -n "$CTX_SIZE" ]] && [[ -n "$CTX_PCT" ]]; then
    _used=$(awk "BEGIN{printf \"%d\", $CTX_SIZE * $CTX_PCT / 100}" 2>/dev/null || echo 0)
  fi
  _used_fmt=$(format_tokens "${_used:-0}")
  _total_fmt=$(format_tokens "${CTX_SIZE:-0}")
  _color=$(color_by_pct "$_pct")
  LINE2+="${C_DIM}📐 CTX${RESET}  ${_bar}  ${_color}${_pct}%${RESET}  ${C_DIM}${_used_fmt} / ${_total_fmt} tokens${RESET}"
fi

# =====================
# LINE 3: 5h | 7d | cost
# =====================
LINE3=""

if [[ -n "$RATE_5H" ]]; then
  _5h_pct="${RATE_5H%.*}"
  _5h_color=$(color_by_pct "$_5h_pct")
  _5h_reset=$(time_until "$RATE_5H_RESET")
  LINE3+="${_5h_color}⏱ 5h ${_5h_pct}%${RESET}"
  [[ -n "$_5h_reset" ]] && LINE3+="${C_DIM} (${_5h_reset})${RESET}"
fi

if [[ -n "$RATE_7D" ]]; then
  _7d_pct="${RATE_7D%.*}"
  _7d_color=$(color_by_pct "$_7d_pct")
  _7d_reset=$(time_until "$RATE_7D_RESET")
  [[ -n "$LINE3" ]] && LINE3+="$SEP"
  LINE3+="${_7d_color}⏱ 7d ${_7d_pct}%${RESET}"
  [[ -n "$_7d_reset" ]] && LINE3+="${C_DIM} (${_7d_reset})${RESET}"
fi

if [[ -n "$TOTAL_COST" ]] && [[ "$TOTAL_COST" != "0" ]]; then
  [[ -n "$LINE3" ]] && LINE3+="$SEP"
  LINE3+="${C_GREEN}💰 \$${TOTAL_COST}${RESET}"
else
  [[ -n "$LINE3" ]] && LINE3+="$SEP"
  LINE3+="${C_DIM}💰 --${RESET}"
fi

# --- Output ---
echo -e "$LINE1"
echo -e "$LINE2"
echo -e "$LINE3"
