import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/features/game/domain/entities/user_settings.dart';

// ignore_for_file: prefer_const_constructors

/// Service for persisting user settings
class SettingsService {
  static const String _key = 'user_settings';
  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Load user settings
  Future<UserSettings> loadSettings() async {
    try {
      final jsonString = _prefs?.getString(_key);
      if (jsonString == null) {
        return UserSettings();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserSettings.fromJson(json);
    } catch (e) {
      // Return defaults if loading fails
      return UserSettings();
    }
  }

  /// Save user settings
  Future<void> saveSettings(UserSettings settings) async {
    final json = settings.toJson();
    final jsonString = jsonEncode(json);
    await _prefs?.setString(_key, jsonString);
  }

  /// Reset settings to defaults
  Future<void> resetSettings() async {
    await _prefs?.remove(_key);
  }
}
