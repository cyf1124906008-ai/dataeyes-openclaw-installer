#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="${1:-dataeyes-openclaw-installer}"
VISIBILITY="${VISIBILITY:-public}"

ROOT="$(cd "$(dirname "$0")" && pwd)"

gh auth status >/dev/null

if gh repo view "$REPO_NAME" >/dev/null 2>&1; then
  echo "Repo already exists: $REPO_NAME"
else
  gh repo create "$REPO_NAME" --"$VISIBILITY" --source "$ROOT" --remote origin
fi

if git -C "$ROOT" remote get-url origin >/dev/null 2>&1; then
  git -C "$ROOT" push -u origin main
else
  echo "Remote origin is not configured."
  exit 1
fi
