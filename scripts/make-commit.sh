#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMMIT_TEXT_FILE="$REPO_ROOT/commit-text-proposal.txt"

if [[ ! -f "$COMMIT_TEXT_FILE" ]]; then
  echo "Error: $COMMIT_TEXT_FILE not found." >&2
  exit 1
fi

COMMIT_MSG="$(cat "$COMMIT_TEXT_FILE")"

if [[ -z "$COMMIT_MSG" ]]; then
  echo "Error: $COMMIT_TEXT_FILE is empty." >&2
  exit 1
fi

cd "$REPO_ROOT"
git add -A
git commit -m "$COMMIT_MSG"
git push
