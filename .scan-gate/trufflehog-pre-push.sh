#!/usr/bin/env bash
set -euo pipefail

if ! command -v trufflehog >/dev/null 2>&1; then
  echo "trufflehog is required but was not found in PATH." >&2
  echo "Install it from https://docs.trufflesecurity.com/pre-commit-hooks and retry." >&2
  exit 127
fi

zero_ref="0000000000000000000000000000000000000000"
from_ref="${PRE_COMMIT_FROM_REF:-}"

if [ -n "$from_ref" ] && [ "$from_ref" != "$zero_ref" ] && git cat-file -e "$from_ref^{commit}" 2>/dev/null; then
  base_ref="$from_ref"
else
  base_ref="$(git rev-list --max-parents=0 HEAD | tail -n 1)"
fi

echo "Running TruffleHog git scan since ${base_ref}..."

trufflehog git file://. \
  --config .trufflehog.yaml \
  --since-commit "$base_ref" \
  --results=verified,unknown,unverified \
  --fail \
  --no-update
