#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <artifacts-directory>"
  exit 1
fi

artifacts_dir="$1"

if [[ ! -d "$artifacts_dir" ]]; then
  echo "Error: artifacts directory '$artifacts_dir' was not found"
  exit 1
fi

if [[ -z "${SPARKLE_PUBLIC_BASE_URL:-}" ]]; then
  echo "Error: SPARKLE_PUBLIC_BASE_URL is required"
  exit 1
fi

if [[ -z "${SPARKLE_PRIVATE_ED_KEY:-}" ]]; then
  echo "Error: SPARKLE_PRIVATE_ED_KEY is required"
  exit 1
fi

generate_appcast_bin="${GENERATE_APPCAST_BIN:-}"
if [[ -z "$generate_appcast_bin" ]]; then
  generate_appcast_bin="$(./scripts/release/build_sparkle_tool.sh generate_appcast)"
fi

if [[ ! -x "$generate_appcast_bin" ]]; then
  echo "Error: generate_appcast binary '$generate_appcast_bin' is not executable"
  exit 1
fi

max_versions="${SPARKLE_MAX_VERSIONS:-3}"

printf '%s' "$SPARKLE_PRIVATE_ED_KEY" | "$generate_appcast_bin" \
  --ed-key-file - \
  --download-url-prefix "$SPARKLE_PUBLIC_BASE_URL" \
  --release-notes-url-prefix "$SPARKLE_PUBLIC_BASE_URL" \
  --maximum-versions "$max_versions" \
  "$artifacts_dir"

if [[ ! -f "$artifacts_dir/appcast.xml" ]]; then
  echo "Error: appcast.xml was not generated in '$artifacts_dir'"
  exit 1
fi

echo "$artifacts_dir/appcast.xml"
