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
    final theme = Theme.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate size based on available space
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final cellSize = size / AppConstants.boardSize;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Purple 3x3 box backgrounds
                ..._buildBoxBackgrounds(cellSize, theme),
                // Cell grid on top
                GridView.builder(
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

                    // Check if cell is in same row, column, or box as selected cell
                    // (but not the selected cell itself)
                    final isHighlighted = !isSelected &&
                        selectedRow != null &&
                        selectedCol != null &&
                        (row == selectedRow ||
                            col == selectedCol ||
                            (row ~/ AppConstants.boxSize ==
                                    selectedRow! ~/ AppConstants.boxSize &&
                                col ~/ AppConstants.boxSize ==
                                    selectedCol! ~/ AppConstants.boxSize));

                    return SudokuCellWidget(
                      cell: cell,
                      row: row,
                      col: col,
                      isSelected: isSelected,
                      isHighlighted: isHighlighted,
                      hasError: hasError,
                      notes: cellNotes,
                      onTap: onCellSelected != null
                          ? () => onCellSelected!(row, col)
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build purple background containers for each 3x3 box
  List<Widget> _buildBoxBackgrounds(double cellSize, ThemeData theme) {
    final boxBackgrounds = <Widget>[];
    const boxSize = AppConstants.boxSize; // 3
    final boxDimension = cellSize * boxSize;
    
    // Purple color from design
    const purpleBoxColor = Color(0xFF2d1b69);

    for (var boxRow = 0; boxRow < 3; boxRow++) {
      for (var boxCol = 0; boxCol < 3; boxCol++) {
        boxBackgrounds.add(
          Positioned(
            left: boxCol * boxDimension,
            top: boxRow * boxDimension,
            width: boxDimension,
            height: boxDimension,
            child: Container(
              margin: const EdgeInsets.all(2), // Small gap between boxes
              decoration: BoxDecoration(
                color: purpleBoxColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }
    }

    return boxBackgrounds;
  }
}

/// Widget that displays a single Sudoku cell
class SudokuCellWidget extends StatelessWidget {
  const SudokuCellWidget({
    required this.cell,
    required this.row,
    required this.col,
    this.isSelected = false,
    this.isHighlighted = false,
    this.hasError = false,
    this.notes = const {},
    this.onTap,
    super.key,
  });

  final Cell cell;
  final int row;
  final int col;
  final bool isSelected;
  final bool isHighlighted;
  final bool hasError;
  final Set<int> notes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine if this cell is on a 3x3 box boundary
    final isTopBoxBorder = row % AppConstants.boxSize == 0;
    final isLeftBoxBorder = col % AppConstants.boxSize == 0;
    final isBottomBoxBorder = (row + 1) % AppConstants.boxSize == 0 || row == AppConstants.boardSize - 1;
    final isRightBoxBorder = (col + 1) % AppConstants.boxSize == 0 || col == AppConstants.boardSize - 1;
    
    // Box border color (darker for better visibility)
    const boxBorderColor = Color(0xFF5a5a7c);
    const cellBorderColor = Color(0xFF3a3a5c);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(colorScheme, 0),
          border: Border(
            top: BorderSide(
              color: isSelected 
                  ? colorScheme.primary 
                  : (isTopBoxBorder ? boxBorderColor : cellBorderColor),
              width: isSelected && isTopBoxBorder
                  ? 3.0
                  : isTopBoxBorder
                      ? 3.0
                      : 1.0,
            ),
            left: BorderSide(
              color: isSelected 
                  ? colorScheme.primary 
                  : (isLeftBoxBorder ? boxBorderColor : cellBorderColor),
              width: isSelected && isLeftBoxBorder
                  ? 3.0
                  : isLeftBoxBorder
                      ? 3.0
                      : 1.0,
            ),
            bottom: BorderSide(
              color: isSelected 
                  ? colorScheme.primary 
                  : (isBottomBoxBorder ? boxBorderColor : cellBorderColor),
              width: isSelected
                  ? 3.0
                  : isBottomBoxBorder
                      ? 3.0
                      : 1.0,
            ),
            right: BorderSide(
              color: isSelected 
                  ? colorScheme.primary 
                  : (isRightBoxBorder ? boxBorderColor : cellBorderColor),
              width: isSelected
                  ? 3.0
                  : isRightBoxBorder
                      ? 3.0
                      : 1.0,
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
                        ? colorScheme.onSurface // White for fixed
                        : const Color(0xFF4dd4e8), // Cyan for user input
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

  Color _getBackgroundColor(ColorScheme colorScheme, int boxIndex) {
    if (hasError) {
      return colorScheme.errorContainer;
    }

    // If this is the selected cell, use stronger highlight
    if (isSelected) {
      return const Color(0x40933AEA); // Slightly stronger purple for selected
    }

    // If this cell is in the same row, column, or box as selected cell
    if (isHighlighted) {
      return const Color(0x26933AEA); // Subtle prominent purple (15% opacity)
    }

    // Transparent to show purple box background through
    return Colors.transparent;
  }
}
