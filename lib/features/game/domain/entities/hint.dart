/// Represents a hint for a specific cell with possible candidate values
class Hint {
  const Hint({
    required this.row,
    required this.col,
    required this.candidates,
  });

  final int row;
  final int col;
  final Set<int> candidates;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hint &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Hint(row: $row, col: $col, candidates: $candidates)';
}
