import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/entities/cell_notes.dart';

void main() {
  group('CellNotes', () {
    test('creates empty notes by default', () {
      final notes = CellNotes();
      
      expect(notes.isEmpty, true);
      expect(notes.values, isEmpty);
    });

    test('adds single note', () {
      final notes = CellNotes()..add(5);
      
      expect(notes.contains(5), true);
      expect(notes.values, {5});
    });

    test('adds multiple notes', () {
      final notes = CellNotes()
        ..add(1)
        ..add(5)
        ..add(9);
      
      expect(notes.values, {1, 5, 9});
      expect(notes.contains(1), true);
      expect(notes.contains(5), true);
      expect(notes.contains(9), true);
    });

    test('prevents duplicate notes', () {
      final notes = CellNotes()
        ..add(3)
        ..add(3)
        ..add(3);
      
      expect(notes.values, {3});
    });

    test('removes note', () {
      final notes = CellNotes()
        ..add(2)
        ..add(4)
        ..add(6)
        ..remove(4);
      
      expect(notes.values, {2, 6});
      expect(notes.contains(4), false);
    });

    test('toggle adds note if not present', () {
      final notes = CellNotes()..toggle(7);
      
      expect(notes.contains(7), true);
    });

    test('toggle removes note if present', () {
      final notes = CellNotes()
        ..add(7)
        ..toggle(7);
      
      expect(notes.contains(7), false);
    });

    test('clears all notes', () {
      final notes = CellNotes()
        ..add(1)
        ..add(5)
        ..add(9)
        ..clear();
      
      expect(notes.isEmpty, true);
      expect(notes.values, isEmpty);
    });

    test('validates number range (1-9 only)', () {
      expect(() => CellNotes()..add(0), throwsArgumentError);
      expect(() => CellNotes()..add(10), throwsArgumentError);
      expect(() => CellNotes()..add(-1), throwsArgumentError);
    });

    test('allows all valid numbers (1-9)', () {
      final notes = CellNotes();
      for (var i = 1; i <= 9; i++) {
        notes.add(i);
      }
      
      expect(notes.values, {1, 2, 3, 4, 5, 6, 7, 8, 9});
    });

    test('removing non-existent note is no-op', () {
      final notes = CellNotes()
        ..add(5)
        ..remove(3);
      
      expect(notes.values, {5});
    });

    test('contains returns false for non-existent note', () {
      final notes = CellNotes()..add(5);
      
      expect(notes.contains(3), false);
    });
  });
}
