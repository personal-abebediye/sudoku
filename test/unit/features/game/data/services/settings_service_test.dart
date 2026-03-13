import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/features/game/data/services/settings_service.dart';
import 'package:sudoku/features/game/domain/entities/user_settings.dart';
import 'package:sudoku/shared/providers/theme_provider.dart';

// ignore_for_file: prefer_const_constructors

void main() {
  group('SettingsService', () {
    late SettingsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = SettingsService();
      await service.initialize();
    });

    test('should load default settings when none exist', () async {
      final settings = await service.loadSettings();

      expect(settings.autoCheckErrors, true);
      expect(settings.showTimer, true);
      expect(settings.themeMode, AppThemeMode.system);
    });

    test('should save and load settings', () async {
      final settings = UserSettings(
        autoCheckErrors: false,
        showTimer: false,
        themeMode: AppThemeMode.dark,
      );

      await service.saveSettings(settings);
      final loaded = await service.loadSettings();

      expect(loaded.autoCheckErrors, false);
      expect(loaded.showTimer, false);
      expect(loaded.themeMode, AppThemeMode.dark);
    });

    test('should reset settings to defaults', () async {
      // Save custom settings
      await service.saveSettings(UserSettings(
        autoCheckErrors: false,
        themeMode: AppThemeMode.dark,
      ));

      // Reset
      await service.resetSettings();

      // Load should return defaults
      final loaded = await service.loadSettings();
      expect(loaded.autoCheckErrors, true);
      expect(loaded.themeMode, AppThemeMode.system);
    });

    test('should handle corrupted data gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_settings', 'invalid json');

      final settings = await service.loadSettings();
      expect(settings.autoCheckErrors, true); // defaults
    });
  });
}
