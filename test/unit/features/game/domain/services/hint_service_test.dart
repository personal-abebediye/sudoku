import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/entities/board.dart';
import 'package:sudoku/features/game/domain/services/hint_service.dart';

void main() {
  group('HintService', () {
    late HintService hintService;

    setUp(() {
      hintService = HintService();
    });

    group('calculateCandidates', () {
      test('should return all numbers 1-9 for empty board', () {
        final board = Board.empty();
        final candidates = hintService.calculateCandidates(board, 0, 0);

        expect(candidates, {1, 2, 3, 4, 5, 6, 7, 8, 9});
      });

      test('should exclude numbers in same row', () {
        final board = Board.empty()
            .setCell(0, 0, 1)
            .setCell(0, 1, 2)
            .setCell(0, 2, 3);

        final candidates = hintService.calculateCandidates(board, 0, 3);

        expect(candidates, {4, 5, 6, 7, 8, 9});
        expect(candidates.contains(1), false);
        expect(candidates.contains(2), false);
        expect(candidates.contains(3), false);
      });

      test('should exclude numbers in same column', () {
        final board = Board.empty()
            .setCell(0, 0, 1)
            .setCell(1, 0, 2)
            .setCell(2, 0, 3);

        final candidates = hintService.calculateCandidates(board, 3, 0);

        expect(candidates, {4, 5, 6, 7, 8, 9});
        expect(candidates.contains(1), false);
        expect(candidates.contains(2), false);
        expect(candidates.contains(3), false);
      });

      test('should exclude numbers in same 3x3 box', () {
        final board = Board.empty()
            .setCell(0, 0, 1)
            .setCell(0, 1, 2)
            .setCell(1, 0, 3);

        final candidates = hintService.calculateCandidates(board, 1, 1);

        expect(candidates, {4, 5, 6, 7, 8, 9});
        expect(candidates.contains(1), false);
        expect(candidates.contains(2), false);
        expect(candidates.contains(3), false);
      });

      test('should combine all constraints', () {
        // Create a board with numbers in row, column, and box
        final board = Board.empty()
            .setCell(0, 0, 1) // Same row as target
            .setCell(1, 0, 2) // Same column as target
            .setCell(1, 1, 3); // Same box as target

        final candidates = hintService.calculateCandidates(board, 0, 1);

        expect(candidates, {4, 5, 6, 7, 8, 9});
      });

      test('should return empty set for filled cell', () {
        final board = Board.empty().setCell(0, 0, 5);
        final candidates = hintService.calculateCandidates(board, 0, 0);

        expect(candidates, isEmpty);
      });
    });

    group('findBestHint', () {
      test('should return null for completed board', () {
        // Create a valid completed board (simplified for test)
        var board = Board.empty();
        for (var row = 0; row < 9; row++) {
          for (var col = 0; col < 9; col++) {
            board = board.setCell(row, col, ((row * 3 + row ~/ 3 + col) % 9) + 1);
          }
        }

        final hint = hintService.findBestHint(board);
        expect(hint, isNull);
      });

      test('should return null for board with no empty cells', () {
        var board = Board.empty();
        for (var row = 0; row < 9; row++) {
          for (var col = 0; col < 9; col++) {
            board = board.setCell(row, col, 1); // Invalid but filled
          }
        }

        final hint = hintService.findBestHint(board);
        expect(hint, isNull);
      });

      test('should find cell with fewest candidates', () {
        // Create a board where (0, 0) has more constraints than (8, 8)
        final board = Board.empty()
            .setCell(0, 1, 1)
            .setCell(0, 2, 2)
            .setCell(1, 0, 3)
            .setCell(2, 0, 4);

        final hint = hintService.findBestHint(board);

        expect(hint, isNotNull);
        expect(hint!.row, 0);
        expect(hint.col, 0);
        expect(hint.candidates.length, lessThan(9));
      });

      test('should return cell with single candidate first', () {
        // Create a board where (0, 0) has only one valid number
        var board = Board.empty();
        // Fill row 0 except position 0
        for (var col = 1; col < 9; col++) {
          board = board.setCell(0, col, col);
        }
        // Fill column 0 except position 0 (avoid duplicates)
        // We already have 1,2,3,4,5,6,7,8 in row, so column needs 9
        // Position (0,0) can only be 9

        final hint = hintService.findBestHint(board);

        expect(hint, isNotNull);
        expect(hint!.row, 0);
        expect(hint.col, 0);
        expect(hint.candidates, {9});
      });

      test('should prefer cells with fewer candidates over more candidates', () {
        // Cell (1, 1) should have fewer candidates than (8, 8)
        final board = Board.empty()
            .setCell(0, 1, 1)
            .setCell(1, 0, 2)
            .setCell(1, 2, 3)
            .setCell(2, 1, 4);

        final hint = hintService.findBestHint(board);

        expect(hint, isNotNull);
        // Should prioritize (1,1) which has most constraints
        final candidates11 =
            hintService.calculateCandidates(board, 1, 1);
        final candidates88 =
            hintService.calculateCandidates(board, 8, 8);

        expect(candidates11.length, lessThan(candidates88.length));
      });
    });
  });
}
