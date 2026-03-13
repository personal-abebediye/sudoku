import 'package:flutter/material.dart';

/// Widget that displays a number pad for entering numbers 1-9
class NumberPadWidget extends StatelessWidget {
  const NumberPadWidget({
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

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: [
        // Numbers 1-9
        for (var i = 1; i <= 9; i++)
          ElevatedButton(
            onPressed:
                onNumberSelected != null ? () => onNumberSelected!(i) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedNumber == i
                  ? colorScheme.primaryContainer
                  : colorScheme.surface,
              foregroundColor: selectedNumber == i
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
              elevation: selectedNumber == i ? 4 : 1,
            ),
            child: Text(
              '$i',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight:
                    selectedNumber == i ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        // Clear button
        ElevatedButton(
          onPressed:
              onNumberSelected != null ? () => onNumberSelected!(0) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.errorContainer,
            foregroundColor: colorScheme.onErrorContainer,
          ),
          child: Text(
            '✕',
            style: theme.textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }
}
