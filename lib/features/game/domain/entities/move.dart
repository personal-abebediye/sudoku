import 'package:equatable/equatable.dart';

/// Represents a single move in the Sudoku game
/// Tracks the position and value change for undo/redo functionality
class Move extends Equatable {
  /// Creates a move with the given position and value change
  const Move({
    required this.row,
    required this.col,
    required this.oldValue,
    required this.newValue,
  });

  /// Row index (0-8) of the cell
  final int row;

  /// Column index (0-8) of the cell
  final int col;

  /// Previous value before this move (0 if cell was empty)
  final int oldValue;

  /// New value after this move (0 if cell was cleared)
  final int newValue;

  @override
  List<Object?> get props => [row, col, oldValue, newValue];
}
