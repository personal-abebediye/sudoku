import 'package:equatable/equatable.dart';
import 'package:sudoku/core/constants/app_constants.dart';
import 'package:sudoku/features/game/domain/entities/cell.dart';

/// Represents a Sudoku board with 9x9 grid
class Board extends Equatable {
  /// Creates a board with the given cells
  const Board({required this.cells});

  /// Creates an empty board with all cells set to 0
  factory Board.empty() => Board(
        cells: List.generate(
          AppConstants.boardSize,
          (_) => List.generate(
            AppConstants.boardSize,
            (_) => const Cell(value: 0, isFixed: false),
          ),
        ),
      );

  /// Creates a board from a 2D grid of integers
  /// Non-zero values are marked as fixed (given numbers)
  factory Board.fromGrid(List<List<int>> grid) {
    assert(
      grid.length == AppConstants.boardSize,
      'Grid must have ${AppConstants.boardSize} rows',
    );
    assert(
      grid.every((row) => row.length == AppConstants.boardSize),
      'All rows must have ${AppConstants.boardSize} columns',
    );

    return Board(
      cells: List.generate(
        AppConstants.boardSize,
        (row) => List.generate(
          AppConstants.boardSize,
          (col) {
            final value = grid[row][col];
            return Cell(value: value, isFixed: value != 0);
          },
        ),
      ),
    );
  }

  /// Core validation logic: checks if a list of cells has no duplicate non-zero values
  /// This is the foundation for row, column, and box validation
  bool _isRegionValid(Iterable<Cell> cells) {
    final values = <int>{};
    for (final cell in cells) {
      if (cell.value != 0) {
        if (values.contains(cell.value)) {
          return false;
        }
        values.add(cell.value);
      }
    }
    return true;
  }

  /// Extracts all cells in a given row
  Iterable<Cell> _getRowCells(int row) => cells[row];

  /// Extracts all cells in a given column
  Iterable<Cell> _getColumnCells(int col) => cells.map((row) => row[col]);

  /// Calculates the starting coordinates of a 3x3 box containing the given position
  /// Returns a record with (row, col) representing the top-left cell of the box
  ({int row, int col}) _getBoxStart(int row, int col) => (
        row: (row ~/ AppConstants.boxSize) * AppConstants.boxSize,
        col: (col ~/ AppConstants.boxSize) * AppConstants.boxSize,
      );

  /// Extracts all cells in a 3x3 box containing the given position
  /// Returns cells from the box that contains [row][col]
  Iterable<Cell> _getBoxCells(int row, int col) sync* {
    final boxStart = _getBoxStart(row, col);

    for (var r = boxStart.row; r < boxStart.row + AppConstants.boxSize; r++) {
      for (var c = boxStart.col; c < boxStart.col + AppConstants.boxSize; c++) {
        yield cells[r][c];
      }
    }
  }

  /// Checks if a row is valid (no duplicate non-zero values)
  bool isRowValid(int row) => _isRegionValid(_getRowCells(row));

  /// Checks if a column is valid (no duplicate non-zero values)
  bool isColumnValid(int col) => _isRegionValid(_getColumnCells(col));

  /// Checks if a 3x3 box is valid (no duplicate non-zero values)
  /// [row] and [col] can be any cell within the box
  bool isBoxValid(int row, int col) => _isRegionValid(_getBoxCells(row, col));

  /// Checks if a value conflicts with existing values in row/column/box
  /// Returns true if the value exists in the same row, column, or box
  /// (excluding the cell at [row][col] itself)
  bool _hasValueConflict(int row, int col, int value) {
    // Check if value exists in row (excluding current cell)
    for (var c = 0; c < AppConstants.boardSize; c++) {
      if (c != col && cells[row][c].value == value) {
        return true;
      }
    }

    // Check if value exists in column (excluding current cell)
    for (var r = 0; r < AppConstants.boardSize; r++) {
      if (r != row && cells[r][col].value == value) {
        return true;
      }
    }

    // Check if value exists in box (excluding current cell)
    // Reuses box coordinate calculation from _getBoxStart
    final boxStart = _getBoxStart(row, col);
    for (var r = boxStart.row; r < boxStart.row + AppConstants.boxSize; r++) {
      for (var c = boxStart.col; c < boxStart.col + AppConstants.boxSize; c++) {
        if ((r != row || c != col) && cells[r][c].value == value) {
          return true;
        }
      }
    }

    return false;
  }

  /// Checks if placing a value at the given position is valid
  /// Returns false if:
  /// - The cell is fixed
  /// - The value already exists in the same row, column, or box
  bool isValidMove(int row, int col, int value) {
    // Can't modify fixed cells
    if (cells[row][col].isFixed) {
      return false;
    }

    return !_hasValueConflict(row, col, value);
  }

  /// Creates a new board with the cell at [row][col] set to [value]
  /// Returns the same board if the cell is fixed
  Board setCell(int row, int col, int value) {
    if (cells[row][col].isFixed) {
      return this;
    }

    final newCells = List.generate(
      AppConstants.boardSize,
      (r) => List.generate(
        AppConstants.boardSize,
        (c) => r == row && c == col
            ? cells[r][c].copyWith(value: value)
            : cells[r][c],
      ),
    );

    return Board(cells: newCells);
  }

  /// Checks if the cell at [row][col] has a conflict
  /// Returns true if the same non-zero value appears in the same row, column, or box
  /// Reuses the conflict detection logic from isValidMove
  bool hasConflict(int row, int col) {
    final value = cells[row][col].value;

    // Empty cells have no conflicts
    if (value == 0) {
      return false;
    }

    // Check if this value would conflict (reuses _hasValueConflict logic)
    return _hasValueConflict(row, col, value);
  }

  /// The 9x9 grid of cells
  final List<List<Cell>> cells;

  @override
  List<Object?> get props => [cells];
}
