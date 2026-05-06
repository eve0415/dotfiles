#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

case "$TOOL_NAME" in
  WebFetch|WebSearch) ;;
  *) exit 0 ;;
esac

if [[ "$TOOL_NAME" == "WebFetch" ]]; then
  URL=$(echo "$INPUT" | jq -r '.tool_input.url // ""')
  HOST=$(echo "$URL" | sed -E 's|^https?://||; s|^[^@]*@||; s|[:/].*||' | tr '[:upper:]' '[:lower:]')

  case "$HOST" in
    github.com|api.github.com|raw.githubusercontent.com|gist.githubusercontent.com)
      echo "Use \`gh\` CLI instead of WebFetch for GitHub resources. For API calls use \`gh api\`, for repo content use \`gh api repos/{owner}/{repo}/contents/{path}\`, for issues/PRs use \`gh issue\`/\`gh pr\`." >&2
      exit 2
      ;;
  esac
fi

if [[ "$TOOL_NAME" == "WebSearch" ]]; then
  QUERY=$(echo "$INPUT" | jq -r '.tool_input.query // ""' | tr '[:upper:]' '[:lower:]')

  if [[ "$QUERY" == *"github.com"* ]]; then
    echo "Use \`gh search\` CLI instead of WebSearch for GitHub. Available: \`gh search repos\`, \`gh search issues\`, \`gh search prs\`, \`gh search code\`." >&2
    exit 2
  fi
fi

exit 0
