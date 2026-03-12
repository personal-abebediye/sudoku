# Copilot Instructions - Sudoku App

## Project Overview

Cross-platform Sudoku game built with Flutter, targeting iOS, Android, Web, and Desktop platforms.

## Build, Test, and Lint Commands

### Development
```bash
# Run in development mode
flutter run

# Run on specific platform
flutter run -d chrome        # Web
flutter run -d macos         # macOS
flutter run -d ios           # iOS simulator
flutter run -d android       # Android emulator

# Hot reload: press 'r' in terminal
# Hot restart: press 'R' in terminal
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Run tests with coverage
flutter test --coverage

# Run widget tests only
flutter test test/widgets/

# Run unit tests only
flutter test test/unit/

# Run integration tests
flutter test integration_test/
```

### Linting and Formatting
```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Format specific file
flutter format lib/path/to/file.dart

# Check formatting without modifying
flutter format --set-exit-if-changed .
```

### Building
```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android)
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Build Web
flutter build web --release

# Build macOS
flutter build macos --release
```

## Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── core/                     # Core functionality and utilities
│   ├── constants/           # App-wide constants
│   ├── theme/               # Theme configuration
│   └── utils/               # Utility functions
├── features/                # Feature-based organization
│   ├── game/                # Sudoku game logic
│   │   ├── data/           # Data sources and repositories
│   │   ├── domain/         # Business logic and entities
│   │   └── presentation/   # UI components and state
│   ├── solver/              # Sudoku solving algorithms
│   └── generator/           # Sudoku puzzle generation
└── shared/                  # Shared widgets and components
    ├── widgets/
    └── models/
```

### State Management
- **Primary**: Use Riverpod for state management
- **Local UI state**: Use StatefulWidget or hooks for simple component-level state
- **Game state**: Managed through providers in `features/game/presentation/providers/`
- **Persistence**: Use shared_preferences for settings, hive for game saves

### Design Patterns
- **Feature-first architecture**: Organize code by feature rather than by layer
- **Repository pattern**: Abstract data sources behind repositories in the `data/` layer
- **Provider pattern**: Expose game logic through Riverpod providers
- **Separation of concerns**: Keep business logic in `domain/`, UI in `presentation/`, data access in `data/`

## Key Conventions

### Sudoku Game Logic
- **Board representation**: Use 2D List<List<int>> where 0 represents empty cells (1-9 for filled)
- **Immutability**: Game state should be immutable; create new instances for state changes
- **Validation**: Always validate moves before applying them to the board
- **Difficulty levels**: Easy (40-45 empty cells), Medium (45-50), Hard (50-55), Expert (55+)

### Code Style
- **File naming**: Use snake_case for file names (e.g., `game_board.dart`)
- **Class naming**: Use PascalCase for classes (e.g., `GameBoard`)
- **Private members**: Prefix with underscore (e.g., `_validateMove()`)
- **Widget organization**: Place widgets in `presentation/widgets/`, screens in `presentation/screens/`

### Testing Strategy (Test-Driven Development)
- **TDD Workflow**: Write tests BEFORE implementation code
  1. Write failing test (Red)
  2. Write minimal code to pass (Green)
  3. Refactor while keeping tests green (Refactor)
- **Unit tests**: Test all business logic in `domain/` layer (>80% coverage)
- **Widget tests**: Test UI components in isolation
- **Integration tests**: Test complete user flows (placed in `integration_test/` directory)
- **Test file naming**: Match source files with `_test.dart` suffix (e.g., `game_board_test.dart` for `game_board.dart`)
- **Mock data**: Create test fixtures in `test/fixtures/`
- **Run tests frequently**: `flutter test --watch` during development

### Performance Considerations
- **Solver algorithms**: Implement backtracking with optimizations (naked singles, hidden singles)
- **Generator**: Use efficient algorithms to ensure unique solutions
- **UI updates**: Minimize rebuilds by using const constructors and proper provider scoping
- **Animations**: Keep animations at 60fps; use `AnimatedBuilder` or implicit animations

### Platform-Specific Code
- Place platform-specific implementations in `lib/platform/`
- Use conditional imports or Platform checks when necessary
- Keep platform code minimal; favor cross-platform solutions

### Dependencies
- Prefer well-maintained packages from pub.dev
- Document why each major dependency was chosen in this file when added
- Pin major versions in `pubspec.yaml` to avoid breaking changes

## Assets and Resources
- **Images**: Place in `assets/images/`
- **Fonts**: Place in `assets/fonts/`
- **Translations**: Use flutter_localizations; place strings in `lib/l10n/`
- Remember to declare all assets in `pubspec.yaml`

## Git Workflow

### Trunk-Based Development
- Work directly on `main` branch (single developer)
- Commit frequently with small, focused changes
- Use conventional commits for automatic semantic versioning
- Run tests and linting before pushing
- Every push to main triggers automatic version bumping and release

### Development Workflow (TDD)
1. **Write test first**: Create or update test file in `test/` directory
2. **Run test** to see it fail: `flutter test path/to/test_file.dart`
3. **Write minimal code**: Implement just enough to pass the test
4. **Run test** to see it pass (green)
5. **Refactor**: Clean up code while keeping tests green
6. **Commit**: Use conventional commits

### Commit Message Format
Follow [Conventional Commits](https://www.conventionalcommits.org/):
```bash
feat(scope): add new feature      # Minor version bump
fix(scope): fix bug               # Patch version bump
test: add tests for feature       # No version bump
docs: update documentation        # No version bump
chore: update dependencies        # No version bump
```

See [documentation/VERSIONING.md](../documentation/VERSIONING.md) and [documentation/TDD_GUIDE.md](../documentation/TDD_GUIDE.md) for complete guidelines.
