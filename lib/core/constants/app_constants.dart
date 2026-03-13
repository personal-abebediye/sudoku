/// Application-wide constants for the Sudoku game.
class AppConstants {
  AppConstants._();

  /// Standard Sudoku board size (9x9).
  static const int boardSize = 9;

  /// Size of each 3x3 box in Sudoku.
  static const int boxSize = 3;

  /// Available difficulty levels.
  static const List<String> difficultyLevels = [
    'Easy',
    'Medium',
    'Hard',
    'Expert',
  ];
}
