import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('should have correct board size', () {
      // Arrange & Act
      const boardSize = AppConstants.boardSize;

      // Assert
      expect(boardSize, 9);
    });

    test('should have correct box size', () {
      // Arrange & Act
      const boxSize = AppConstants.boxSize;

      // Assert
      expect(boxSize, 3);
    });

    test('should have valid difficulty levels', () {
      // Arrange & Act
      const difficulties = AppConstants.difficultyLevels;

      // Assert
      expect(difficulties, isNotEmpty);
      expect(difficulties, contains('Easy'));
      expect(difficulties, contains('Medium'));
      expect(difficulties, contains('Hard'));
      expect(difficulties, contains('Expert'));
    });
  });
}
