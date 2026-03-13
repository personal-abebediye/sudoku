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

  /// Checks if a row is valid (no duplicate non-zero values)
  bool isRowValid(int row) {
    final values = <int>{};
    for (final cell in cells[row]) {
      if (cell.value != 0) {
        if (values.contains(cell.value)) {
          return false;
        }
        values.add(cell.value);
      }
    }
    return true;
  }

  /// Checks if a column is valid (no duplicate non-zero values)
  bool isColumnValid(int col) {
    final values = <int>{};
    for (var row = 0; row < AppConstants.boardSize; row++) {
      final cell = cells[row][col];
      if (cell.value != 0) {
        if (values.contains(cell.value)) {
          return false;
        }
        values.add(cell.value);
      }
    }
    return true;
  }

  /// Checks if a 3x3 box is valid (no duplicate non-zero values)
  /// [row] and [col] can be any cell within the box
  bool isBoxValid(int row, int col) {
    final boxStartRow = (row ~/ AppConstants.boxSize) * AppConstants.boxSize;
    final boxStartCol = (col ~/ AppConstants.boxSize) * AppConstants.boxSize;

    final values = <int>{};
    for (var r = boxStartRow; r < boxStartRow + AppConstants.boxSize; r++) {
      for (var c = boxStartCol; c < boxStartCol + AppConstants.boxSize; c++) {
        final cell = cells[r][c];
        if (cell.value != 0) {
          if (values.contains(cell.value)) {
            return false;
          }
          values.add(cell.value);
        }
      }
    }
    return true;
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

    // Check if value exists in row
    for (var c = 0; c < AppConstants.boardSize; c++) {
      if (c != col && cells[row][c].value == value) {
        return false;
      }
    }

    // Check if value exists in column
    for (var r = 0; r < AppConstants.boardSize; r++) {
      if (r != row && cells[r][col].value == value) {
        return false;
      }
    }

    // Check if value exists in box
    final boxStartRow = (row ~/ AppConstants.boxSize) * AppConstants.boxSize;
    final boxStartCol = (col ~/ AppConstants.boxSize) * AppConstants.boxSize;
    for (var r = boxStartRow; r < boxStartRow + AppConstants.boxSize; r++) {
      for (var c = boxStartCol; c < boxStartCol + AppConstants.boxSize; c++) {
        if ((r != row || c != col) && cells[r][c].value == value) {
          return false;
        }
      }
    }

    return true;
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

  /// The 9x9 grid of cells
  final List<List<Cell>> cells;

  @override
  List<Object?> get props => [cells];
}
