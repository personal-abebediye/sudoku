import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/entities/user_settings.dart';
import 'package:sudoku/shared/providers/theme_provider.dart';

// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

void main() {
  group('UserSettings', () {
    test('should create with default values', () {
      final settings = UserSettings();

      expect(settings.autoCheckErrors, true);
      expect(settings.showTimer, true);
      expect(settings.enableHaptics, true);
      expect(settings.highlightSameNumbers, true);
      expect(settings.highlightRow, true);
      expect(settings.highlightColumn, true);
      expect(settings.highlightBox, true);
      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.numberPadAtBottom, true);
    });

    test('should create with custom values', () {
      final settings = UserSettings(
        autoCheckErrors: false,
        showTimer: false,
        enableHaptics: false,
        highlightSameNumbers: false,
        themeMode: AppThemeMode.dark,
        numberPadAtBottom: false,
      );

      expect(settings.autoCheckErrors, false);
      expect(settings.showTimer, false);
      expect(settings.enableHaptics, false);
      expect(settings.highlightSameNumbers, false);
      expect(settings.themeMode, AppThemeMode.dark);
      expect(settings.numberPadAtBottom, false);
    });

    test('should create copy with modified values', () {
      final settings = UserSettings();
      final modified = settings.copyWith(
        autoCheckErrors: false,
        themeMode: AppThemeMode.light,
      );

      expect(modified.autoCheckErrors, false);
      expect(modified.themeMode, AppThemeMode.light);
      expect(modified.showTimer, true); // unchanged
    });

    test('should serialize to JSON', () {
      final settings = UserSettings(
        autoCheckErrors: false,
        themeMode: AppThemeMode.dark,
      );
      final json = settings.toJson();

      expect(json['autoCheckErrors'], false);
      expect(json['showTimer'], true);
      expect(json['themeMode'], 'dark');
    });

    test('should deserialize from JSON', () {
      final json = {
        'autoCheckErrors': false,
        'showTimer': false,
        'enableHaptics': true,
        'highlightSameNumbers': true,
        'highlightRow': false,
        'highlightColumn': false,
        'highlightBox': true,
        'themeMode': 'light',
        'numberPadAtBottom': false,
      };
      final settings = UserSettings.fromJson(json);

      expect(settings.autoCheckErrors, false);
      expect(settings.showTimer, false);
      expect(settings.highlightRow, false);
      expect(settings.themeMode, AppThemeMode.light);
      expect(settings.numberPadAtBottom, false);
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};
      final settings = UserSettings.fromJson(json);

      expect(settings.autoCheckErrors, true);
      expect(settings.showTimer, true);
      expect(settings.themeMode, AppThemeMode.system);
    });

    test('should handle invalid theme mode with default', () {
      final json = {'themeMode': 'invalid'};
      final settings = UserSettings.fromJson(json);

      expect(settings.themeMode, AppThemeMode.system);
    });

    test('should serialize and deserialize correctly', () {
      final original = UserSettings(
        autoCheckErrors: false,
        showTimer: false,
        enableHaptics: true,
        highlightSameNumbers: false,
        highlightRow: true,
        highlightColumn: false,
        highlightBox: true,
        themeMode: AppThemeMode.highContrast,
        numberPadAtBottom: false,
      );
      final json = original.toJson();
      final restored = UserSettings.fromJson(json);

      expect(restored.autoCheckErrors, original.autoCheckErrors);
      expect(restored.showTimer, original.showTimer);
      expect(restored.enableHaptics, original.enableHaptics);
      expect(restored.highlightSameNumbers, original.highlightSameNumbers);
      expect(restored.highlightRow, original.highlightRow);
      expect(restored.highlightColumn, original.highlightColumn);
      expect(restored.highlightBox, original.highlightBox);
      expect(restored.themeMode, original.themeMode);
      expect(restored.numberPadAtBottom, original.numberPadAtBottom);
    });
  });
}
