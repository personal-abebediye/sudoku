import 'package:flutter/material.dart';
import 'package:sudoku/core/theme/app_theme.dart';

/// Modern 3x3 grid number pad widget (numbers 1-9 only)
class NumberPadGridWidget extends StatelessWidget {
  const NumberPadGridWidget({
    required this.onNumberSelected,
    this.selectedNumber,
    super.key,
  });

  final void Function(int)? onNumberSelected;
  final int? selectedNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.charcoal,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0, // Square buttons
        children: [
          // Numbers 1-9 in a 3x3 grid
          for (var i = 1; i <= 9; i++)
            ElevatedButton(
              onPressed:
                  onNumberSelected != null ? () => onNumberSelected!(i) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedNumber == i
                    ? colorScheme.primary
                    : AppTheme.backgroundDark,
                foregroundColor: AppTheme.pureWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                '$i',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
