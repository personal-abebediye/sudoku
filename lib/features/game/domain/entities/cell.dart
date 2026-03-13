import 'package:equatable/equatable.dart';

/// Represents a single cell in the Sudoku board
class Cell extends Equatable {
  /// Creates a cell with the given value and fixed state
  const Cell({
    required this.value,
    required this.isFixed,
  }) : assert(value >= 0 && value <= 9, 'Cell value must be between 0 and 9');

  /// The value of the cell (0 = empty, 1-9 = filled)
  final int value;

  /// Whether this cell is part of the initial puzzle (fixed/given)
  final bool isFixed;

  /// Returns true if the cell is empty (value is 0)
  bool get isEmpty => value == 0;

  /// Creates a copy of this cell with optional updated values
  Cell copyWith({
    int? value,
    bool? isFixed,
  }) =>
      Cell(
        value: value ?? this.value,
        isFixed: isFixed ?? this.isFixed,
      );

  @override
  List<Object?> get props => [value, isFixed];
}
