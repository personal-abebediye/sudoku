import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/features/game/presentation/screens/settings_screen.dart';
import 'package:sudoku/shared/providers/theme_provider.dart';

void main() {
  group('SettingsScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display settings screen with sections',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Wait for loading
      await tester.pumpAndSettle();

      // Check title
      expect(find.text('Settings'), findsOneWidget);

      // Check sections
      expect(find.text('Game Settings'), findsOneWidget);
      expect(find.text('Display Settings'), findsOneWidget);

      // Check game settings switches
      expect(find.text('Auto-check errors'), findsOneWidget);
      expect(find.text('Show timer'), findsOneWidget);
      expect(find.text('Haptic feedback'), findsOneWidget);

      // Check display settings
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Highlight same numbers'), findsOneWidget);
      expect(find.text('Highlight row'), findsOneWidget);
      expect(find.text('Highlight column'), findsOneWidget);
      expect(find.text('Highlight box'), findsOneWidget);
      expect(find.text('Number pad at bottom'), findsOneWidget);
    });

    testWidgets('should toggle auto-check errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the switch for auto-check errors
      final switchFinder = find.descendant(
        of: find.ancestor(
          of: find.text('Auto-check errors'),
          matching: find.byType(SwitchListTile),
        ),
        matching: find.byType(Switch),
      );

      // Check initial state (should be ON by default)
      final initialSwitch = tester.widget<Switch>(switchFinder);
      expect(initialSwitch.value, true);

      // Toggle off
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Verify it's off
      final toggledSwitch = tester.widget<Switch>(switchFinder);
      expect(toggledSwitch.value, false);
    });

    testWidgets('should open theme picker dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on theme tile
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      // Check dialog appears
      expect(find.text('Select Theme'), findsOneWidget);
      expect(find.byType(RadioListTile<AppThemeMode>), findsNWidgets(4));
    });

    testWidgets('should change theme via dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on theme tile
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      // Find and tap the dark theme radio button
      final darkRadio = find.byWidgetPredicate((widget) {
        return widget is RadioListTile<AppThemeMode> &&
            widget.value == AppThemeMode.dark;
      });
      await tester.tap(darkRadio);
      await tester.pumpAndSettle();

      // Dialog should close
      expect(find.text('Select Theme'), findsNothing);
    });

    testWidgets('should display reset button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check reset button exists
      expect(find.byIcon(Icons.restore), findsOneWidget);
      expect(find.byTooltip('Reset to defaults'), findsOneWidget);
    });

    testWidgets('should show reset confirmation dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap reset button
      await tester.tap(find.byIcon(Icons.restore));
      await tester.pumpAndSettle();

      // Check confirmation dialog
      expect(find.text('Reset Settings'), findsOneWidget);
      expect(
        find.text('Are you sure you want to reset all settings to defaults?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('should cancel reset', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap reset button
      await tester.tap(find.byIcon(Icons.restore));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should close
      expect(find.text('Reset Settings'), findsNothing);
    });

    testWidgets('should confirm reset', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Change a setting first
      final switchFinder = find.descendant(
        of: find.ancestor(
          of: find.text('Auto-check errors'),
          matching: find.byType(SwitchListTile),
        ),
        matching: find.byType(Switch),
      );
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Verify it changed
      var toggledSwitch = tester.widget<Switch>(switchFinder);
      expect(toggledSwitch.value, false);

      // Tap reset button
      await tester.tap(find.byIcon(Icons.restore));
      await tester.pumpAndSettle();

      // Confirm reset
      await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
      await tester.pumpAndSettle();

      // Dialog should close
      expect(find.text('Reset Settings'), findsNothing);

      // Setting should be back to default (true)
      final resetSwitch = tester.widget<Switch>(switchFinder);
      expect(resetSwitch.value, true);
    });

    testWidgets('should toggle all boolean settings',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // List of all switchable settings
      final settingLabels = [
        'Auto-check errors',
        'Show timer',
        'Haptic feedback',
        'Highlight same numbers',
        'Highlight row',
        'Highlight column',
        'Highlight box',
        'Number pad at bottom',
      ];

      // Toggle each one
      for (final label in settingLabels) {
        // Scroll to make sure widget is visible
        await tester.ensureVisible(find.text(label));
        await tester.pumpAndSettle();

        final switchFinder = find.descendant(
          of: find.ancestor(
            of: find.text(label),
            matching: find.byType(SwitchListTile),
          ),
          matching: find.byType(Switch),
        );

        // Get initial value
        final initialValue = tester.widget<Switch>(switchFinder).value;

        // Toggle
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        // Verify it changed
        final newValue = tester.widget<Switch>(switchFinder).value;
        expect(newValue, !initialValue);
      }
    });
  });
}
