/// Manages pencil marks (candidate numbers) for a Sudoku cell.
///
/// CellNotes stores a set of numbers (1-9) that represent possible
/// candidates for an empty cell. This is commonly used as a solving aid.
class CellNotes {
  final Set<int> _notes = {};

  /// Returns true if no notes are present.
  bool get isEmpty => _notes.isEmpty;

  /// Returns an unmodifiable view of the current notes.
  Set<int> get values => Set.unmodifiable(_notes);

  /// Adds a note to the cell.
  ///
  /// Throws [ArgumentError] if [value] is not in the range 1-9.
  void add(int value) {
    _validateNumber(value);
    _notes.add(value);
  }

  /// Removes a note from the cell.
  ///
  /// If the note doesn't exist, this is a no-op.
  void remove(int value) {
    _notes.remove(value);
  }

  /// Toggles a note: adds it if not present, removes it if present.
  void toggle(int value) {
    _validateNumber(value);
    if (_notes.contains(value)) {
      _notes.remove(value);
    } else {
      _notes.add(value);
    }
  }

  /// Checks if a specific note is present.
  bool contains(int value) => _notes.contains(value);

  /// Clears all notes.
  void clear() {
    _notes.clear();
  }

  /// Validates that a number is in the valid range (1-9).
  void _validateNumber(int value) {
    if (value < 1 || value > 9) {
      throw ArgumentError('Note value must be between 1 and 9, got $value');
    }
  }
}
