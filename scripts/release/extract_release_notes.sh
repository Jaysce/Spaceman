#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <version> <output-file>"
  exit 1
fi

version="$1"
output_file="$2"
changelog_file="${CHANGELOG_FILE:-CHANGELOG.md}"

if [[ ! -f "$changelog_file" ]]; then
  echo "Error: changelog file '$changelog_file' was not found"
  exit 1
fi

set +e
section="$(
  awk -v version="$version" '
    BEGIN { in_section = 0; found = 0 }
    $0 ~ "^## \\[" version "\\]" {
      in_section = 1
      found = 1
      next
    }
    in_section && $0 ~ "^## \\[" { exit }
    in_section { print }
    END {
      if (!found) {
        exit 2
      }
    }
  ' "$changelog_file"
)"
status=$?
set -e

if [[ $status -eq 2 ]]; then
  echo "Error: changelog entry for version '$version' was not found"
  exit 1
fi

if [[ $status -ne 0 ]]; then
  echo "Error: failed to parse changelog"
  exit 1
fi

section="$(printf '%s\n' "$section" | sed -e '/./,$!d')"
if [[ -z "$section" ]]; then
  echo "Error: changelog section for '$version' is empty"
  exit 1
fi

mkdir -p "$(dirname "$output_file")"
{
  printf 'Spaceman %s\n\n' "$version"
  printf '%s\n' "$section"
} > "$output_file"

echo "$output_file"
