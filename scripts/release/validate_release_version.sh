#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <tag>"
  exit 1
fi

tag="$1"
project_file="${PROJECT_FILE:-Spaceman.xcodeproj/project.pbxproj}"
changelog_file="${CHANGELOG_FILE:-CHANGELOG.md}"

if [[ ! "$tag" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  echo "Error: tag '$tag' must match semantic version format vMAJOR.MINOR.PATCH"
  exit 1
fi

version="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"

marketing_versions="$(
  grep -Eo 'MARKETING_VERSION = [^;]+' "$project_file" \
    | awk '{print $3}' \
    | sort -u
)"
current_versions="$(
  grep -Eo 'CURRENT_PROJECT_VERSION = [^;]+' "$project_file" \
    | awk '{print $3}' \
    | sort -u
)"

if [[ -z "$marketing_versions" ]]; then
  echo "Error: MARKETING_VERSION was not found in $project_file"
  exit 1
fi

if [[ -z "$current_versions" ]]; then
  echo "Error: CURRENT_PROJECT_VERSION was not found in $project_file"
  exit 1
fi

marketing_count="$(printf '%s\n' "$marketing_versions" | wc -l | tr -d ' ')"
current_count="$(printf '%s\n' "$current_versions" | wc -l | tr -d ' ')"

if [[ "$marketing_count" != "1" ]]; then
  echo "Error: expected exactly one MARKETING_VERSION value, found: $marketing_versions"
  exit 1
fi

if [[ "$current_count" != "1" ]]; then
  echo "Error: expected exactly one CURRENT_PROJECT_VERSION value, found: $current_versions"
  exit 1
fi

marketing_version="$(printf '%s\n' "$marketing_versions" | head -n 1)"
current_version="$(printf '%s\n' "$current_versions" | head -n 1)"

if [[ "$marketing_version" != "$version" ]]; then
  echo "Error: MARKETING_VERSION ($marketing_version) does not match tag version ($version)"
  exit 1
fi

if [[ "$current_version" != "$version" ]]; then
  echo "Error: CURRENT_PROJECT_VERSION ($current_version) does not match tag version ($version)"
  exit 1
fi

if ! grep -Eq "^## \\[$version\\](\\s*-\\s*.*)?$" "$changelog_file"; then
  echo "Error: CHANGELOG is missing heading for version $version"
  exit 1
fi

echo "$version"
