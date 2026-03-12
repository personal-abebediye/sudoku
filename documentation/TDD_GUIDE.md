# Test-Driven Development (TDD) Guide

## Overview

This project follows **Test-Driven Development (TDD)** principles. Always write tests before implementation code.

## The TDD Cycle: Red-Green-Refactor

```
┌─────────────┐
│   Red 🔴    │  Write a failing test
│             │  (Test what you want to build)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Green 🟢   │  Write minimal code to pass
│             │  (Make the test pass)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Refactor ♻️  │  Improve code quality
│             │  (Keep tests passing)
└──────┬──────┘
       │
       └─────► Repeat
```

## TDD Workflow for Sudoku App

### 1. Red Phase - Write Failing Test

Create test file before the implementation file:

```dart
// test/features/game/domain/entities/sudoku_board_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/entities/sudoku_board.dart';

void main() {
  group('SudokuBoard', () {
    test('should create 9x9 empty board', () {
      // Arrange
      const expectedSize = 9;
      
      // Act
      final board = SudokuBoard.empty();
      
      // Assert
      expect(board.grid.length, expectedSize);
      expect(board.grid[0].length, expectedSize);
      expect(board.grid[0][0], 0); // Empty cells are 0
    });
  });
}
```

**Run the test (it should fail):**
```bash
flutter test test/features/game/domain/entities/sudoku_board_test.dart
```

Expected: ❌ Test fails because `SudokuBoard` doesn't exist yet.

### 2. Green Phase - Write Minimal Code

Create implementation to pass the test:

```dart
// lib/features/game/domain/entities/sudoku_board.dart
class SudokuBoard {
  final List<List<int>> grid;

  SudokuBoard({required this.grid});

  factory SudokuBoard.empty() {
    final grid = List.generate(
      9,
      (_) => List.filled(9, 0),
    );
    return SudokuBoard(grid: grid);
  }
}
```

**Run the test again:**
```bash
flutter test test/features/game/domain/entities/sudoku_board_test.dart
```

Expected: ✅ Test passes!

### 3. Refactor Phase - Improve Code

Now improve the code while keeping tests green:

```dart
// lib/features/game/domain/entities/sudoku_board.dart
class SudokuBoard {
  static const int boardSize = 9;
  
  final List<List<int>> grid;

  const SudokuBoard({required this.grid});

  factory SudokuBoard.empty() {
    final grid = List.generate(
      boardSize,
      (_) => List.filled(boardSize, 0),
    );
    return SudokuBoard(grid: grid);
  }
  
  // Add getter for immutable access
  List<List<int>> get cells => grid.map((row) => List.from(row)).toList();
}
```

**Run tests to ensure they still pass:**
```bash
flutter test test/features/game/domain/entities/sudoku_board_test.dart
```

Expected: ✅ Tests still pass after refactoring!

## TDD Best Practices

### ✅ Do

1. **Always write test first**
   - No implementation without a failing test
   - Test defines the behavior you want

2. **Keep tests simple and focused**
   - One concept per test
   - Use descriptive test names
   - Follow AAA pattern: Arrange, Act, Assert

3. **Write minimal code to pass**
   - Don't add features not covered by tests
   - Resist the urge to over-engineer

4. **Refactor fearlessly**
   - Tests give you confidence
   - Keep tests green while refactoring

5. **Run tests frequently**
   - After each change
   - Use `flutter test --watch` for continuous testing

6. **Test behavior, not implementation**
   - Test what the code does, not how it does it
   - Tests should survive refactoring

### ❌ Don't

1. **Don't write implementation first**
   - No "I'll add tests later" mentality
   - Tests are not optional

2. **Don't write multiple tests at once**
   - Focus on one test at a time
   - Keep the cycle tight (minutes, not hours)

3. **Don't skip refactor step**
   - Technical debt accumulates quickly
   - Clean code is maintainable code

4. **Don't test external dependencies directly**
   - Mock external services
   - Focus on your code's behavior

