# Semantic Versioning with Conventional Commits

This project uses automated semantic versioning based on [Conventional Commits](https://www.conventionalcommits.org/).

## Commit Message Format

All commit messages must follow this format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type
Must be one of the following:

- **feat**: A new feature (triggers **MINOR** version bump)
- **fix**: A bug fix (triggers **PATCH** version bump)
- **perf**: Performance improvements (triggers **PATCH** version bump)
- **docs**: Documentation only changes (no version bump)
- **style**: Code style changes (formatting, missing semi-colons, etc.) (no version bump)
- **refactor**: Code change that neither fixes a bug nor adds a feature (no version bump)
- **test**: Adding or updating tests (no version bump)
- **chore**: Changes to build process, dependencies, or tooling (no version bump)
- **ci**: Changes to CI configuration files and scripts (no version bump)

### Breaking Changes
To trigger a **MAJOR** version bump, use one of these:

1. Add `!` after the type/scope:
   ```
   feat!: remove support for Flutter 2.x
   ```

2. Add `BREAKING CHANGE:` in the footer:
   ```
   feat: update state management to Riverpod 3.0

   BREAKING CHANGE: StateProvider API has changed
   ```

### Scope (optional)
The scope provides additional context about what part of the codebase is affected:

- `game`: Game logic and board management
- `solver`: Puzzle solving algorithms
- `generator`: Puzzle generation
- `ui`: User interface components
- `storage`: Data persistence
- `stats`: Statistics and achievements
- `theme`: Theme and styling
- `settings`: App settings

### Examples

```bash
# New feature (bumps from 1.2.3 to 1.3.0)
feat(game): add hint system with three hint types

# Bug fix (bumps from 1.2.3 to 1.2.4)
fix(solver): correct validation logic for 3x3 boxes

# Performance improvement (bumps from 1.2.3 to 1.2.4)
perf(generator): optimize puzzle generation algorithm

# Breaking change (bumps from 1.2.3 to 2.0.0)
feat(storage)!: migrate from SharedPreferences to Hive

BREAKING CHANGE: Existing save data will need migration

# No version bump
docs: update README with installation instructions
chore(deps): update flutter_riverpod to 2.5.1
test(game): add tests for hint validation
```

## Version Automation

### Trunk-Based Development Workflow

This project uses trunk-based development (single main branch):

1. **Make changes** directly on `main` branch
2. **Commit frequently** with conventional commit messages:
   ```bash
   git add .
   git commit -m "feat(game): add undo/redo functionality"
   ```
3. **Push to main**: Version bumping happens automatically via GitHub Actions
   ```bash
   git push origin main
   ```

**Tips for trunk-based development:**
- Commit small, incremental changes frequently
- Each commit should be a working state (compiles and passes tests)
- Use `git commit --amend` to fix the last commit before pushing
- Test locally before pushing to avoid breaking the build

### Manual Version Management (if needed)

```bash
# Install cider globally
dart pub global activate cider

# Bump version manually
cider bump patch    # 1.2.3 -> 1.2.4
cider bump minor    # 1.2.3 -> 1.3.0
cider bump major    # 1.2.3 -> 2.0.0

# Add changelog entry
cider log added "New hint system"
cider log fixed "Validation bug in solver"
cider log changed "Updated UI theme"

# Commit changes
cider release
```

## Changelog

The `CHANGELOG.md` file is automatically updated with each release. It follows the [Keep a Changelog](https://keepachangelog.com/) format:

- **Added**: New features
- **Changed**: Changes to existing functionality
- **Deprecated**: Features that will be removed soon
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security fixes

## CI/CD Workflow

When you push to `main`:

1. GitHub Actions analyzes commits since last tag
2. Determines version bump type (major/minor/patch/none)
3. Updates `pubspec.yaml` with new version
4. Updates `CHANGELOG.md` with new entries
5. Creates a Git tag (e.g., `v1.3.0`)
6. Creates a GitHub Release
7. Pushes changes back to repository

**Note**: Commits with `chore(release)` in the message are skipped to avoid infinite loops.

## Best Practices

1. **Commit often** with clear, descriptive messages
2. **Keep commits focused** - one logical change per commit
3. **Use the body** to explain *why* changes were made, not *what* (that's in the code)
4. **Reference issues**: `fix(game): correct timer pause bug (#123)`
5. **Review before pushing** to main - once pushed, versions are automatic
6. **Squash feature branch commits** before merging to keep main history clean

## Troubleshooting

### Workflow doesn't run
- Ensure you're pushing to `main` branch
- Check that commit messages follow conventional format
- Verify GitHub Actions is enabled in repository settings

### Wrong version bump
- Review commit messages since last tag
- Ensure breaking changes use `!` or `BREAKING CHANGE:`
- Remember: only `feat`, `fix`, and `perf` trigger bumps

### Need to skip version bump
- Use commit types that don't trigger bumps: `docs`, `chore`, `test`, etc.
- Or commit directly with `chore(release)` in the message

## Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Cider Documentation](https://pub.dev/packages/cider)
- [Keep a Changelog](https://keepachangelog.com/)
