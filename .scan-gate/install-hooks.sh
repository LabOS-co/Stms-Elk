#!/usr/bin/env bash
set -euo pipefail

missing=0

if ! command -v pre-commit >/dev/null 2>&1; then
  echo "pre-commit is not installed." >&2
  echo "Install with: pip install pre-commit" >&2
  missing=1
fi

if ! command -v trufflehog >/dev/null 2>&1; then
  echo "trufflehog is not installed." >&2
  echo "Install with:" >&2
  echo "curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin" >&2
  missing=1
fi

if [ "$missing" -ne 0 ]; then
  exit 127
fi

pre-commit install --hook-type pre-commit --hook-type pre-push
pre-commit install-hooks

echo "Scan gate installed for pre-commit and pre-push."