5. **Don't ignore failing tests**
   - Fix or update immediately
   - Never commit with failing tests

## Test Structure

### Unit Tests (Business Logic)

```dart
// test/features/game/domain/use_cases/validate_move_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidateMove', () {
    late ValidateMove validateMove;
    
    setUp(() {
      validateMove = ValidateMove();
    });
    
    group('row validation', () {
      test('should return false when number already exists in row', () {
        // Arrange
        final board = SudokuBoard(grid: [
          [1, 2, 3, 4, 5, 6, 7, 8, 9],
          // ... other rows
        ]);
        
        // Act
        final result = validateMove.call(
          board: board,
          row: 0,
          col: 0,
          number: 1,
        );
        
        // Assert
        expect(result.isValid, false);
        expect(result.reason, 'Number already exists in row');
      });
    });
  });
}
```

### Widget Tests (UI Components)

```dart
// test/features/game/presentation/widgets/sudoku_cell_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SudokuCell', () {
    testWidgets('should display number when cell is filled', (tester) async {
      // Arrange
      const number = 5;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuCell(
              number: number,
              isClue: true,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('5'), findsOneWidget);
    });
    
    testWidgets('should highlight when selected', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuCell(
              number: 0,
              isSelected: true,
            ),
          ),
        ),
      );
      
      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isNotNull);
      // Add more specific assertions about highlight style
    });
  });
}
```

### Integration Tests (User Flows)

```dart
// integration_test/game_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Game Flow', () {
    testWidgets('user can start and complete a puzzle', (tester) async {
      // Start app
      await tester.pumpWidget(const SudokuApp());
      await tester.pumpAndSettle();
      
      // Start new game
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      
      // Select difficulty
      await tester.tap(find.text('Easy'));
      await tester.pumpAndSettle();
      
      // Verify board is displayed
      expect(find.byType(GameBoard), findsOneWidget);
      
      // Make a move
      await tester.tap(find.byKey(const Key('cell_0_0')));
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      
      // Verify move was applied
      expect(find.text('1'), findsWidgets);
    });
  });
}
```

## TDD Example: Complete Feature

Let's build a feature using TDD: **Validate Row**

### Step 1: Write Test for Row Validation

```dart
// test/features/game/domain/validators/row_validator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/validators/row_validator.dart';

void main() {
  group('RowValidator', () {
    test('should return true when row has no duplicates', () {
      // Arrange
      final row = [1, 2, 3, 4, 5, 6, 7, 8, 9];
      final validator = RowValidator();
      
      // Act
      final result = validator.isValid(row);
      
      // Assert
      expect(result, true);
    });
    
    test('should return false when row has duplicates', () {
      // Arrange
      final row = [1, 2, 3, 1, 5, 6, 7, 8, 9]; // duplicate 1
      final validator = RowValidator();
      
      // Act
      final result = validator.isValid(row);
      
      // Assert
      expect(result, false);
    });
    
    test('should ignore empty cells (0) when checking duplicates', () {
      // Arrange
      final row = [0, 0, 3, 0, 5, 0, 7, 0, 9];
      final validator = RowValidator();
      
      // Act
      final result = validator.isValid(row);
      
      // Assert
      expect(result, true);
    });
  });
}
```

