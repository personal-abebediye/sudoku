import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/features/game/domain/entities/game_statistics.dart';

/// Service for persisting and loading game statistics
class StatisticsService {
  static const String _statisticsKey = 'game_statistics';

  /// Save statistics
  Future<bool> saveStatistics(GameStatistics stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = stats.toJsonString();
      return await prefs.setString(_statisticsKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Load statistics
  Future<GameStatistics> loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_statisticsKey);

      if (jsonString == null) {
        return GameStatistics();
      }

      return GameStatistics.fromJsonString(jsonString);
    } catch (e) {
      return GameStatistics();
    }
  }

  /// Reset all statistics
  Future<bool> resetStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_statisticsKey);
    } catch (e) {
      return false;
    }
  }
}
