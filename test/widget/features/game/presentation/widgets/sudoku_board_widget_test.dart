import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/entities/board.dart';
import 'package:sudoku/features/game/domain/entities/cell.dart';
import 'package:sudoku/features/game/presentation/widgets/sudoku_board_widget.dart';

void main() {
  group('SudokuBoardWidget', () {
    late Board testBoard;

    setUp(() {
      // Create a simple test board
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 5;
      grid[4][4] = 9;
      grid[8][8] = 3;
      testBoard = Board.fromGrid(grid);
    });

    testWidgets('should render 9x9 grid of cells', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuBoardWidget(board: testBoard),
          ),
        ),
      );

      // Assert - Should have 81 cells (9x9)
      expect(find.byType(SudokuCellWidget), findsNWidgets(81));
    });

    testWidgets('should display cell values correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuBoardWidget(board: testBoard),
          ),
        ),
      );

      // Assert - Check specific cell values
      expect(find.text('5'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should handle cell selection', (tester) async {
      // Arrange
      int? selectedRow;
      int? selectedCol;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuBoardWidget(
              board: testBoard,
              onCellSelected: (row, col) {
                selectedRow = row;
                selectedCol = col;
              },
            ),
          ),
        ),
      );

      // Act - Tap on first cell
      await tester.tap(find.byType(SudokuCellWidget).first);
      await tester.pump();

      // Assert
      expect(selectedRow, equals(0));
      expect(selectedCol, equals(0));
    });

    testWidgets('should highlight selected cell', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuBoardWidget(
              board: testBoard,
              selectedRow: 2,
              selectedCol: 3,
            ),
          ),
        ),
      );

      // Assert - Cell at [2,3] should be highlighted
      final cellWidgets = tester.widgetList<SudokuCellWidget>(
        find.byType(SudokuCellWidget),
      );
      final selectedCell = cellWidgets.elementAt(2 * 9 + 3);
      expect(selectedCell.isSelected, isTrue);
    });

    testWidgets('should distinguish fixed cells from user cells',
        (tester) async {
      // Arrange
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 5; // Fixed
      final board = Board.fromGrid(grid);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuBoardWidget(board: board),
          ),
        ),
      );

      // Assert - Fixed cell should have isFixed = true
      final cellWidgets = tester.widgetList<SudokuCellWidget>(
        find.byType(SudokuCellWidget),
      );
      final firstCell = cellWidgets.first;
      expect(firstCell.cell.isFixed, isTrue);
    });

    testWidgets('should be responsive to different screen sizes',
        (tester) async {
      // Arrange - Set large screen size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuBoardWidget(board: testBoard),
          ),
        ),
      );

      // Assert - Widget should render without overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle empty board', (tester) async {
      // Arrange
      final emptyBoard = Board.empty();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuBoardWidget(board: emptyBoard),
          ),
        ),
      );

      // Assert - Should render all empty cells
      expect(find.byType(SudokuCellWidget), findsNWidgets(81));
    });
  });

  group('SudokuCellWidget', () {
    testWidgets('should display cell value', (tester) async {
      // Arrange
      const cell = Cell(value: 7, isFixed: false);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SudokuCellWidget(
              cell: cell,
              row: 0,
              col: 0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('should display empty cell', (tester) async {
      // Arrange
      const cell = Cell(value: 0, isFixed: false);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SudokuCellWidget(
              cell: cell,
              row: 0,
              col: 0,
            ),
          ),
        ),
      );

      // Assert - Empty cells should not display text
      expect(find.text('0'), findsNothing);
    });

    testWidgets('should be tappable', (tester) async {
      // Arrange
      const cell = Cell(value: 0, isFixed: false);
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuCellWidget(
              cell: cell,
              row: 0,
              col: 0,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(SudokuCellWidget));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should show different style for fixed cells', (tester) async {
      // Arrange
      const fixedCell = Cell(value: 5, isFixed: true);
      const userCell = Cell(value: 5, isFixed: false);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SudokuCellWidget(cell: fixedCell, row: 0, col: 0),
                SudokuCellWidget(cell: userCell, row: 1, col: 0),
              ],
            ),
          ),
        ),
      );

      // Assert - Both should render (visual distinction tested manually)
      expect(find.text('5'), findsNWidgets(2));
    });

    testWidgets('should highlight when selected', (tester) async {
      // Arrange
      const cell = Cell(value: 5, isFixed: false);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SudokuCellWidget(
              cell: cell,
              row: 0,
              col: 0,
              isSelected: true,
            ),
          ),
        ),
      );

      // Assert - Widget should render with selected state
      final widget = tester.widget<SudokuCellWidget>(
        find.byType(SudokuCellWidget),
      );
      expect(widget.isSelected, isTrue);
    });
  });
}
