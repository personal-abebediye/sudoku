import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/features/game/presentation/screens/tutorial_screen.dart';

void main() {
  group('TutorialScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display first tutorial step',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TutorialScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check first step content
      expect(find.text('Tutorial'), findsOneWidget);
      expect(find.text('Step 1 of 8'), findsOneWidget);
      expect(find.text('Welcome to Sudoku!'), findsOneWidget);
      expect(find.textContaining('Sudoku is a logic puzzle'), findsOneWidget);

      // Should only have Next button (no Back on first step)
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Back'), findsNothing);
    });

    testWidgets('should navigate to next step', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TutorialScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Check second step
      expect(find.text('Step 2 of 8'), findsOneWidget);
      expect(find.text('How to Play'), findsOneWidget);

      // Should have both buttons now
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('should navigate back to previous step',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TutorialScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Go to step 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Step 2 of 8'), findsOneWidget);

      // Go back
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Should be back at step 1
      expect(find.text('Step 1 of 8'), findsOneWidget);
      expect(find.text('Welcome to Sudoku!'), findsOneWidget);
    });

    testWidgets('should show Finish button on last step',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TutorialScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to last step (step 8)
      for (var i = 0; i < 7; i++) {
        await tester.tap(find.text(i == 6 ? 'Next' : 'Next'));
        await tester.pumpAndSettle();
      }

      // Check last step
      expect(find.text('Step 8 of 8'), findsOneWidget);
      expect(find.text('You\'re Ready!'), findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);
    });

    testWidgets('should close tutorial on finish', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const TutorialScreen(),
                    ),
                  );
                },
                child: const Text('Open Tutorial'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open tutorial
      await tester.tap(find.text('Open Tutorial'));
      await tester.pumpAndSettle();
      expect(find.text('Tutorial'), findsOneWidget);

      // Navigate to last step
      for (var i = 0; i < 7; i++) {
        await tester.tap(find.text(i == 6 ? 'Next' : 'Next'));
        await tester.pumpAndSettle();
      }

      // Tap finish
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      // Tutorial should be closed
      expect(find.text('Tutorial'), findsNothing);
    });

    testWidgets('should show skip confirmation dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TutorialScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Check confirmation dialog
      expect(find.text('Skip Tutorial'), findsOneWidget);
      expect(
        find.textContaining('Are you sure you want to skip'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('should cancel skip', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TutorialScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should close, still in tutorial
      expect(find.text('Skip Tutorial'), findsNothing);
      expect(find.text('Welcome to Sudoku!'), findsOneWidget);
    });

    testWidgets('should skip tutorial', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const TutorialScreen(),
                    ),
                  );
                },
                child: const Text('Open Tutorial'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open tutorial
      await tester.tap(find.text('Open Tutorial'));
      await tester.pumpAndSettle();

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Confirm skip
      await tester.tap(find.widgetWithText(FilledButton, 'Skip'));
      await tester.pumpAndSettle();

      // Tutorial should be closed
      expect(find.text('Tutorial'), findsNothing);
    });

    testWidgets('should update progress indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TutorialScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check progress on first step (1/8 = 0.125)
      var progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(progressIndicator.value, closeTo(0.125, 0.01));

      // Go to next step
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Check progress on second step (2/8 = 0.25)
      progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(progressIndicator.value, closeTo(0.25, 0.01));
    });

    testWidgets('should display all 8 tutorial steps',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TutorialScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final expectedTitles = [
        'Welcome to Sudoku!',
        'How to Play',
        'Number Pad',
        'Pencil Marks',
        'Error Checking',
        'Undo & Redo',
        'Game Controls',
        'You\'re Ready!',
      ];

      for (var i = 0; i < expectedTitles.length; i++) {
        expect(find.text('Step ${i + 1} of 8'), findsOneWidget);
        expect(find.text(expectedTitles[i]), findsOneWidget);

        if (i < expectedTitles.length - 1) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
