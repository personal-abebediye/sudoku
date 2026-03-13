import 'package:flutter/material.dart';
import 'package:sudoku/core/constants/app_constants.dart';
import 'package:sudoku/features/game/domain/entities/board.dart';
import 'package:sudoku/features/game/domain/entities/cell.dart';

/// Widget that displays the 9x9 Sudoku game board
class SudokuBoardWidget extends StatelessWidget {
  const SudokuBoardWidget({
    required this.board,
    this.selectedRow,
    this.selectedCol,
    this.errorCells = const {},
    this.notes = const {},
    this.onCellSelected,
    super.key,
  });

  final Board board;
  final int? selectedRow;
  final int? selectedCol;
  final Set<String>
      errorCells; // Set of "row,col" strings for cells with errors
  final Map<String, Set<int>> notes; // Notes for each cell
  final void Function(int row, int col)? onCellSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate size based on available space
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppConstants.boardSize,
              ),
              itemCount: AppConstants.boardSize * AppConstants.boardSize,
              itemBuilder: (context, index) {
                final row = index ~/ AppConstants.boardSize;
                final col = index % AppConstants.boardSize;
                final cell = board.cells[row][col];
                final isSelected = row == selectedRow && col == selectedCol;
                final hasError = errorCells.contains('$row,$col');
                final cellNotes = notes['$row,$col'] ?? {};

                return SudokuCellWidget(
                  cell: cell,
                  row: row,
                  col: col,
                  isSelected: isSelected,
                  hasError: hasError,
                  notes: cellNotes,
                  onTap: onCellSelected != null
                      ? () => onCellSelected!(row, col)
                      : null,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Widget that displays a single Sudoku cell
class SudokuCellWidget extends StatelessWidget {
  const SudokuCellWidget({
    required this.cell,
    required this.row,
    required this.col,
    this.isSelected = false,
    this.hasError = false,
    this.notes = const {},
    this.onTap,
    super.key,
  });

  final Cell cell;
  final int row;
  final int col;
  final bool isSelected;
  final bool hasError;
  final Set<int> notes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine border thickness for 3x3 box boundaries
    final isTopBorder = row % AppConstants.boxSize == 0;
    final isLeftBorder = col % AppConstants.boxSize == 0;
    final isBottomBorder = row == AppConstants.boardSize - 1;
    final isRightBorder = col == AppConstants.boardSize - 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(colorScheme),
          border: Border(
            top: BorderSide(
              color: colorScheme.outline,
              width: isTopBorder ? 2.0 : 0.5,
            ),
            left: BorderSide(
              color: colorScheme.outline,
              width: isLeftBorder ? 2.0 : 0.5,
            ),
            bottom: BorderSide(
              color: colorScheme.outline,
              width: isBottomBorder ? 2.0 : 0.5,
            ),
            right: BorderSide(
              color: colorScheme.outline,
              width: isRightBorder ? 2.0 : 0.5,
            ),
          ),
        ),
        child: Center(
          child: cell.isEmpty
              ? (notes.isNotEmpty ? _buildNotesGrid(context) : null)
              : Text(
                  '${cell.value}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: cell.isFixed
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight:
                        cell.isFixed ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNotesGrid(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final number = index + 1;
          final hasNote = notes.contains(number);

          return Center(
            child: Text(
              hasNote ? '$number' : '',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withAlpha(178), // 70% opacity
                fontSize: 10,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (hasError) {
      return colorScheme.errorContainer;
    }
    if (isSelected) {
      return colorScheme.primaryContainer;
    }
    return colorScheme.surface;
  }
}
