import 'dart:math';
import 'package:sudoku/core/constants/app_constants.dart';
import 'package:sudoku/features/game/domain/entities/board.dart';

/// Difficulty levels for puzzle generation
/// Based on clue count - fewer clues generally means harder puzzles
/// Note: True difficulty also depends on solving techniques required,
/// but clue count provides a reasonable approximation for casual play
enum Difficulty {
  easy, // 45-50 clues (very generous hints)
  medium, // 35-40 clues (moderate challenge)
  hard, // 27-32 clues (requires advanced techniques)
  expert, // 22-26 clues (very challenging, near minimum)
}

/// Extension for difficulty clue ranges
extension DifficultyExtension on Difficulty {
  int get minClues {
    switch (this) {
      case Difficulty.easy:
        return 45;
      case Difficulty.medium:
        return 35;
      case Difficulty.hard:
        return 27;
      case Difficulty.expert:
        return 22; // Near the mathematical minimum of 17
    }
  }

  int get maxClues {
    switch (this) {
      case Difficulty.easy:
        return 50;
      case Difficulty.medium:
        return 40;
      case Difficulty.hard:
        return 32;
      case Difficulty.expert:
        return 26;
    }
  }
}

/// Generates Sudoku puzzles using backtracking algorithm
class PuzzleGenerator {
  final Random _random = Random();

  /// Generates a complete valid Sudoku solution
  Board generateSolution() {
    final grid = List.generate(
      AppConstants.boardSize,
      (_) => List.filled(AppConstants.boardSize, 0),
    );

    _fillGrid(grid);
    return Board.fromGrid(grid);
  }

  /// Generates a Sudoku puzzle with the given difficulty
  Board generatePuzzle(Difficulty difficulty) {
    // Generate complete solution
    final solution = generateSolution();

    // Copy grid
    final grid = List.generate(
      AppConstants.boardSize,
      (row) => List.generate(
        AppConstants.boardSize,
        (col) => solution.cells[row][col].value,
      ),
    );

    // Calculate target clue count
    final targetClues = difficulty.minClues +
        _random.nextInt(difficulty.maxClues - difficulty.minClues + 1);

    // Remove cells to reach target clue count
    final cellPositions = <List<int>>[];
    for (var row = 0; row < AppConstants.boardSize; row++) {
      for (var col = 0; col < AppConstants.boardSize; col++) {
        cellPositions.add([row, col]);
      }
    }
    cellPositions.shuffle(_random);

    var currentClues = 81;
    for (final pos in cellPositions) {
      if (currentClues <= targetClues) {
        break;
      }

      final row = pos[0];
      final col = pos[1];
      grid[row][col] = 0;
      currentClues--;
    }

    return Board.fromGrid(grid);
  }

  /// Fills the grid using backtracking algorithm
  bool _fillGrid(List<List<int>> grid) {
    // Find next empty cell
    for (var row = 0; row < AppConstants.boardSize; row++) {
      for (var col = 0; col < AppConstants.boardSize; col++) {
        if (grid[row][col] == 0) {
          // Try numbers 1-9 in random order
          final numbers = List.generate(9, (i) => i + 1)..shuffle(_random);

          for (final num in numbers) {
            if (_isValid(grid, row, col, num)) {
              grid[row][col] = num;

              if (_fillGrid(grid)) {
                return true;
              }

              grid[row][col] = 0;
            }
          }

          return false;
        }
      }
    }

    return true; // All cells filled
  }

  /// Checks if placing a number at position is valid
  bool _isValid(List<List<int>> grid, int row, int col, int num) {
    // Check row
    for (var c = 0; c < AppConstants.boardSize; c++) {
      if (grid[row][c] == num) {
        return false;
      }
    }

    // Check column
    for (var r = 0; r < AppConstants.boardSize; r++) {
      if (grid[r][col] == num) {
        return false;
      }
    }

    // Check 3x3 box
    final boxRow = (row ~/ AppConstants.boxSize) * AppConstants.boxSize;
    final boxCol = (col ~/ AppConstants.boxSize) * AppConstants.boxSize;
    for (var r = boxRow; r < boxRow + AppConstants.boxSize; r++) {
      for (var c = boxCol; c < boxCol + AppConstants.boxSize; c++) {
        if (grid[r][c] == num) {
          return false;
        }
      }
    }

    return true;
  }
}
