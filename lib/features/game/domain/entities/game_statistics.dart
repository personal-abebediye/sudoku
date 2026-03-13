import 'dart:convert';
import 'package:sudoku/features/game/domain/services/puzzle_generator.dart';

// ignore_for_file: sort_constructors_first

/// Statistics for a specific difficulty level
class DifficultyStats {
  DifficultyStats({
    this.gamesCompleted = 0,
    this.totalSeconds = 0,
    this.bestTimeSeconds,
  });

  factory DifficultyStats.fromJson(Map<String, dynamic> json) {
    return DifficultyStats(
      gamesCompleted: json['gamesCompleted'] as int? ?? 0,
      totalSeconds: json['totalSeconds'] as int? ?? 0,
      bestTimeSeconds: json['bestTimeSeconds'] as int?,
    );
  }

  final int gamesCompleted;
  final int totalSeconds;
  final int? bestTimeSeconds;

  /// Average time per game in seconds
  double get averageTimeSeconds =>
      gamesCompleted > 0 ? totalSeconds / gamesCompleted : 0;

  Map<String, dynamic> toJson() {
    return {
      'gamesCompleted': gamesCompleted,
      'totalSeconds': totalSeconds,
      'bestTimeSeconds': bestTimeSeconds,
    };
  }

  /// Create a copy with updated values
  DifficultyStats copyWith({
    int? gamesCompleted,
    int? totalSeconds,
    int? bestTimeSeconds,
  }) {
    return DifficultyStats(
      gamesCompleted: gamesCompleted ?? this.gamesCompleted,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
    );
  }
}

/// Overall game statistics
class GameStatistics {
  GameStatistics({
    Map<Difficulty, DifficultyStats>? statsByDifficulty,
    this.totalGamesPlayed = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
  }) : statsByDifficulty = statsByDifficulty ??
            {
              Difficulty.easy: DifficultyStats(),
              Difficulty.medium: DifficultyStats(),
              Difficulty.hard: DifficultyStats(),
              Difficulty.expert: DifficultyStats(),
            };

  factory GameStatistics.fromJson(Map<String, dynamic> json) {
    final statsMap = <Difficulty, DifficultyStats>{};
    final statsJson = json['statsByDifficulty'] as Map<String, dynamic>?;

    if (statsJson != null) {
      for (final difficulty in Difficulty.values) {
        final diffStats = statsJson[difficulty.name];
        if (diffStats != null) {
          statsMap[difficulty] =
              DifficultyStats.fromJson(diffStats as Map<String, dynamic>);
        } else {
          statsMap[difficulty] = DifficultyStats();
        }
      }
    }

    return GameStatistics(
      statsByDifficulty: statsMap,
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
    );
  }

  final Map<Difficulty, DifficultyStats> statsByDifficulty;
  final int totalGamesPlayed;
  final int currentStreak;
  final int bestStreak;

  /// Total time played across all difficulties in seconds
  int get totalTimePlayedSeconds {
    return statsByDifficulty.values
        .fold(0, (sum, stats) => sum + stats.totalSeconds);
  }

  Map<String, dynamic> toJson() {
    return {
      'statsByDifficulty': statsByDifficulty
          .map((key, value) => MapEntry(key.name, value.toJson())),
      'totalGamesPlayed': totalGamesPlayed,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory GameStatistics.fromJsonString(String jsonString) =>
      GameStatistics.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  /// Record a completed game
  GameStatistics recordCompletion(
      Difficulty difficulty, int completionTimeSeconds) {
    final currentStats = statsByDifficulty[difficulty]!;
    final newBestTime = currentStats.bestTimeSeconds == null
        ? completionTimeSeconds
        : (completionTimeSeconds < currentStats.bestTimeSeconds!
            ? completionTimeSeconds
            : currentStats.bestTimeSeconds);

    final updatedStats = currentStats.copyWith(
      gamesCompleted: currentStats.gamesCompleted + 1,
      totalSeconds: currentStats.totalSeconds + completionTimeSeconds,
      bestTimeSeconds: newBestTime,
    );

    final newStatsByDifficulty =
        Map<Difficulty, DifficultyStats>.from(statsByDifficulty);
    newStatsByDifficulty[difficulty] = updatedStats;

    final newStreak = currentStreak + 1;

    return GameStatistics(
      statsByDifficulty: newStatsByDifficulty,
      totalGamesPlayed: totalGamesPlayed + 1,
      currentStreak: newStreak,
      bestStreak: newStreak > bestStreak ? newStreak : bestStreak,
    );
  }
}
