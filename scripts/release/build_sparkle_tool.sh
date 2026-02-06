#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <tool-name> [derived-data-path]"
  exit 1
fi

tool_name="$1"
derived_data_path="${2:-$PWD/.build/sparkle-tools}"
project_path="${PROJECT_PATH:-Spaceman.xcodeproj}"

xcodebuild -project "$project_path" -resolvePackageDependencies >/dev/null

project_name="$(basename "$project_path" .xcodeproj)"
sparkle_project="$(
  find "$HOME/Library/Developer/Xcode/DerivedData" \
    -path "*/${project_name}-*/SourcePackages/checkouts/Sparkle/Sparkle.xcodeproj" \
    -print \
    | head -n 1
)"

if [[ -z "$sparkle_project" ]]; then
  sparkle_project="$(
    find "$HOME/Library/Developer/Xcode/DerivedData" \
      -path "*/SourcePackages/checkouts/Sparkle/Sparkle.xcodeproj" \
      -print \
      | head -n 1
  )"
fi

if [[ -z "$sparkle_project" ]]; then
  echo "Error: could not locate Sparkle.xcodeproj in DerivedData"
  exit 1
fi

xcodebuild \
  -project "$sparkle_project" \
  -scheme "$tool_name" \
  -configuration Release \
  -derivedDataPath "$derived_data_path" \
  build >/dev/null

tool_path="$derived_data_path/Build/Products/Release/$tool_name"
if [[ ! -x "$tool_path" ]]; then
  echo "Error: expected Sparkle tool at '$tool_path'"
  exit 1
fi

echo "$tool_path"
