import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/features/game/domain/entities/game_state.dart';

/// Service for persisting and loading game state
class GamePersistenceService {
  static const String _currentGameKey = 'current_game_state';

  /// Save the current game state
  Future<bool> saveGame(GameState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = state.toJsonString();
      return await prefs.setString(_currentGameKey, jsonString);
    } catch (e) {
      // Log error in production
      return false;
    }
  }

  /// Load the saved game state
  Future<GameState?> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_currentGameKey);
      
      if (jsonString == null) {
        return null;
      }
      
      return GameState.fromJsonString(jsonString);
    } catch (e) {
      // Log error in production
      return null;
    }
  }

  /// Check if a saved game exists
  Future<bool> hasSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_currentGameKey);
    } catch (e) {
      return false;
    }
  }

  /// Clear the saved game state
  Future<bool> clearGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_currentGameKey);
    } catch (e) {
      return false;
    }
  }
}
