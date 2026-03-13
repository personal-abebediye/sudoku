import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/constants/app_constants.dart';
import 'package:sudoku/features/game/domain/entities/board.dart';

void main() {
  group('Board', () {
    group('creation', () {
      test('should create an empty board with all cells value 0', () {
        // Arrange & Act
        final board = Board.empty();

        // Assert
        expect(board.cells.length, equals(AppConstants.boardSize));
        for (final row in board.cells) {
          expect(row.length, equals(AppConstants.boardSize));
          for (final cell in row) {
            expect(cell.value, equals(0));
            expect(cell.isFixed, isFalse);
          }
        }
      });

      test('should create a board from grid data', () {
        // Arrange
        final grid = List.generate(
          9,
          (i) => List.generate(9, (j) => i == j ? i + 1 : 0),
        );

        // Act
        final board = Board.fromGrid(grid);

        // Assert
        for (var i = 0; i < 9; i++) {
          for (var j = 0; j < 9; j++) {
            expect(board.cells[i][j].value, equals(grid[i][j]));
          }
        }
      });

      test('should mark non-zero cells as fixed when creating from grid', () {
        // Arrange
        final grid = [
          [5, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
        ];

        // Act
        final board = Board.fromGrid(grid);

        // Assert
        expect(board.cells[0][0].isFixed, isTrue);
        expect(board.cells[0][1].isFixed, isFalse);
      });
    });

    group('row validation', () {
      test('should return true for valid row with no duplicates', () {
        // Arrange
        final grid = [
          [1, 2, 3, 4, 5, 6, 7, 8, 9],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
        ];
        final board = Board.fromGrid(grid);

        // Act
        final isValid = board.isRowValid(0);

        // Assert
        expect(isValid, isTrue);
      });

      test('should return false for row with duplicate values', () {
        // Arrange
        final grid = [
          [1, 2, 3, 4, 5, 6, 7, 8, 1], // Duplicate 1
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
        ];
        final board = Board.fromGrid(grid);

        // Act
        final isValid = board.isRowValid(0);

        // Assert
        expect(isValid, isFalse);
      });

      test('should return true for row with zeros (empty cells)', () {
        // Arrange
        final grid = [
          [1, 0, 3, 0, 5, 0, 7, 0, 9],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
        ];
        final board = Board.fromGrid(grid);

        // Act
        final isValid = board.isRowValid(0);

        // Assert
        expect(isValid, isTrue);
      });
    });

    group('column validation', () {
      test('should return true for valid column with no duplicates', () {
        // Arrange
        final grid = [
          [1, 0, 0, 0, 0, 0, 0, 0, 0],
          [2, 0, 0, 0, 0, 0, 0, 0, 0],
          [3, 0, 0, 0, 0, 0, 0, 0, 0],
          [4, 0, 0, 0, 0, 0, 0, 0, 0],
          [5, 0, 0, 0, 0, 0, 0, 0, 0],
          [6, 0, 0, 0, 0, 0, 0, 0, 0],
          [7, 0, 0, 0, 0, 0, 0, 0, 0],
          [8, 0, 0, 0, 0, 0, 0, 0, 0],
          [9, 0, 0, 0, 0, 0, 0, 0, 0],
        ];
        final board = Board.fromGrid(grid);

        // Act
        final isValid = board.isColumnValid(0);

        // Assert
        expect(isValid, isTrue);
      });

      test('should return false for column with duplicate values', () {
        // Arrange
        final grid = [
          [1, 0, 0, 0, 0, 0, 0, 0, 0],
          [2, 0, 0, 0, 0, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0, 0, 0, 0], // Duplicate 1
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
        ];
        final board = Board.fromGrid(grid);

        // Act
        final isValid = board.isColumnValid(0);

        // Assert
        expect(isValid, isFalse);
      });
    });

    group('box validation', () {
      test('should return true for valid 3x3 box with no duplicates', () {
        // Arrange
        final grid = [
          [1, 2, 3, 0, 0, 0, 0, 0, 0],
          [4, 5, 6, 0, 0, 0, 0, 0, 0],
          [7, 8, 9, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
        ];
        final board = Board.fromGrid(grid);

        // Act
        final isValid = board.isBoxValid(0, 0); // Top-left box

        // Assert
        expect(isValid, isTrue);
      });

      test('should return false for box with duplicate values', () {
        // Arrange
        final grid = [
          [1, 2, 3, 0, 0, 0, 0, 0, 0],
          [4, 5, 6, 0, 0, 0, 0, 0, 0],
          [7, 8, 1, 0, 0, 0, 0, 0, 0], // Duplicate 1
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
        ];
        final board = Board.fromGrid(grid);

        // Act
        final isValid = board.isBoxValid(0, 0);

        // Assert
        expect(isValid, isFalse);
      });

      test('should validate middle box correctly', () {
        // Arrange
        final grid = [
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 1, 2, 3, 0, 0, 0],
          [0, 0, 0, 4, 5, 6, 0, 0, 0],
          [0, 0, 0, 7, 8, 9, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
        ];
        final board = Board.fromGrid(grid);

        // Act
        final isValid = board.isBoxValid(3, 3); // Middle box

        // Assert
        expect(isValid, isTrue);
      });
    });

    group('move validation', () {
      test('should return true for valid move', () {
        // Arrange
        final grid = List.generate(9, (_) => List.filled(9, 0));
        grid[0][0] = 1; // Set first cell
        final board = Board.fromGrid(grid);

        // Act
        final canMove = board.isValidMove(0, 1, 2);

        // Assert
        expect(canMove, isTrue);
      });

      test('should return false if number already in row', () {
        // Arrange
        final grid = List.generate(9, (_) => List.filled(9, 0));
        grid[0][0] = 5;
        final board = Board.fromGrid(grid);

        // Act
        final canMove = board.isValidMove(0, 1, 5); // Same row, same value

        // Assert
        expect(canMove, isFalse);
      });

      test('should return false if number already in column', () {
        // Arrange
        final grid = List.generate(9, (_) => List.filled(9, 0));
        grid[0][0] = 5;
        final board = Board.fromGrid(grid);

        // Act
        final canMove = board.isValidMove(1, 0, 5); // Same column, same value

        // Assert
        expect(canMove, isFalse);
      });

      test('should return false if number already in box', () {
        // Arrange
        final grid = List.generate(9, (_) => List.filled(9, 0));
        grid[0][0] = 5;
        final board = Board.fromGrid(grid);

        // Act
        final canMove = board.isValidMove(1, 1, 5); // Same box, same value

        // Assert
        expect(canMove, isFalse);
      });

      test('should return false for fixed cell', () {
        // Arrange
        final grid = List.generate(9, (_) => List.filled(9, 0));
        grid[0][0] = 5; // Will be marked as fixed
        final board = Board.fromGrid(grid);

        // Act
        final canMove = board.isValidMove(0, 0, 9); // Try to change fixed cell

        // Assert
        expect(canMove, isFalse);
      });
    });

    group('setCell', () {
      test('should update cell value if valid', () {
        // Arrange
        final board = Board.empty();

        // Act
        final newBoard = board.setCell(0, 0, 5);

        // Assert
        expect(newBoard.cells[0][0].value, equals(5));
        expect(board.cells[0][0].value, equals(0)); // Original unchanged
      });

      test('should not update fixed cell', () {
        // Arrange
        final grid = List.generate(9, (_) => List.filled(9, 0));
        grid[0][0] = 5;
        final board = Board.fromGrid(grid);

        // Act
        final newBoard = board.setCell(0, 0, 9);

        // Assert
        expect(newBoard.cells[0][0].value, equals(5)); // Unchanged
      });
    });

    group('edge cases', () {
      test('should validate all 9 boxes correctly', () {
        // Arrange - Create valid board with all boxes filled
        final grid = [
          [1, 2, 3, 4, 5, 6, 7, 8, 9],
          [4, 5, 6, 7, 8, 9, 1, 2, 3],
          [7, 8, 9, 1, 2, 3, 4, 5, 6],
          [2, 3, 4, 5, 6, 7, 8, 9, 1],
          [5, 6, 7, 8, 9, 1, 2, 3, 4],
          [8, 9, 1, 2, 3, 4, 5, 6, 7],
          [3, 4, 5, 6, 7, 8, 9, 1, 2],
          [6, 7, 8, 9, 1, 2, 3, 4, 5],
          [9, 1, 2, 3, 4, 5, 6, 7, 8],
        ];
        final board = Board.fromGrid(grid);

        // Act & Assert - Check all 9 boxes
        for (var boxRow = 0; boxRow < 9; boxRow += 3) {
          for (var boxCol = 0; boxCol < 9; boxCol += 3) {
            expect(board.isBoxValid(boxRow, boxCol), isTrue);
          }
        }
      });

      test('should handle boundary positions correctly', () {
        // Arrange
        final board = Board.empty();

        // Act & Assert - Test corners and edges
        expect(() => board.isValidMove(0, 0, 5), returnsNormally); // Top-left
        expect(() => board.isValidMove(0, 8, 5), returnsNormally); // Top-right
        expect(
            () => board.isValidMove(8, 0, 5), returnsNormally); // Bottom-left
        expect(
            () => board.isValidMove(8, 8, 5), returnsNormally); // Bottom-right
        expect(() => board.isValidMove(4, 4, 5), returnsNormally); // Center
      });

      test('should handle board with single non-zero value', () {
        // Arrange
        final grid = List.generate(9, (_) => List.filled(9, 0));
        grid[4][4] = 5; // Center cell only
        final board = Board.fromGrid(grid);

        // Act & Assert
        expect(board.isRowValid(4), isTrue);
        expect(board.isColumnValid(4), isTrue);
        expect(board.isBoxValid(4, 4), isTrue);
      });

      test('should validate completely filled board', () {
        // Arrange - Valid complete Sudoku solution
        final grid = [
          [5, 3, 4, 6, 7, 8, 9, 1, 2],
          [6, 7, 2, 1, 9, 5, 3, 4, 8],
          [1, 9, 8, 3, 4, 2, 5, 6, 7],
          [8, 5, 9, 7, 6, 1, 4, 2, 3],
          [4, 2, 6, 8, 5, 3, 7, 9, 1],
          [7, 1, 3, 9, 2, 4, 8, 5, 6],
          [9, 6, 1, 5, 3, 7, 2, 8, 4],
          [2, 8, 7, 4, 1, 9, 6, 3, 5],
          [3, 4, 5, 2, 8, 6, 1, 7, 9],
        ];
        final board = Board.fromGrid(grid);

        // Act & Assert - All rows, columns, and boxes should be valid
        for (var i = 0; i < 9; i++) {
          expect(board.isRowValid(i), isTrue);
          expect(board.isColumnValid(i), isTrue);
        }
        for (var row = 0; row < 9; row += 3) {
          for (var col = 0; col < 9; col += 3) {
            expect(board.isBoxValid(row, col), isTrue);
          }
        }
      });

      test('should detect invalid move in corner box', () {
        // Arrange
        final grid = List.generate(9, (_) => List.filled(9, 0));
        grid[0][0] = 5;
        final board = Board.fromGrid(grid);

        // Act & Assert - Try to place 5 in same box
        expect(board.isValidMove(2, 2, 5),
            isFalse); // Bottom-right of top-left box
      });

      test('should allow same number in different boxes', () {
        // Arrange
        final board = Board.empty();

        // Act
        final board1 = board.setCell(0, 0, 5); // Top-left box
        final board2 = board1.setCell(3, 3, 5); // Middle box

        // Assert
        expect(board2.isValidMove(6, 6, 5), isTrue); // Bottom-right box
      });

      test('should maintain immutability through multiple setCell calls', () {
        // Arrange
        final original = Board.empty();

        // Act
        final board1 = original.setCell(0, 0, 1);
        final board2 = board1.setCell(1, 1, 2);
        final board3 = board2.setCell(2, 2, 3);

        // Assert
        expect(original.cells[0][0].value, equals(0));
        expect(board1.cells[0][0].value, equals(1));
        expect(board1.cells[1][1].value, equals(0));
        expect(board2.cells[1][1].value, equals(2));
        expect(board3.cells[2][2].value, equals(3));
      });
    });
  });
}
