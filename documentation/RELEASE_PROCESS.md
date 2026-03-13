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

- Pre-push hook validates code quality
- CI workflow runs on GitHub
- Changes are live in DEV environment
- **No version bump yet**

### 2. Create Release (PROD)

When ready to release to production:

1. **Go to GitHub Actions**
   - Visit: https://github.com/personal-abebediye/sudoku/actions/workflows/version-bump.yml
   
2. **Click "Run workflow"**
   - Select branch: `main`
   - Choose bump type: `auto` (recommended) or `major`/`minor`/`patch`
   - Click "Run workflow"

3. **The workflow automatically:**
   - Analyzes commits since last release (if `auto` selected)
   - Bumps version in `pubspec.yaml` based on conventional commits
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

**Manual override:** Choose `major`, `minor`, or `patch` to force a specific bump type.

## Environments

### DEV Environment
- **Source:** Latest `main` branch
- **Trigger:** Every push to main (after pre-push hook passes)
- **Purpose:** Testing, validation, preview
- **CI:** Runs tests, formatting, analysis
- **Version:** Uses current pubspec.yaml version (may be behind latest release)

### PROD Environment  
- **Source:** Release tags only (`v*`)
- **Trigger:** Manual workflow dispatch
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
git push origin main  # DEV deployment

git commit -m "test: add generator tests"
git push origin main  # DEV deployment

git commit -m "fix: generator edge case"
git push origin main  # DEV deployment

# Ready to release? Go to GitHub Actions and run "Version Bump and Release" workflow
# → Workflow analyzes commits (feat + fix)
# → Bumps version: 0.3.1 → 0.4.0 (feat = minor)
# → Creates v0.4.0 tag and GitHub Release
```

## Emergency Rollback

If a release has critical issues:

```bash
# Revert to previous release
git checkout v1.0.0

# Or create hotfix and release via workflow
git commit -m "fix!: critical security issue"
git push origin main
# Then manually run release workflow with bump_type: patch
```

## Using GitHub CLI

You can also trigger the release workflow from command line:

```bash
# Trigger release with auto version bump
gh workflow run version-bump.yml

# Or with specific bump type
gh workflow run version-bump.yml -f bump_type=minor
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
- https://github.com/personal-abebediye/sudoku/actions

## Migration from Old Setup

**Previous behavior:**
- Every push to main triggered version bump
- Many unnecessary version bumps for chore commits

**New behavior:**
- Push to main → DEV deployment only (no version bump)
- Manual workflow trigger → PROD deployment with version bump
- Cleaner version history
- More control over releases

## Quick Reference

```bash
# Daily development (DEV)
git commit -m "feat: ..." && git push origin main

# Create release (PROD) - via GitHub Web UI
# 1. Go to: https://github.com/personal-abebediye/sudoku/actions/workflows/version-bump.yml
# 2. Click "Run workflow"
# 3. Select bump type (usually "auto")
# 4. Click "Run workflow"

# Or via CLI
gh workflow run version-bump.yml
```

