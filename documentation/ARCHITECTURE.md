# Project Architecture

This document describes the architecture and organization of the Sudoku Flutter app.

## Overview

The project follows **Clean Architecture** principles with a **Feature-First** folder structure. This approach provides:

- Clear separation of concerns
- Testability at each layer
- Independence from frameworks and UI
- Flexibility to change implementations

## Folder Structure

```
lib/
├── core/                    # Core utilities and constants
│   ├── constants/          # App-wide constants (board size, difficulties, etc.)
│   ├── theme/              # Theme configuration (light/dark themes)
│   └── utils/              # Utility functions and helpers
├── features/               # Feature modules (feature-first organization)
│   ├── game/              # Game playing feature
│   │   ├── data/          # Data layer (repositories, data sources, models)
│   │   ├── domain/        # Domain layer (entities, use cases)
│   │   └── presentation/  # Presentation layer (UI, widgets, state)
│   └── settings/          # Settings feature
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/                # Shared code across features
│   ├── providers/         # Shared Riverpod providers
│   └── widgets/           # Reusable widgets
└── main.dart             # App entry point
```

## Clean Architecture Layers

Each feature is organized into three layers:

### 1. Domain Layer (`domain/`)
**Pure business logic - no dependencies on Flutter or external packages**

- **Entities**: Core business objects (e.g., `Board`, `Cell`, `Puzzle`)
- **Use Cases**: Business rules and operations (e.g., `ValidateMove`, `GeneratePuzzle`)
- **Repositories (interfaces)**: Abstract contracts for data access

**Rules:**
- Contains only pure Dart code
- No dependencies on Flutter or external frameworks
- Defines interfaces that outer layers implement
- Most stable layer - rarely changes

### 2. Data Layer (`data/`)
**Implementation of data access and storage**

- **Repositories (implementations)**: Concrete repository implementations
- **Data Sources**: Local (Hive) and remote data access
- **Models**: Data transfer objects and serialization

**Rules:**
- Implements repository interfaces from domain layer
- Handles data persistence (Hive, SharedPreferences)
- Converts between models and entities
- No UI dependencies

### 3. Presentation Layer (`presentation/`)
**User interface and state management**

- **Widgets**: UI components
- **State**: Riverpod providers and state notifiers
- **Pages**: Full-screen views

**Rules:**
- Depends on domain layer (uses entities and use cases)
- Uses Riverpod for state management
- Contains Flutter-specific code
- Most volatile layer - changes frequently

## State Management

The app uses **Riverpod** for state management:

- **Providers**: Global state and dependency injection
- **StateNotifier**: Complex state logic
- **FutureProvider/StreamProvider**: Async operations

### Provider Organization

- Feature-specific providers live in `features/<feature>/presentation/providers/`
- Shared providers live in `shared/providers/`
- Theme provider example: `shared/providers/theme_provider.dart`

## Dependency Flow

```
Presentation → Domain ← Data
     ↓
  Shared
```

- **Presentation** depends on **Domain**
- **Data** implements **Domain** interfaces
- **Domain** has no dependencies (pure Dart)
- **Shared** provides common utilities

## Naming Conventions

### Files and Folders
- **Files**: `snake_case.dart`
- **Folders**: `snake_case`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `camelCase` or `SCREAMING_SNAKE_CASE` for compile-time constants

### Feature Structure Example

```
game/
├── data/
│   ├── data_sources/
│   │   └── game_local_data_source.dart
│   ├── models/
│   │   └── board_model.dart
│   └── repositories/
│       └── game_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── board.dart
│   │   └── cell.dart
│   ├── repositories/
│   │   └── game_repository.dart
│   └── usecases/
│       ├── validate_move.dart
│       └── generate_puzzle.dart
└── presentation/
    ├── pages/
    │   └── game_page.dart
    ├── providers/
    │   └── game_state_provider.dart
    └── widgets/
        ├── game_board.dart
        └── number_pad.dart
```

## Testing Strategy

### Unit Tests
- **Domain**: Test entities and use cases (pure logic)
- **Data**: Test repositories and data sources (with mocks)
- **Presentation**: Test state logic (providers and notifiers)

### Widget Tests
- Test UI components in isolation
- Test user interactions
- Located in `test/widget/`

### Test Organization
Mirror the `lib/` structure:
```
test/
├── unit/
│   ├── core/
│   ├── features/
│   │   └── game/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   └── shared/
├── widget/
└── helpers/
```

## Core Modules

### Constants
Located in `lib/core/constants/`:
- `app_constants.dart`: Board size, difficulty levels, game rules

### Theme
Located in `lib/core/theme/`:
- `app_theme.dart`: Material Design theme configuration (light/dark)

### Utilities
Located in `lib/core/utils/`:
- Validators, formatters, and helper functions

## Adding a New Feature

1. **Create feature folder** under `lib/features/`
2. **Add domain layer** first (entities, use cases, repository interfaces)
3. **Write unit tests** for domain logic
4. **Implement data layer** (repository implementations, data sources)
5. **Create presentation layer** (UI, providers, widgets)
6. **Write widget tests** for UI components

## Dependency Injection

Riverpod handles dependency injection:

```dart
// Domain: Define use case
final generatePuzzleProvider = Provider<GeneratePuzzle>(
  (ref) => GeneratePuzzle(ref.watch(gameRepositoryProvider)),
);

// Data: Provide repository implementation
final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepositoryImpl(ref.watch(localDataSourceProvider)),
);

// Presentation: Use in UI
final puzzleProvider = FutureProvider<Board>((ref) async {
  final generatePuzzle = ref.read(generatePuzzleProvider);
  return generatePuzzle(difficulty: Difficulty.easy);
});
```

## Design Principles

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Dependency Inversion**: Depend on abstractions, not concretions
3. **Single Responsibility**: Each class/function does one thing
4. **Open/Closed**: Open for extension, closed for modification
5. **Feature-First**: Organize by feature, not by layer

## Benefits

### ✅ Testability
Each layer can be tested in isolation with mocks

### ✅ Maintainability
Clear structure makes code easy to find and modify

### ✅ Scalability
Easy to add new features without affecting existing code

### ✅ Flexibility
Can swap implementations (e.g., change data source) without affecting business logic

### ✅ Collaboration
Multiple developers can work on different features simultaneously

## References

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Riverpod Documentation](https://riverpod.dev/)
- [Feature-First vs Layer-First](https://codewithandrea.com/articles/flutter-project-structure/)
