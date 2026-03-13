import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/entities/move.dart';

void main() {
  group('Move', () {
    test('should create a move with valid values', () {
      const move = Move(
        row: 0,
        col: 0,
        oldValue: 0,
        newValue: 5,
      );

      expect(move.row, equals(0));
      expect(move.col, equals(0));
      expect(move.oldValue, equals(0));
      expect(move.newValue, equals(5));
    });

    test('should support equality comparison', () {
      const move1 = Move(row: 2, col: 3, oldValue: 1, newValue: 7);
      const move2 = Move(row: 2, col: 3, oldValue: 1, newValue: 7);
      const move3 = Move(row: 2, col: 3, oldValue: 1, newValue: 8);

      expect(move1, equals(move2));
      expect(move1, isNot(equals(move3)));
    });

    test('should handle clearing a cell (newValue = 0)', () {
      const move = Move(row: 5, col: 5, oldValue: 9, newValue: 0);

      expect(move.oldValue, equals(9));
      expect(move.newValue, equals(0));
    });

    test('should handle changing an existing value', () {
      const move = Move(row: 4, col: 6, oldValue: 3, newValue: 7);

      expect(move.oldValue, equals(3));
      expect(move.newValue, equals(7));
    });
  });
}
