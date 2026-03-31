#!/usr/bin/env bash
# PreCompact hook: increments a per-session compact counter

set -euo pipefail

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

if [[ -z "$SESSION_ID" ]]; then
  exit 0
fi

DIR="$HOME/.claude/compact"
mkdir -p "$DIR"

FILE="$DIR/$SESSION_ID"
COUNT=0
if [[ -f "$FILE" ]]; then
  COUNT=$(cat "$FILE")
fi
COUNT=$((COUNT + 1))
echo "$COUNT" > "$FILE"
