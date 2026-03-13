# Release Process

This document describes how to create releases for the Sudoku project.

## Philosophy

- **Main branch is always deployable** but not always released
- **Releases are manual** - triggered via GitHub Actions when ready
- **DEV environment** runs from latest main branch
- **PROD environment** runs from tagged releases only

## Release Workflow

### 1. Develop on Main (DEV)

```bash
# Make changes following TDD
git add .
git commit -m "feat: add new feature"
git push origin main  # Pre-push hook runs automatically
```

- Pre-push hook validates code quality (format, analyze, test, YAML)
- CI workflow runs on GitHub (tests and analysis only)
- Changes are live in DEV environment
- **No version bump or release yet**

### 2. Create Release (PROD)

When ready to release to production:

1. **Ensure CI is passing**
   - Check: https://github.com/personal-abebediye/sudoku/actions
   - Wait for latest CI run to complete successfully ✅

2. **Manually trigger release workflow**
   - Go to: https://github.com/personal-abebediye/sudoku/actions/workflows/release.yml
   - Click "Run workflow" button
   - Select branch: `main`
   - Choose bump type:
     - `auto` (recommended) - Analyzes commits automatically
     - `major` - Force major version bump (breaking changes)
     - `minor` - Force minor version bump (new features)
     - `patch` - Force patch version bump (bug fixes)
   - Click "Run workflow" ▶️

3. **The workflow automatically:**
   - Analyzes commits since last release (if `auto` selected)
   - Bumps version in `pubspec.yaml`
   - Updates `CHANGELOG.md`
   - Creates version tag (e.g., `v1.0.0`)
   - Creates GitHub Release
   - Pushes changes to main

### 3. Version Bumping Rules (when using `auto`)

The workflow analyzes commits since the last release tag:

| Commit Type | Version Bump | Example |
|-------------|--------------|---------|
| `feat!:` or `BREAKING CHANGE:` | **Major** | 1.0.0 → 2.0.0 |
| `feat:` | **Minor** | 1.0.0 → 1.1.0 |
| `fix:` or `perf:` | **Patch** | 1.0.0 → 1.0.1 |
| `docs:`, `chore:`, `test:`, `style:` | None | No bump |

**Manual override:** Choose `major`, `minor`, or `patch` to force a specific bump type regardless of commits.

## Environments

### DEV Environment
- **Source:** Latest `main` branch
- **Trigger:** Every push to main (after pre-push hook passes)
- **Purpose:** Testing, validation, preview
- **CI:** Runs tests, formatting, analysis
- **Version:** Uses current pubspec.yaml version (may be behind latest release)

### PROD Environment
- **Source:** Release tags only (`v*`)
- **Trigger:** Manual workflow dispatch (click button)
- **Purpose:** End-user facing production
- **CD:** Version bump, changelog, GitHub release
- **Version:** Automatically bumped based on commits

## Release Cadence

### For MVP Development (Current Phase)
- Release **when features are complete and stable**
- Typical: 1-2 releases per week
- Use for milestones or significant features

### For Production (Post-Launch)
- **Hotfixes:** As needed (patch releases)
- **Features:** Weekly or bi-weekly (minor releases)
- **Breaking changes:** With communication plan (major releases)

## Example Workflow

```bash
# Week 1: Implement features
git commit -m "feat: add puzzle generator"
git push origin main  # DEV - CI runs

git commit -m "test: add generator tests"
git push origin main  # DEV - CI runs

git commit -m "fix: generator edge case"
git push origin main  # DEV - CI runs

# All tests passing? Ready to release!
# Go to GitHub Actions → Create Release workflow → Run workflow (auto)
# → Analyzes commits (feat + fix)
# → Bumps version: 0.3.1 → 0.4.0 (feat = minor)
# → Creates v0.4.0 tag and GitHub Release
```

## Using GitHub CLI

You can also trigger the release workflow from command line:

```bash
# Check if CI is passing first
gh run list --workflow=ci.yml --limit 1

# Trigger release with auto version bump
gh workflow run release.yml

# Or with specific bump type
gh workflow run release.yml -f bump_type=minor

# Watch the release workflow
gh run watch
```

## Checking Release Status

View releases:
```bash
# List all releases
gh release list

# View specific release
gh release view v1.0.0
```

View workflow runs:
- CI: https://github.com/personal-abebediye/sudoku/actions/workflows/ci.yml
- Release: https://github.com/personal-abebediye/sudoku/actions/workflows/release.yml

## Migration from Old Setup

**Previous behavior:**
- Every push to main triggered version bump automatically
- Many unnecessary version bumps for chore/docs commits

**New behavior:**
- Push to main → CI runs (tests only, no release)
- Manual click → Release workflow runs (version bump + release)
- Cleaner version history
- Full control over when releases happen

## Quick Reference

```bash
# Daily development (DEV)
git commit -m "feat: ..." && git push origin main

# Create release (PROD)
# 1. Ensure CI passed: https://github.com/personal-abebediye/sudoku/actions/workflows/ci.yml
# 2. Trigger release: https://github.com/personal-abebediye/sudoku/actions/workflows/release.yml
# 3. Click "Run workflow" button
```


