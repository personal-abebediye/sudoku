import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/entities/move.dart';
import 'package:sudoku/features/game/domain/entities/move_history.dart';

void main() {
  group('MoveHistory', () {
    late MoveHistory history;

    setUp(() {
      history = MoveHistory();
    });

    test('should start with empty stacks', () {
      expect(history.canUndo, isFalse);
      expect(history.canRedo, isFalse);
    });

    test('should push move to undo stack', () {
      const move = Move(row: 0, col: 0, oldValue: 0, newValue: 5);
      
      history.push(move);

      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);
    });

    test('should undo last move', () {
      const move = Move(row: 1, col: 2, oldValue: 0, newValue: 7);
      
      history.push(move);
      final undoneMove = history.undo();

      expect(undoneMove, equals(move));
      expect(history.canUndo, isFalse);
      expect(history.canRedo, isTrue);
    });

    test('should redo undone move', () {
      const move = Move(row: 3, col: 4, oldValue: 5, newValue: 8);
      
      history.push(move);
      history.undo();
      final redoneMove = history.redo();

      expect(redoneMove, equals(move));
      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);
    });

    test('should return null when undoing empty stack', () {
      final result = history.undo();

      expect(result, isNull);
      expect(history.canUndo, isFalse);
    });

    test('should return null when redoing empty stack', () {
      final result = history.redo();

      expect(result, isNull);
      expect(history.canRedo, isFalse);
    });

    test('should clear redo stack when pushing new move after undo', () {
      const move1 = Move(row: 0, col: 0, oldValue: 0, newValue: 1);
      const move2 = Move(row: 1, col: 1, oldValue: 0, newValue: 2);
      const move3 = Move(row: 2, col: 2, oldValue: 0, newValue: 3);

      history.push(move1);
      history.push(move2);
      history.undo(); // move2 in redo stack
      
      expect(history.canRedo, isTrue);
      
      history.push(move3); // Should clear redo stack
      
      expect(history.canRedo, isFalse);
      expect(history.canUndo, isTrue);
    });

    test('should handle multiple undo operations', () {
      const move1 = Move(row: 0, col: 0, oldValue: 0, newValue: 1);
      const move2 = Move(row: 1, col: 1, oldValue: 0, newValue: 2);
      const move3 = Move(row: 2, col: 2, oldValue: 0, newValue: 3);

      history.push(move1);
      history.push(move2);
      history.push(move3);

      expect(history.undo(), equals(move3));
      expect(history.undo(), equals(move2));
      expect(history.undo(), equals(move1));
      expect(history.canUndo, isFalse);
    });

    test('should handle multiple redo operations', () {
      const move1 = Move(row: 0, col: 0, oldValue: 0, newValue: 1);
      const move2 = Move(row: 1, col: 1, oldValue: 0, newValue: 2);

      history.push(move1);
      history.push(move2);
      history.undo();
      history.undo();

      expect(history.redo(), equals(move1));
      expect(history.redo(), equals(move2));
      expect(history.canRedo, isFalse);
    });

    test('should clear both stacks', () {
      const move1 = Move(row: 0, col: 0, oldValue: 0, newValue: 1);
      const move2 = Move(row: 1, col: 1, oldValue: 0, newValue: 2);

      history.push(move1);
      history.push(move2);
      history.undo();

      expect(history.canUndo, isTrue);
      expect(history.canRedo, isTrue);

      history.clear();

      expect(history.canUndo, isFalse);
      expect(history.canRedo, isFalse);
    });

    test('should respect max size limit', () {
      final limitedHistory = MoveHistory(maxSize: 3);

      const move1 = Move(row: 0, col: 0, oldValue: 0, newValue: 1);
      const move2 = Move(row: 1, col: 1, oldValue: 0, newValue: 2);
      const move3 = Move(row: 2, col: 2, oldValue: 0, newValue: 3);
      const move4 = Move(row: 3, col: 3, oldValue: 0, newValue: 4);

      limitedHistory.push(move1);
      limitedHistory.push(move2);
      limitedHistory.push(move3);
      limitedHistory.push(move4); // Should remove move1

      // Undo all moves
      expect(limitedHistory.undo(), equals(move4));
      expect(limitedHistory.undo(), equals(move3));
      expect(limitedHistory.undo(), equals(move2));
      expect(limitedHistory.canUndo, isFalse); // move1 was dropped
    });

    test('should handle alternating undo/redo operations', () {
      const move = Move(row: 0, col: 0, oldValue: 0, newValue: 5);

      history.push(move);
      
      history.undo();
      expect(history.canUndo, isFalse);
      expect(history.canRedo, isTrue);
      
      history.redo();
      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);
      
      history.undo();
      expect(history.canUndo, isFalse);
      expect(history.canRedo, isTrue);
    });
  });
}
