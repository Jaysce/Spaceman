# Releasing Spaceman

Use these steps for a normal release.

## Release steps

1. Choose a semantic version `X.Y.Z`.
2. Update `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in Xcode to `X.Y.Z`.
3. Update `CHANGELOG.md` with a new section for this version.
4. Merge to `main`.
5. Tag that `main` commit as `vX.Y.Z` and push the tag.
6. The Release workflow will build, sign, generate appcast entries, and publish assets to GitHub Releases.

### Example changelog edit

```md
## [1.1.0] - 2026-02-06

### Added
- Added automatic update publishing to GitHub Releases.

### Changed
- Updated Sparkle integration and release automation scripts.
```

The heading version must match the app version and tag:
- `MARKETING_VERSION = 1.1.0`
- `CURRENT_PROJECT_VERSION = 1.1.0`
- Git tag: `v1.1.0`
