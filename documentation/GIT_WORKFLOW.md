# Git Workflow Guide

## Trunk-Based Development

This project uses **trunk-based development** - all work happens directly on the `main` branch. This is ideal for solo developers and eliminates branch management overhead.

## Daily Workflow

### 1. Start Working
```bash
# Pull latest changes (if working across devices)
git pull origin main

# Check current status
git status
```

### 2. Make Changes
Work on your features/fixes directly on `main`. Keep changes focused and commit frequently.

### 3. Commit Changes
Use conventional commit messages for automatic versioning:

```bash
# Stage your changes
git add .

# Or stage specific files
git add lib/features/game/

# Commit with conventional format
git commit -m "feat(game): add hint button to game board"
```

### 4. Push to GitHub
```bash
# Push to main (triggers automatic versioning)
git push origin main
```

## Conventional Commit Types

| Type | Version Bump | When to Use |
|------|--------------|-------------|
| `feat` | MINOR (0.1.0 → 0.2.0) | New features |
| `fix` | PATCH (0.1.0 → 0.1.1) | Bug fixes |
| `perf` | PATCH (0.1.0 → 0.1.1) | Performance improvements |
| `docs` | None | Documentation only |
| `style` | None | Code formatting |
| `refactor` | None | Code restructuring |
| `test` | None | Adding/updating tests |
| `chore` | None | Dependencies, configs |
| `feat!` or `BREAKING CHANGE` | MAJOR (0.1.0 → 1.0.0) | Breaking changes |

## Example Workflow Session

```bash
# Session 1: Add hint system
git add lib/features/game/presentation/widgets/hint_button.dart
git commit -m "feat(game): add hint button widget"
git push origin main
# ✅ Version bumped to 0.2.0, changelog updated, tagged

# Session 2: Fix a bug
git add lib/features/solver/validation.dart
git commit -m "fix(solver): correct 3x3 box validation logic"
git push origin main
# ✅ Version bumped to 0.2.1

# Session 3: Update docs (no version change)
git add README.md
git commit -m "docs: add installation instructions"
git push origin main
# ✅ No version bump

# Session 4: Refactor code (no version change)
git add lib/features/game/domain/
git commit -m "refactor(game): extract board validation to separate class"
git push origin main
# ✅ No version bump
```

## Best Practices

### ✅ Do
- **Commit frequently** - Small, focused commits are better
- **Test before pushing** - Run `flutter test && flutter analyze`
- **Keep main stable** - Only push working code
- **Use descriptive scopes** - `feat(game)`, `fix(ui)`, `perf(solver)`
- **Write meaningful messages** - Explain *what* and *why*
- **Amend recent commits** - Use `git commit --amend` to fix mistakes before pushing

### ❌ Don't
- **Don't push broken code** - Always test locally first
- **Don't make huge commits** - Break work into logical pieces
- **Don't use vague messages** - Avoid "fix stuff" or "update code"
- **Don't forget the type** - Always use conventional format
- **Don't push untested changes** - Run tests first

## Useful Git Commands

### Checking Status
```bash
# See what's changed
git status

# See detailed diff
git diff

# See staged changes
git diff --cached
```

### Amending Commits
```bash
# Fix the last commit message
git commit --amend -m "feat(game): corrected message"

# Add forgotten files to last commit
git add forgotten_file.dart
git commit --amend --no-edit

# ⚠️ Only amend commits that haven't been pushed!
```

### Undoing Changes
```bash
# Discard changes in working directory
git checkout -- file.dart

# Unstage files
git reset HEAD file.dart

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes) ⚠️
git reset --hard HEAD~1
```

### Viewing History
```bash
# View commit history
git log --oneline

# View last 5 commits
git log --oneline -5

# View changes in a commit
git show <commit-hash>

# View file history
git log --follow -- path/to/file.dart
```

### Working Across Devices (with Cloud Sync)
```bash
# Before starting work
git pull origin main

# After committing locally
git push origin main

# If you forgot to pull first and have conflicts
git pull --rebase origin main
```

## Handling Mistakes

### Pushed wrong commit message
```bash
# If version bump already happened, just make a new commit
git commit --allow-empty -m "docs: fix typo in previous commit message"
```

### Need to revert a pushed commit
```bash
# Create a new commit that undoes changes
git revert <commit-hash>
git push origin main
```

### Accidentally pushed to main without testing
```bash
# Fix the issue quickly
# Make fixes
git add .
git commit -m "fix: resolve build error from previous commit"
git push origin main
```

## Pre-Push Checklist

Before every `git push origin main`:

- [ ] Code compiles: `flutter analyze`
- [ ] Tests pass: `flutter test`
- [ ] Commit message follows conventional format
- [ ] Changes are complete and working
- [ ] No commented-out code or debug logs

## GitHub Actions

When you push to main:
1. Workflow analyzes your commits since last tag
2. Determines version bump (major/minor/patch/none)
3. Updates `pubspec.yaml` and `CHANGELOG.md`
4. Creates Git tag (e.g., `v0.2.0`)
5. Creates GitHub Release
6. Pushes changes back to main

**Note**: Commits with `chore(release)` are skipped to avoid loops.

## Resources

- [Trunk-Based Development](https://trunkbaseddevelopment.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Pro Git Book](https://git-scm.com/book/en/v2)
