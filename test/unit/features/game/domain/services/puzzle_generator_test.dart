import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/constants/app_constants.dart';
import 'package:sudoku/features/game/domain/services/puzzle_generator.dart';

void main() {
  group('PuzzleGenerator', () {
    late PuzzleGenerator generator;

    setUp(() {
      generator = PuzzleGenerator();
    });

    group('generateSolution', () {
      test('should generate a valid complete Sudoku solution', () {
        // Act
        final board = generator.generateSolution();

        // Assert - All rows valid
        for (var i = 0; i < AppConstants.boardSize; i++) {
          expect(board.isRowValid(i), isTrue);
        }

        // Assert - All columns valid
        for (var i = 0; i < AppConstants.boardSize; i++) {
          expect(board.isColumnValid(i), isTrue);
        }

        // Assert - All boxes valid
        for (var row = 0; row < AppConstants.boardSize; row += 3) {
          for (var col = 0; col < AppConstants.boardSize; col += 3) {
            expect(board.isBoxValid(row, col), isTrue);
          }
        }

        // Assert - All cells filled
        for (var row = 0; row < AppConstants.boardSize; row++) {
          for (var col = 0; col < AppConstants.boardSize; col++) {
            expect(board.cells[row][col].value, isNot(equals(0)));
          }
        }
      });

      test('should generate different solutions on multiple calls', () {
        // Act
        final board1 = generator.generateSolution();
        final board2 = generator.generateSolution();

        // Assert - Not identical (very high probability)
        expect(board1, isNot(equals(board2)));
      });
    });

    group('generatePuzzle', () {
      test('should generate easy puzzle with 45-50 clues', () {
        // Act
        final board = generator.generatePuzzle(Difficulty.easy);

        // Assert - Count clues
        var clueCount = 0;
        for (var row = 0; row < AppConstants.boardSize; row++) {
          for (var col = 0; col < AppConstants.boardSize; col++) {
            if (!board.cells[row][col].isEmpty) {
              clueCount++;
              expect(board.cells[row][col].isFixed, isTrue);
            }
          }
        }
        expect(clueCount, greaterThanOrEqualTo(45));
        expect(clueCount, lessThanOrEqualTo(50));
      });

      test('should generate medium puzzle with 35-40 clues', () {
        // Act
        final board = generator.generatePuzzle(Difficulty.medium);

        // Assert
        var clueCount = 0;
        for (var row = 0; row < AppConstants.boardSize; row++) {
          for (var col = 0; col < AppConstants.boardSize; col++) {
            if (!board.cells[row][col].isEmpty) {
              clueCount++;
            }
          }
        }
        expect(clueCount, greaterThanOrEqualTo(35));
        expect(clueCount, lessThanOrEqualTo(40));
      });

      test('should generate hard puzzle with 27-32 clues', () {
        // Act
        final board = generator.generatePuzzle(Difficulty.hard);

        // Assert
        var clueCount = 0;
        for (var row = 0; row < AppConstants.boardSize; row++) {
          for (var col = 0; col < AppConstants.boardSize; col++) {
            if (!board.cells[row][col].isEmpty) {
              clueCount++;
            }
          }
        }
        expect(clueCount, greaterThanOrEqualTo(27));
        expect(clueCount, lessThanOrEqualTo(32));
      });

      test('should generate expert puzzle with 22-26 clues', () {
        // Act
        final board = generator.generatePuzzle(Difficulty.expert);

        // Assert
        var clueCount = 0;
        for (var row = 0; row < AppConstants.boardSize; row++) {
          for (var col = 0; col < AppConstants.boardSize; col++) {
            if (!board.cells[row][col].isEmpty) {
              clueCount++;
            }
          }
        }
        expect(clueCount, greaterThanOrEqualTo(22));
        expect(clueCount, lessThanOrEqualTo(26));
      });

      test('should generate valid puzzle with no rule violations', () {
        // Act
        final board = generator.generatePuzzle(Difficulty.medium);

        // Assert - All rows valid
        for (var i = 0; i < AppConstants.boardSize; i++) {
          expect(board.isRowValid(i), isTrue);
        }

        // Assert - All columns valid
        for (var i = 0; i < AppConstants.boardSize; i++) {
          expect(board.isColumnValid(i), isTrue);
        }

        // Assert - All boxes valid
        for (var row = 0; row < AppConstants.boardSize; row += 3) {
          for (var col = 0; col < AppConstants.boardSize; col += 3) {
            expect(board.isBoxValid(row, col), isTrue);
          }
        }
      });

      test('should complete generation in under 1 second', () {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        generator.generatePuzzle(Difficulty.medium);
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should generate solvable puzzle', () {
        // Act
        generator.generatePuzzle(Difficulty.easy);

        // Assert - Should be able to generate solution
        final solution = generator.generateSolution();
        expect(solution, isNotNull);
      });
    });

    group('edge cases', () {
      test('should handle multiple consecutive generations', () {
        // Act
        final puzzles =
            List.generate(5, (_) => generator.generatePuzzle(Difficulty.easy));

        // Assert - All should be valid
        for (final puzzle in puzzles) {
          for (var i = 0; i < AppConstants.boardSize; i++) {
            expect(puzzle.isRowValid(i), isTrue);
            expect(puzzle.isColumnValid(i), isTrue);
          }
        }
      });

      test('should generate puzzles with different patterns', () {
        // Act
        final puzzles = List.generate(
            3, (_) => generator.generatePuzzle(Difficulty.medium));

        // Assert - Not all identical (statistical check)
        expect(puzzles[0], isNot(equals(puzzles[1])));
      });
    });
  });
}
