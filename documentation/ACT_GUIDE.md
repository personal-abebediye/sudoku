# Running CI Checks Locally

## Git Hooks (Automated)

This project uses a **pre-push git hook** to automatically run CI checks before every push. The hook is located at `.git/hooks/pre-push` and runs:

1. **Code formatting** (`dart format`)
2. **Static analysis** (`flutter analyze`)
3. **Tests** (`flutter test`)

### Hook Installation

The hook source is in `hooks/pre-push`. To install or update:

```bash
# Copy hook to git hooks directory
cp hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

### Bypassing the Hook

If you need to push without running checks (not recommended):
```bash
git push --no-verify
```

## Manual Checks

You can also run checks manually:

## Installation

Act is already installed via Homebrew:
```bash
brew install act
```

## Configuration

The `.actrc` file contains default configuration for act:
- Uses `catthehacker/ubuntu:act-latest` Docker image
- Sets repository environment variables

## Usage

### Run CI Workflow Locally

**Note:** Flutter-specific actions may not work well in act due to version/architecture constraints. For Flutter projects, it's recommended to use Flutter CLI tools directly.

**Validate workflow syntax:**
```bash
# Dry run to check workflow syntax
act push -W .github/workflows/ci.yml --dryrun

# List available workflows
act -l
```

**Run checks with Flutter CLI (recommended for this project):**
```bash
dart format .           # Format code
flutter analyze         # Static analysis
flutter test --coverage # Tests with coverage
```

### Run Version Bump Workflow (Careful!)

```bash
# Test version bump workflow (read-only)
act push -W .github/workflows/version-bump.yml --dryrun

# Note: Don't actually run version-bump locally, only test it
```

## Development Workflow with Act

### Before Every Push

```bash
# 1. Format code
dart format .

# 2. Run analyzer
flutter analyze

# 3. Run tests locally with coverage
flutter test --coverage

# 4. (Optional) Test CI workflow with act
#    Note: Flutter-specific actions may not work in act
#    but you can test workflow syntax and structure
act push -W .github/workflows/ci.yml --dryrun

# 5. If all pass, commit and push
git add .
git commit -m "feat: your commit message"
git push origin main
```

### Quick Pre-Push Script

Create an alias or script:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias prepush='dart format . && flutter analyze && flutter test --coverage'
```

Then before pushing:
```bash
prepush  # Runs all checks locally
git push origin main  # Push if all pass
```

## Troubleshooting

### Docker Not Running
```bash
# Start Docker Desktop on macOS
open -a Docker

# Or use colima (lightweight alternative)
brew install colima
colima start
```

### Slow First Run
- Act downloads Docker images on first run
- Subsequent runs are faster (images cached)
- Use `--pull=false` to skip image updates

### Image Size Issues
- Default images are large (~1GB+)
- Medium image (`catthehacker/ubuntu:act-latest`) is recommended
- Configured in `.actrc`

### Permission Issues
```bash
# If act can't access Docker
sudo chmod 666 /var/run/docker.sock
```

## Act vs GitHub Actions

### Differences
- Act runs in Docker containers
- Some GitHub-specific features may not work (e.g., creating releases)
- Secrets need to be passed via command line or `.secrets` file
- Some actions may behave differently
- **Flutter-specific actions may fail** with version/architecture issues in act

### Best Practices for Flutter Projects
- ✅ **Run checks locally with Flutter CLI** (`dart format`, `flutter analyze`, `flutter test`)
- ✅ Use act for **dry-run validation** of workflow syntax
- ✅ Use act for **generic workflows** (e.g., Node.js, Python)
- ❌ Don't rely on act for Flutter-specific workflows (use Flutter CLI instead)
- ❌ Don't use act for deployment/release workflows (test with dry-run only)

### Recommended Pre-Push Workflow for This Project
Since Flutter actions don't run well in act, use Flutter CLI directly:
```bash
dart format . && flutter analyze && flutter test --coverage
```
This gives the same validation as CI without Docker overhead!

## Advanced Usage

### Run Specific Step
```bash
# Run only up to a specific step
act push -W .github/workflows/ci.yml --job test --step "Run tests"
```

### Use Different Docker Image
```bash
# Use larger image with more tools
act push -P ubuntu-latest=catthehacker/ubuntu:full-latest

# Use minimal image (faster but fewer tools)
act push -P ubuntu-latest=node:16-alpine
```

### Debug Mode
```bash
# Verbose output
act push -W .github/workflows/ci.yml -v

# Super verbose
act push -W .github/workflows/ci.yml -vv
```

## Resources

- [Act Documentation](https://github.com/nektos/act)
- [Docker Images for Act](https://github.com/catthehacker/docker_images)
- [GitHub Actions Syntax](https://docs.github.com/en/actions)

## TL;DR

**Before every push (Flutter CLI - Recommended):**
```bash
dart format . && flutter analyze && flutter test --coverage
```

**Or validate workflow syntax with act:**
```bash
act push -W .github/workflows/ci.yml --dryrun
```

This catches issues locally, saving time and avoiding broken builds on GitHub!

**Note:** For this Flutter project, Flutter CLI tools provide better local validation than act due to Flutter-specific action limitations in Docker.
