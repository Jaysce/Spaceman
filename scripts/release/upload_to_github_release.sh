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

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: GitHub CLI (gh) is required"
  exit 1
fi

release_tag="${RELEASE_TAG:-}"
release_version="${RELEASE_VERSION:-}"
release_title="${RELEASE_TITLE:-}"
repo="${GITHUB_REPOSITORY:-}"

if [[ -z "$release_tag" ]]; then
  echo "Error: RELEASE_TAG is required"
  exit 1
fi

if [[ -z "$release_version" ]]; then
  echo "Error: RELEASE_VERSION is required"
  exit 1
fi

if [[ -z "$release_title" ]]; then
  echo "Error: RELEASE_TITLE is required"
  exit 1
fi

if [[ -z "$repo" ]]; then
  echo "Error: GITHUB_REPOSITORY is required"
  exit 1
fi

notes_file="$artifacts_dir/Spaceman-$release_version.txt"
dmg_file="$artifacts_dir/Spaceman-$release_version.dmg"
appcast_file="$artifacts_dir/appcast.xml"

if [[ ! -f "$notes_file" ]]; then
  echo "Error: release notes file '$notes_file' was not found"
  exit 1
fi

if [[ ! -f "$dmg_file" ]]; then
  echo "Error: DMG file '$dmg_file' was not found"
  exit 1
fi

if [[ ! -f "$appcast_file" ]]; then
  echo "Error: appcast file '$appcast_file' was not found"
  exit 1
fi

if gh release view "$release_tag" --repo "$repo" >/dev/null 2>&1; then
  gh release edit "$release_tag" \
    --repo "$repo" \
    --title "$release_title" \
    --notes-file "$notes_file"
else
  gh release create "$release_tag" \
    --repo "$repo" \
    --title "$release_title" \
    --notes-file "$notes_file"
fi

assets=(
  "$dmg_file"
  "$notes_file"
  "$appcast_file"
)

shopt -s nullglob
delta_files=( "$artifacts_dir"/*.delta )
shopt -u nullglob

if (( ${#delta_files[@]} > 0 )); then
  assets+=( "${delta_files[@]}" )
fi

gh release upload "$release_tag" "${assets[@]}" --repo "$repo" --clobber

echo "https://github.com/${repo}/releases/tag/${release_tag}"
