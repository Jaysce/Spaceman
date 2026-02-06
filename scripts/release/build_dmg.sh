#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <version> <output-directory>"
  exit 1
fi

version="$1"
output_dir="$2"

project_path="${PROJECT_PATH:-Spaceman.xcodeproj}"
scheme_name="${SCHEME_NAME:-Spaceman}"
app_name="${APP_NAME:-Spaceman}"
allow_unsigned="${ALLOW_UNSIGNED_ARCHIVE:-0}"
release_code_sign_identity="${RELEASE_CODE_SIGN_IDENTITY:-Developer ID Application}"
release_other_code_sign_flags="${RELEASE_OTHER_CODE_SIGN_FLAGS:-}"
release_code_sign_style="${RELEASE_CODE_SIGN_STYLE:-Manual}"
release_development_team="${RELEASE_DEVELOPMENT_TEAM:-}"

mkdir -p "$output_dir"
archive_path="$output_dir/${app_name}.xcarchive"
app_path="$archive_path/Products/Applications/${app_name}.app"
dmg_path="$output_dir/${app_name}-${version}.dmg"

build_args=(
  -project "$project_path"
  -scheme "$scheme_name"
  -configuration Release
  -archivePath "$archive_path"
  clean
  archive
)

if [[ "$allow_unsigned" == "1" ]]; then
  build_args+=(
    CODE_SIGNING_ALLOWED=NO
    CODE_SIGNING_REQUIRED=NO
  )
else
  build_args+=("CODE_SIGN_STYLE=$release_code_sign_style")
  if [[ "$release_code_sign_style" == "Manual" ]]; then
    if [[ -z "$release_development_team" ]]; then
      echo "Error: RELEASE_DEVELOPMENT_TEAM is required when RELEASE_CODE_SIGN_STYLE=Manual"
      exit 1
    fi
    build_args+=("DEVELOPMENT_TEAM=$release_development_team")
  fi

  build_args+=("CODE_SIGN_IDENTITY=$release_code_sign_identity")

  if [[ -n "$release_other_code_sign_flags" ]]; then
    build_args+=("OTHER_CODE_SIGN_FLAGS=$release_other_code_sign_flags")
  fi
fi

xcodebuild "${build_args[@]}"

if [[ ! -d "$app_path" ]]; then
  echo "Error: archived app was not found at '$app_path'"
  exit 1
fi

rm -f "$dmg_path"
hdiutil create \
  -volname "$app_name" \
  -srcfolder "$app_path" \
  -ov \
  -format UDZO \
  "$dmg_path" >/dev/null

if [[ -n "${DMG_SIGN_IDENTITY:-}" ]]; then
  codesign --force --timestamp --sign "${DMG_SIGN_IDENTITY}" "$dmg_path"
fi

echo "$dmg_path"
