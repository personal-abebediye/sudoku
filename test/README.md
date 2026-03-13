# Testing Infrastructure Documentation

## Overview
This document describes the testing infrastructure for the Sudoku project.

## Test Structure

```
test/
├── fixtures/              # Test data and sample boards
│   └── board_fixtures.dart
├── helpers/               # Test utilities and custom matchers
│   └── test_helpers.dart
├── unit/                  # Unit tests for business logic
│   └── core/
│       └── constants/
├── widget/                # Widget tests for UI components
└── integration_test/      # Integration tests (in root)
```

## Running Tests

### All Tests
```bash
flutter test
```

### Specific Test File
```bash
flutter test test/unit/core/constants/app_constants_test.dart
```

### With Coverage
```bash
flutter test --coverage
open coverage/html/index.html  # View coverage report
```

### Watch Mode (TDD)
```bash
flutter test --watch
```

## Test Helpers

### Custom Matchers
Located in `test/helpers/test_helpers.dart`:

- `isValidBoardSize(int size)` - Validates board dimensions
- `isEmptyBoard()` - Checks if board is empty (all zeros)
- `isValidSudokuNumber()` - Validates Sudoku numbers (1-9)

### Test Fixtures
Located in `test/fixtures/board_fixtures.dart`:

- `validCompletedBoard` - A solved Sudoku board
- `easyPuzzle` - An easy difficulty puzzle
- `invalidRowBoard` - Board with invalid row (for testing validation)
- `emptyBoard` - Empty 9x9 board

## Coverage Goals

- **Overall:** >80% line coverage
- **Business Logic (domain/):** >95%
- **UI Components:** >70%
- **Critical Paths:** 100%

## CI/CD Integration

Tests run automatically on:
- Every push to `main`
- Every pull request
- Coverage must be ≥80% to pass

See `.github/workflows/ci.yml` for details.

## Writing Tests

### Unit Test Example
```dart
test('should validate board size', () {
  // Arrange
  final board = SudokuBoard.empty();
  
  // Act
  final size = board.size;
  
  // Assert
  expect(size, 9);
});
```

### Widget Test Example
```dart
testWidgets('should display number in cell', (tester) async {
  // Arrange
  const number = 5;
  
  // Act
  await tester.pumpWidget(
    MaterialApp(home: SudokuCell(number: number)),
  );
  
  // Assert
  expect(find.text('5'), findsOneWidget);
});
```

## TDD Workflow

1. 🔴 **Red** - Write failing test
2. 🟢 **Green** - Write minimal code to pass
3. ♻️ **Refactor** - Improve code quality
4. 🔁 **Repeat**

See [TDD_GUIDE.md](../TDD_GUIDE.md) for detailed examples.
