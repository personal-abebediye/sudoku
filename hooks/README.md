# Git Hooks

This directory contains source files for Git hooks used in this project.

## Available Hooks

### pre-push

Automatically runs before every `git push` to ensure code quality.

**Checks performed:**
1. ✅ YAML validation (`yamllint` on workflow files)
2. ✅ Code formatting (`dart format`)
3. ✅ Static analysis (`flutter analyze`)
4. ✅ Unit tests (`flutter test`)

**Installation:**

The hook is already installed in `.git/hooks/pre-push`. If you need to reinstall:

```bash
cp hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push

# Install yamllint for YAML validation (optional but recommended)
brew install yamllint
```

**Bypassing the hook (not recommended):**
```bash
git push --no-verify
```

## Why Git Hooks?

Git hooks provide **immediate feedback** before code reaches CI:
- ✅ Catch formatting issues locally
- ✅ Catch test failures before pushing
- ✅ Prevent broken builds on GitHub
- ✅ Save CI minutes and time
- ✅ Enforce quality standards automatically

## Hook Maintenance

When updating the hook:
1. Edit `hooks/pre-push` (this source file)
2. Copy to `.git/hooks/pre-push`
3. Ensure it's executable (`chmod +x`)
4. Test with a dry-run push or run directly: `.git/hooks/pre-push`

**Note:** Hooks in `.git/hooks/` are **not** tracked by git. That's why we keep the source in this `hooks/` directory and commit it to the repository.

## Team Setup

New developers should install hooks after cloning:
```bash
cp hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

Consider adding this to SETUP.md as part of the initial setup process.
