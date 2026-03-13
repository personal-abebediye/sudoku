import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/entities/cell.dart';

void main() {
  group('Cell', () {
    group('creation', () {
      test('should create a cell with valid value', () {
        // Arrange & Act
        const cell = Cell(value: 5, isFixed: false);

        // Assert
        expect(cell.value, equals(5));
        expect(cell.isFixed, isFalse);
        expect(cell.isEmpty, isFalse);
      });

      test('should create an empty cell with value 0', () {
        // Arrange & Act
        const cell = Cell(value: 0, isFixed: false);

        // Assert
        expect(cell.value, equals(0));
        expect(cell.isEmpty, isTrue);
      });

      test('should create a fixed cell', () {
        // Arrange & Act
        const cell = Cell(value: 7, isFixed: true);

        // Assert
        expect(cell.value, equals(7));
        expect(cell.isFixed, isTrue);
      });
    });

    group('validation', () {
      test('should accept values between 0 and 9', () {
        // Arrange & Act & Assert
        for (var i = 0; i <= 9; i++) {
          expect(() => Cell(value: i, isFixed: false), returnsNormally);
        }
      });

      test('should throw assertion error for value < 0', () {
        // Arrange & Act & Assert
        expect(
          () => Cell(value: -1, isFixed: false),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should throw assertion error for value > 9', () {
        // Arrange & Act & Assert
        expect(
          () => Cell(value: 10, isFixed: false),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        const cell1 = Cell(value: 5, isFixed: true);
        const cell2 = Cell(value: 5, isFixed: true);

        // Act & Assert
        expect(cell1, equals(cell2));
        expect(cell1.hashCode, equals(cell2.hashCode));
      });

      test('should not be equal when value differs', () {
        // Arrange
        const cell1 = Cell(value: 5, isFixed: true);
        const cell2 = Cell(value: 6, isFixed: true);

        // Act & Assert
        expect(cell1, isNot(equals(cell2)));
      });

      test('should not be equal when isFixed differs', () {
        // Arrange
        const cell1 = Cell(value: 5, isFixed: true);
        const cell2 = Cell(value: 5, isFixed: false);

        // Act & Assert
        expect(cell1, isNot(equals(cell2)));
      });
    });

    group('copyWith', () {
      test('should create a new cell with updated value', () {
        // Arrange
        const original = Cell(value: 5, isFixed: false);

        // Act
        final updated = original.copyWith(value: 8);

        // Assert
        expect(updated.value, equals(8));
        expect(updated.isFixed, equals(original.isFixed));
      });

      test('should create a new cell with updated isFixed', () {
        // Arrange
        const original = Cell(value: 5, isFixed: false);

        // Act
        final updated = original.copyWith(isFixed: true);

        // Assert
        expect(updated.value, equals(original.value));
        expect(updated.isFixed, isTrue);
      });

      test('should not modify original cell', () {
        // Arrange
        const original = Cell(value: 5, isFixed: false);

        // Act
        final newCell = original.copyWith(value: 8, isFixed: true);

        // Assert
        expect(original.value, equals(5));
        expect(original.isFixed, isFalse);
        expect(newCell.value, equals(8));
        expect(newCell.isFixed, isTrue);
      });
    });
  });
}
