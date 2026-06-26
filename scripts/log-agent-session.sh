#!/bin/bash

# Usage: log-agent-session.sh <hook_type>
# Reads JSON from stdin, appends a markdown entry to the session log.

HOOK_TYPE="${1:-unknown}"
LOG_FILE="tmp/agent-session-logs/agent-session-logs.txt"
DATETIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p "$(dirname "$LOG_FILE")"

input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

{
  echo ""
  echo "# ${HOOK_TYPE}-${DATETIME}"
  echo ""
} >> "$LOG_FILE"

case "$HOOK_TYPE" in
  sessionStart)
    source=$(echo "$input" | jq -r '.source // "unknown"')
    cwd=$(echo "$input" | jq -r '.cwd // "unknown"')
    {
      echo "- **Source**: $source"
      echo "- **Working directory**: \`$cwd\`"
    } >> "$LOG_FILE"
    ;;
  sessionEnd)
    : # no extra fields
    ;;
  userPromptSubmitted)
    prompt=$(echo "$input" | jq -r '.prompt // empty')
    {
      echo "**Prompt**:"
      echo ""
      echo "$prompt" | sed 's/^/> /'
    } >> "$LOG_FILE"
    ;;
  agentStop)
    # Try to extract last assistant turn from transcript
    if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
      last_response=$(python3 - "$transcript_path" <<'PYEOF'
import sys, json

path = sys.argv[1]
with open(path) as f:
    lines = [json.loads(l) for l in f if l.strip()]

# Find index of last user.message
last_user_idx = -1
for i, obj in enumerate(lines):
    if obj.get("type") == "user.message":
        last_user_idx = i

# Collect all assistant.message content after that
parts = []
for obj in lines[last_user_idx + 1:]:
    if obj.get("type") == "assistant.message":
        content = obj.get("data", {}).get("content", "")
        if content:
            parts.append(content)

print("".join(parts))
PYEOF
)
      if [ -n "$last_response" ]; then
        {
          echo "**Response**:"
          echo ""
          echo "$last_response"
        } >> "$LOG_FILE"
      fi
    fi
    ;;
  subagentStop)
    agent_type=$(echo "$input" | jq -r '.agent_type // "unknown"')
    echo "- **Agent type**: $agent_type" >> "$LOG_FILE"
    ;;
  errorOccurred)
    error=$(echo "$input" | jq -r '.error // .message // "unknown"')
    echo "- **Error**: $error" >> "$LOG_FILE"
    ;;
  *)
    echo "$input" | jq -r '.' 2>/dev/null >> "$LOG_FILE" || echo "$input" >> "$LOG_FILE"
    ;;
esac

echo "" >> "$LOG_FILE"
