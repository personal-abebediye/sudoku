import '../entities/board.dart';
import '../entities/hint.dart';

/// Service for providing hints to the player
class HintService {
  /// Calculate valid candidate numbers for a specific cell
  Set<int> calculateCandidates(Board board, int row, int col) {
    // If cell is already filled, no candidates
    if (board.cells[row][col].value != 0) {
      return {};
    }

    // Start with all possible numbers
    final candidates = <int>{1, 2, 3, 4, 5, 6, 7, 8, 9};

    // Remove numbers in same row
    for (var c = 0; c < 9; c++) {
      candidates.remove(board.cells[row][c].value);
    }

    // Remove numbers in same column
    for (var r = 0; r < 9; r++) {
      candidates.remove(board.cells[r][col].value);
    }

    // Remove numbers in same 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (var r = boxRow; r < boxRow + 3; r++) {
      for (var c = boxCol; c < boxCol + 3; c++) {
        candidates.remove(board.cells[r][c].value);
      }
    }

    return candidates;
  }

  /// Find the best hint (cell with fewest candidates)
  /// Returns null if board is complete or has no valid hints
  Hint? findBestHint(Board board) {
    Hint? bestHint;
    var minCandidates = 10; // More than maximum possible (9)

    // Scan all cells to find the one with fewest candidates
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        // Skip filled cells
        if (board.cells[row][col].value != 0) {
          continue;
        }

        final candidates = calculateCandidates(board, row, col);

        // Skip if no valid candidates (invalid board state)
        if (candidates.isEmpty) {
          continue;
        }

        // Update best hint if this cell has fewer candidates
        if (candidates.length < minCandidates) {
          minCandidates = candidates.length;
          bestHint = Hint(
            row: row,
            col: col,
            candidates: candidates,
          );

          // If we found a cell with only one candidate, return immediately
          if (minCandidates == 1) {
            return bestHint;
          }
        }
      }
    }

    return bestHint;
  }
}