**Run test:** ❌ Fails (RowValidator doesn't exist)

### Step 2: Write Minimal Implementation

```dart
// lib/features/game/domain/validators/row_validator.dart
class RowValidator {
  bool isValid(List<int> row) {
    final nonZeroNumbers = row.where((num) => num != 0).toList();
    final uniqueNumbers = nonZeroNumbers.toSet();
    return nonZeroNumbers.length == uniqueNumbers.length;
  }
}
```

**Run test:** ✅ Passes!

### Step 3: Refactor

```dart
// lib/features/game/domain/validators/row_validator.dart
class RowValidator {
  /// Validates that a Sudoku row has no duplicate numbers.
  /// Empty cells (0) are ignored in validation.
  bool isValid(List<int> row) {
    final filledCells = row.where((number) => number != 0);
    return filledCells.length == filledCells.toSet().length;
  }
}
```

**Run test:** ✅ Still passes after refactoring!

### Step 4: Add More Test Cases

```dart
test('should return true for empty row', () {
  final row = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  final validator = RowValidator();
  expect(validator.isValid(row), true);
});

test('should return false when single number appears twice', () {
  final row = [5, 0, 0, 5, 0, 0, 0, 0, 0];
  final validator = RowValidator();
  expect(validator.isValid(row), false);
});
```

**Run tests:** ✅ All pass! Implementation is complete.

## Running Tests

### During Development

```bash
# Run specific test file
flutter test test/features/game/domain/entities/sudoku_board_test.dart

# Run all tests in directory
flutter test test/features/game/

# Run tests in watch mode (re-runs on file changes)
flutter test --watch

# Run with coverage
flutter test --coverage
open coverage/html/index.html
```

### Before Commit

```bash
# Run all tests
flutter test

# Run analyzer
flutter analyze

# Format code
flutter format .
```

## TDD for Different Scenarios

### Testing Algorithms (Puzzle Generator)

```dart
test('generated puzzle should have unique solution', () {
  final generator = PuzzleGenerator();
  final puzzle = generator.generate(Difficulty.medium);
  
  final solver = Solver();
  final solutions = solver.findAllSolutions(puzzle);
  
  expect(solutions.length, 1);
});
```

### Testing State Management (Riverpod)

```dart
test('game state should update when move is made', () {
  final container = ProviderContainer();
  final gameState = container.read(gameStateProvider.notifier);
  
  gameState.makeMove(row: 0, col: 0, number: 5);
  
  final state = container.read(gameStateProvider);
  expect(state.board.grid[0][0], 5);
});
```

### Testing UI Interactions

```dart
testWidgets('should call onTap when cell is tapped', (tester) async {
  var tapped = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SudokuCell(
          number: 0,
          onTap: () => tapped = true,
        ),
      ),
    ),
  );
  
  await tester.tap(find.byType(SudokuCell));
  
  expect(tapped, true);
});
```

## Test Coverage Goals

- **Overall:** >80% line coverage
- **Business Logic (domain/):** >95% line coverage
- **UI Components:** >70% widget coverage
- **Critical Paths:** 100% coverage (validation, generation, solving)

### Check Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Common Testing Patterns

### Arrange-Act-Assert (AAA)

```dart
test('description', () {
  // Arrange - Set up test data and conditions
  final input = 'test data';
  final expected = 'expected result';
  
  // Act - Execute the code being tested
  final result = functionUnderTest(input);
  
  // Assert - Verify the result
  expect(result, expected);
});
```

### Given-When-Then (BDD Style)

```dart
test('should validate move when number is valid', () {
  // Given
  final board = SudokuBoard.empty();
  final validator = MoveValidator();
  
  // When
  final result = validator.validate(board, row: 0, col: 0, number: 5);
  
  // Then
  expect(result.isValid, true);
});
```

### Setup and Teardown

```dart
group('GameState', () {
  late GameState gameState;
  late SudokuBoard board;
  
  setUp(() {
    // Runs before each test
    board = SudokuBoard.empty();
    gameState = GameState(board);
  });
  
  tearDown(() {
    // Runs after each test (if needed)
    // Clean up resources
  });
  
  test('test 1', () { /* uses gameState */ });
  test('test 2', () { /* uses gameState */ });
});
```

## Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Test-Driven Development](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
- [Testing Best Practices](https://flutter.dev/docs/cookbook/testing)
- [Mockito for Dart](https://pub.dev/packages/mockito)

## Remember

> **"Write the test you wish you had, then make it real."**

TDD isn't just about testing—it's a design methodology that leads to:
- ✅ Better code architecture
- ✅ Fewer bugs
- ✅ Easier refactoring
- ✅ Living documentation
- ✅ Confidence in changes

**Red → Green → Refactor → Repeat**
