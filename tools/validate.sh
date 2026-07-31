#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(git -C "$SCRIPT_DIR/.." rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR: Could not locate the Git repository."
  exit 1
}

cd "$REPO"

echo
echo "=== Portfolio Validation ==="

files=(
  index.html
  styles.css
  script.js
  README.md
  vaultwarden-recovery.html
)

existing_files=()

for file in "${files[@]}"; do
  if [[ -f "$file" ]]; then
    existing_files+=("$file")
  else
    echo "WARNING: Missing file: $file"
  fi
done

echo
echo "Checking merge-conflict markers..."

if grep -nE '^(<<<<<<<|=======|>>>>>>>)' "${existing_files[@]}"; then
  echo
  echo "ERROR: Merge-conflict markers found."
  exit 1
else
  status=$?

  if [[ $status -eq 1 ]]; then
    echo "OK: No merge-conflict markers."
  else
    echo "ERROR: grep failed with status $status."
    exit "$status"
  fi
fi

echo
echo "Checking whitespace..."

if git diff --check; then
  echo "OK: No whitespace errors."
else
  echo
  echo "ERROR: Whitespace problems found."
  exit 1
fi

echo
echo "Checking JavaScript syntax..."

if command -v node >/dev/null 2>&1 && [[ -f script.js ]]; then
  if node --check script.js; then
    echo "OK: JavaScript syntax is valid."
  else
    echo "ERROR: JavaScript syntax check failed."
    exit 1
  fi
else
  echo "SKIPPED: Node.js or script.js unavailable."
fi

echo
echo "Git status:"
git status --short

echo
echo "Diff summary:"
git diff --stat

echo
echo "Validation completed successfully."
