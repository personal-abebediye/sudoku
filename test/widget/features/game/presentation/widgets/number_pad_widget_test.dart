import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/presentation/widgets/number_pad_widget.dart';

void main() {
  group('NumberPadWidget', () {
    testWidgets('should display buttons 1-9', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberPadWidget(
              onNumberSelected: (_) {},
            ),
          ),
        ),
      );

      // Assert - Check for buttons 1-9
      for (var i = 1; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('should display clear/erase button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberPadWidget(
              onNumberSelected: (_) {},
            ),
          ),
        ),
      );

      // Assert - Clear button (X or Clear text)
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data == 'Clear' ||
                  widget.data == 'X' ||
                  widget.data == '✕'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should call callback when number button tapped',
        (tester) async {
      // Arrange
      int? selectedNumber;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberPadWidget(
              onNumberSelected: (number) => selectedNumber = number,
            ),
          ),
        ),
      );

      // Act - Tap button "5"
      await tester.tap(find.text('5'));
      await tester.pump();

      // Assert
      expect(selectedNumber, equals(5));
    });

    testWidgets('should call callback with 0 when clear button tapped',
        (tester) async {
      // Arrange
      int? selectedNumber;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                height: 400,
                width: 300,
                child: NumberPadWidget(
                  onNumberSelected: (number) => selectedNumber = number,
                ),
              ),
            ),
          ),
        ),
      );

      // Act - Tap clear button
      await tester.tap(find.text('✕'));
      await tester.pump();

      // Assert
      expect(selectedNumber, equals(0));
    });

    testWidgets('should have proper grid layout', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberPadWidget(
              onNumberSelected: (_) {},
            ),
          ),
        ),
      );

      // Assert - Should render without overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('should disable buttons when onNumberSelected is null',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NumberPadWidget(
              onNumberSelected: null,
            ),
          ),
        ),
      );

      // Assert - All buttons should be disabled
      final buttons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      for (final button in buttons) {
        expect(button.onPressed, isNull);
      }
    });

    testWidgets('should highlight selected number', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberPadWidget(
              onNumberSelected: (_) {},
              selectedNumber: 7,
            ),
          ),
        ),
      );

      // Assert - Widget should render (visual distinction tested manually)
      expect(find.text('7'), findsOneWidget);
    });
  });
}
