#!/bin/bash
set -euo pipefail
PAYLOAD=$(cat)
EVENT=$(echo "$PAYLOAD" | jq -r '.hook_event_name // "unknown"' 2>/dev/null || echo "unknown")

case "$EVENT" in
  Stop)
    MSG="Task completed"
    ;;
  Notification)
    TYPE=$(echo "$PAYLOAD" | jq -r '.type // ""' 2>/dev/null || echo "")
    case "$TYPE" in
      *) MSG="Waiting for input" ;;
    esac
    ;;
  *)
    MSG="Claude Code"
    ;;
esac

# Set user var with context, then send bell
# WezTerm Lua reads the user var for the message, bell triggers the handler
printf '\e]1337;SetUserVar=%s=%s\a' "claude_status" "$(echo -n "$MSG" | base64)" > /dev/tty 2>/dev/null || true
printf '\a' > /dev/tty 2>/dev/null || true
