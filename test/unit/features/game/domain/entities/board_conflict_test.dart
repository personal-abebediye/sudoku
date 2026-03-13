import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/entities/board.dart';

void main() {
  group('Board conflict detection', () {
    test('should detect conflict in same row', () {
      // Arrange - Board with duplicate 5 in row 0
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 5;
      grid[0][5] = 5; // Duplicate
      final board = Board.fromGrid(grid);

      // Act & Assert
      expect(board.hasConflict(0, 0), isTrue);
      expect(board.hasConflict(0, 5), isTrue);
    });

    test('should detect conflict in same column', () {
      // Arrange - Board with duplicate 7 in column 3
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[2][3] = 7;
      grid[7][3] = 7; // Duplicate
      final board = Board.fromGrid(grid);

      // Act & Assert
      expect(board.hasConflict(2, 3), isTrue);
      expect(board.hasConflict(7, 3), isTrue);
    });

    test('should detect conflict in same 3x3 box', () {
      // Arrange - Board with duplicate 9 in top-left box
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 9;
      grid[2][2] = 9; // Duplicate in same box
      final board = Board.fromGrid(grid);

      // Act & Assert
      expect(board.hasConflict(0, 0), isTrue);
      expect(board.hasConflict(2, 2), isTrue);
    });

    test('should return false for empty cells', () {
      // Arrange
      final board = Board.empty();

      // Act & Assert
      expect(board.hasConflict(0, 0), isFalse);
      expect(board.hasConflict(4, 4), isFalse);
    });

    test('should return false for valid placement', () {
      // Arrange - Board with no conflicts
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 1;
      grid[0][1] = 2;
      grid[1][0] = 3;
      final board = Board.fromGrid(grid);

      // Act & Assert
      expect(board.hasConflict(0, 0), isFalse);
      expect(board.hasConflict(0, 1), isFalse);
      expect(board.hasConflict(1, 0), isFalse);
    });

    test('should detect multiple conflicts for same cell', () {
      // Arrange - Cell has conflicts in row, column, AND box
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 5;
      grid[0][8] = 5; // Same row
      grid[8][0] = 5; // Same column
      grid[2][2] = 5; // Same box
      final board = Board.fromGrid(grid);

      // Act & Assert - All should be detected as conflicts
      expect(board.hasConflict(0, 0), isTrue);
    });

    test('should not flag fixed cells as conflicts with themselves', () {
      // Arrange - Valid puzzle with fixed cells
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 5;
      final board = Board.fromGrid(grid);

      // Act & Assert - Cell shouldn't conflict with itself
      expect(board.hasConflict(0, 0), isFalse);
    });

    test('should detect conflict after user input', () {
      // Arrange - Start with valid board
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 5;
      var board = Board.fromGrid(grid);

      // Act - User adds conflicting number
      board = board.setCell(0, 5, 5);

      // Assert
      expect(board.hasConflict(0, 0), isTrue);
      expect(board.hasConflict(0, 5), isTrue);
    });

    test('should work with complete valid solution', () {
      // Arrange - Complete valid Sudoku
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

      // Act & Assert - No conflicts in valid solution
      for (var row = 0; row < 9; row++) {
        for (var col = 0; col < 9; col++) {
          expect(board.hasConflict(row, col), isFalse);
        }
      }
    });

    test('should detect conflict in middle box', () {
      // Arrange
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[4][4] = 8; // Center cell
      grid[3][5] = 8; // Same middle box
      final board = Board.fromGrid(grid);

      // Act & Assert
      expect(board.hasConflict(4, 4), isTrue);
      expect(board.hasConflict(3, 5), isTrue);
    });
  });
}
