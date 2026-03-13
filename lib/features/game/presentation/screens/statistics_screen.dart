import 'package:flutter/material.dart';
import 'package:sudoku/features/game/data/services/statistics_service.dart';
import 'package:sudoku/features/game/domain/entities/game_statistics.dart';
import 'package:sudoku/features/game/domain/services/puzzle_generator.dart';

/// Screen displaying game statistics
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _statisticsService = StatisticsService();
  GameStatistics? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final stats = await _statisticsService.loadStatistics();
    setState(() {
      _statistics = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Statistics',
            onPressed: _showResetDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Overall stats card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Overall Statistics',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildStatRow(
                            'Total Games Played',
                            '${_statistics!.totalGamesPlayed}',
                            Icons.sports_esports,
                            colorScheme,
                          ),
                          _buildStatRow(
                            'Current Streak',
                            '${_statistics!.currentStreak}',
                            Icons.local_fire_department,
                            colorScheme,
                          ),
                          _buildStatRow(
                            'Best Streak',
                            '${_statistics!.bestStreak}',
                            Icons.emoji_events,
                            colorScheme,
                          ),
                          _buildStatRow(
                            'Total Time Played',
                            _formatTime(_statistics!.totalTimePlayedSeconds),
                            Icons.access_time,
                            colorScheme,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Per-difficulty stats
                  ...Difficulty.values.map((difficulty) {
                    final stats = _statistics!.statsByDifficulty[difficulty]!;
                    return _buildDifficultyCard(
                      difficulty,
                      stats,
                      theme,
                      colorScheme,
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildDifficultyCard(
    Difficulty difficulty,
    DifficultyStats stats,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDifficultyIcon(difficulty),
                  color: _getDifficultyColor(difficulty, colorScheme),
                ),
                const SizedBox(width: 8),
                Text(
                  _getDifficultyLabel(difficulty),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getDifficultyColor(difficulty, colorScheme),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (stats.gamesCompleted > 0) ...[
              _buildStatRow(
                'Games Completed',
                '${stats.gamesCompleted}',
                Icons.check_circle_outline,
                colorScheme,
              ),
              _buildStatRow(
                'Average Time',
                _formatTime(stats.averageTimeSeconds.round()),
                Icons.schedule,
                colorScheme,
              ),
              if (stats.bestTimeSeconds != null)
                _buildStatRow(
                  'Best Time',
                  _formatTime(stats.bestTimeSeconds!),
                  Icons.star,
                  colorScheme,
                ),
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No games completed yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  String _getDifficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  IconData _getDifficultyIcon(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied;
      case Difficulty.medium:
        return Icons.sentiment_neutral;
      case Difficulty.hard:
        return Icons.sentiment_dissatisfied;
      case Difficulty.expert:
        return Icons.whatshot;
    }
  }

  Color _getDifficultyColor(Difficulty difficulty, ColorScheme colorScheme) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
      case Difficulty.expert:
        return Colors.purple;
    }
  }

  void _showResetDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Statistics?'),
          content: const Text(
            'This will permanently delete all your game statistics. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await _statisticsService.resetStatistics();
                if (mounted) {
                  navigator.pop();
                  await _loadStatistics();
                }
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
