import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/game/data/services/game_persistence_service.dart';
import 'features/game/data/services/settings_service.dart';
import 'features/game/data/services/statistics_service.dart';
import 'features/game/domain/entities/board.dart';
import 'features/game/domain/entities/game_state.dart';
import 'features/game/domain/entities/game_timer.dart';
import 'features/game/domain/entities/move.dart';
import 'features/game/domain/entities/move_history.dart';
import 'features/game/domain/entities/user_settings.dart';
import 'features/game/domain/services/hint_service.dart';
import 'features/game/domain/services/puzzle_generator.dart';
import 'features/game/presentation/screens/settings_screen.dart';
import 'features/game/presentation/screens/statistics_screen.dart';
import 'features/game/presentation/screens/tutorial_screen.dart';
import 'features/game/presentation/widgets/game_control_bar.dart';
import 'features/game/presentation/widgets/number_pad_grid_widget.dart';
import 'features/game/presentation/widgets/sudoku_board_widget.dart';
import 'shared/providers/theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SudokuApp(),
    ),
  );
}

class SudokuApp extends ConsumerWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeModeProvider);

    // Determine which theme to use
    final lightTheme = appThemeMode == AppThemeMode.highContrast
        ? AppTheme.highContrastTheme
        : AppTheme.lightTheme;

    final darkTheme = appThemeMode == AppThemeMode.darkModern
        ? AppTheme.darkModernTheme
        : AppTheme.darkTheme;

    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appThemeMode.toThemeMode(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  final _generator = PuzzleGenerator();
  final _moveHistory = MoveHistory();
  final _gameTimer = GameTimer();
  final _persistenceService = GamePersistenceService();
  final _statisticsService = StatisticsService();
  final _settingsService = SettingsService();
  final _hintService = HintService();
  Difficulty _currentDifficulty = Difficulty.easy;
  Board? _board;
  Board? _originalBoard; // Store original for restart
  int? _selectedRow;
  int? _selectedCol;
  Set<String> _errorCells = {};
  bool _isNotesMode = false;
  bool _isPaused = false;
  bool _isLoading = true;
  final Map<String, Set<int>> _notes = {};
  UserSettings _settings = const UserSettings();
  int _hintsRemaining = 0; // Updated based on difficulty

  @override
  void initState() {
    super.initState();
    _loadOrCreateGame();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _loadOrCreateGame() async {
    // Initialize services
    await _settingsService.initialize();

    // Load settings and apply theme
    final settings = await _settingsService.loadSettings();
    if (mounted) {
      ref.read(themeModeProvider.notifier).state = settings.themeMode;
    }

    final savedGame = await _persistenceService.loadGame();

    if (savedGame != null) {
      // Resume saved game
      setState(() {
        _settings = settings;
        _board = savedGame.board;
        _originalBoard = savedGame.originalBoard;
        _currentDifficulty = savedGame.difficulty;
        _hintsRemaining = _getHintLimit(savedGame.difficulty);
        _notes
          ..clear()
          ..addAll(savedGame.notes);
        _gameTimer.setElapsedForTesting(
          Duration(seconds: savedGame.elapsedSeconds),
        );
        _isLoading = false;
      });
    } else {
      // Create new game
      setState(() {
        _settings = settings;
        _board = _generator.generatePuzzle(_currentDifficulty);
        _originalBoard = _board;
        _hintsRemaining = _getHintLimit(_currentDifficulty);
        _isLoading = false;
      });
    }

    _gameTimer.start();

    // Show tutorial on first launch
    final prefs = await SharedPreferences.getInstance();
    final tutorialCompleted = prefs.getBool('tutorial_completed') ?? false;
    if (!tutorialCompleted && mounted) {
      // Delay to let the UI settle
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const TutorialScreen(),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause timer when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _gameTimer.pause();
      _saveGameState(); // Save when app goes to background
    }
    // Resume timer when app comes back to foreground
    else if (state == AppLifecycleState.resumed) {
      _gameTimer.resume();
    }
  }

  void _saveGameState() {
    if (_board == null || _originalBoard == null) {
      return;
    }

    final gameState = GameState(
      board: _board!,
      originalBoard: _originalBoard!,
      difficulty: _currentDifficulty,
      elapsedSeconds: _gameTimer.elapsed.inSeconds,
      notes: Map.from(_notes),
    );
    _persistenceService.saveGame(gameState);
  }

  void _updateErrors() {
    if (_board == null) {
      return;
    }

    // Only check errors if auto-check is enabled
    if (_settings.autoCheckErrors) {
      final errors = <String>{};
      for (var row = 0; row < 9; row++) {
        for (var col = 0; col < 9; col++) {
          if (_board!.hasConflict(row, col)) {
            errors.add('$row,$col');
          }
        }
      }
      _errorCells = errors;
    } else {
      _errorCells = {};
    }

    // Check if puzzle is complete
    if (_isPuzzleComplete()) {
      _handlePuzzleCompletion();
    }
  }

  bool _isPuzzleComplete() {
    if (_board == null) {
      return false;
    }

    // Check all cells are filled
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (_board!.cells[row][col].isEmpty) {
          return false;
        }
      }
    }

    // Check no errors
    return _errorCells.isEmpty;
  }

  Future<void> _handlePuzzleCompletion() async {
    // Stop timer
    _gameTimer.pause();

    // Load and update statistics
    final stats = await _statisticsService.loadStatistics();
    final completionTime = _gameTimer.elapsed.inSeconds;
    final updatedStats =
        stats.recordCompletion(_currentDifficulty, completionTime);
    await _statisticsService.saveStatistics(updatedStats);

    // Clear saved game (puzzle is complete)
    await _persistenceService.clearGame();

    // Show completion dialog
    if (mounted) {
      _showCompletionDialog(completionTime);
    }
  }

  void _showCompletionDialog(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎉 Puzzle Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Time: $timeStr',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Difficulty: ${_getDifficultyLabel(_currentDifficulty)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleRefresh();
              },
              child: const Text('New Game'),
            ),
          ],
        );
      },
    );
  }

  void _handleNumberSelected(int number) {
    if (_selectedRow == null || _selectedCol == null || _board == null) {
      return;
    }

    final row = _selectedRow!;
    final col = _selectedCol!;

    // Don't allow input on fixed cells
    if (_board!.cells[row][col].isFixed) {
      return;
    }

    // Notes mode: toggle note
    if (_isNotesMode) {
      setState(() {
        final key = '$row,$col';
        _notes.putIfAbsent(key, () => <int>{});

        if (number == 0) {
          // Clear button clears all notes for this cell
          _notes[key]!.clear();
        } else {
          // Toggle the note
          if (_notes[key]!.contains(number)) {
            _notes[key]!.remove(number);
          } else {
            _notes[key]!.add(number);
          }
        }
      });
      _saveGameState(); // Save after notes change
      return;
    }

    // Normal mode: set cell value
    final oldValue = _board!.cells[row][col].value;

    // Only record move if value actually changes
    if (oldValue != number) {
      _moveHistory.push(Move(
        row: row,
        col: col,
        oldValue: oldValue,
        newValue: number,
      ));
    }

    setState(() {
      _board = _board!.setCell(row, col, number);

      // Clear notes when value is set
      if (number != 0) {
        _notes.remove('$row,$col');
      }

      _updateErrors();
    });
    _saveGameState(); // Save after move
  }

  void _handleErase() {
    if (_selectedRow == null || _selectedCol == null || _board == null) {
      return;
    }

    final row = _selectedRow!;
    final col = _selectedCol!;

    // Don't allow erase on fixed cells
    if (_board!.cells[row][col].isFixed) {
      return;
    }

    final oldValue = _board!.cells[row][col].value;
    final cellKey = '$row,$col';

    // Clear both value and notes
    if (oldValue != 0) {
      _moveHistory.push(Move(
        row: row,
        col: col,
        oldValue: oldValue,
        newValue: 0,
      ));
    }

    setState(() {
      _board = _board!.setCell(row, col, 0);
      _notes.remove(cellKey); // Also clear notes
      _updateErrors();
    });
    _saveGameState();
  }

  void _handleHint() {
    if (_board == null || _hintsRemaining <= 0) {
      return;
    }

    final hint = _hintService.findBestHint(_board!);
    if (hint == null) {
      // No hint available (board complete or invalid)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hints available!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Select the hint cell and show candidates in a dialog
    setState(() {
      _selectedRow = hint.row;
      _selectedCol = hint.col;
      if (_hintsRemaining < 999) {
        _hintsRemaining--;
      }
    });

    // Show hint dialog with candidates
    if (mounted) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('💡 Hint'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cell at row ${hint.row + 1}, column ${hint.col + 1}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  hint.candidates.length == 1
                      ? 'Can only be: ${hint.candidates.first}'
                      : 'Possible values: ${hint.candidates.toList()..sort()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (_hintsRemaining < 999)
                  Text(
                    'Hints remaining: $_hintsRemaining',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it!'),
              ),
            ],
          );
        },
      );
    }
  }

  void _handleUndo() {
    final move = _moveHistory.undo();
    if (move == null || _board == null) {
      return;
    }

    setState(() {
      _board = _board!.setCell(move.row, move.col, move.oldValue);
      _updateErrors();
    });
    _saveGameState(); // Save after undo
  }

  // Redo functionality preserved for future use (not in current UI)
  // ignore: unused_element
  void _handleRedo() {
    final move = _moveHistory.redo();
    if (move == null || _board == null) {
      return;
    }

    setState(() {
      _board = _board!.setCell(move.row, move.col, move.newValue);
      _updateErrors();
    });
    _saveGameState(); // Save after redo
  }

  void _handleRefresh() {
    setState(() {
      _board = _generator.generatePuzzle(_currentDifficulty);
      _originalBoard = _board; // Store original for restart
      _selectedRow = null;
      _selectedCol = null;
      _errorCells = {};
      _moveHistory.clear(); // Clear history when starting new puzzle
      _notes.clear(); // Clear all notes when starting new puzzle
      _isPaused = false; // Unpause if paused
      _hintsRemaining = _getHintLimit(_currentDifficulty);
      _gameTimer
        ..reset() // Reset timer when starting new puzzle
        ..start(); // Start fresh timer
    });
    _saveGameState(); // Save new game
  }

  /// Get hint limit based on difficulty
  int _getHintLimit(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 999; // Effectively unlimited
      case Difficulty.medium:
        return 5;
      case Difficulty.hard:
        return 3;
      case Difficulty.expert:
        return 1;
    }
  }

  void _handlePause() {
    setState(() {
      _isPaused = true;
      _gameTimer.pause();
    });
  }

  void _handleResume() {
    setState(() {
      _isPaused = false;
      _gameTimer.resume();
    });
  }

  void _handleRestart() {
    if (_originalBoard == null) {
      return;
    }

    setState(() {
      _board = _originalBoard; // Reset to original puzzle
      _selectedRow = null;
      _selectedCol = null;
      _errorCells = {};
      _moveHistory.clear(); // Clear all moves
      _notes.clear(); // Clear all notes
      _isPaused = false; // Unpause if paused
      _hintsRemaining = _getHintLimit(_currentDifficulty);
      _gameTimer
        ..reset()
        ..start(); // Restart timer
    });
    _saveGameState(); // Save restarted game
  }

  void _showDifficultyDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Difficulty'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: Difficulty.values.map((difficulty) {
                  // ignore: deprecated_member_use
                  return RadioListTile<Difficulty>(
                    title: Text(_getDifficultyLabel(difficulty)),
                    subtitle: Text(_getDifficultySubtitle(difficulty)),
                    value: difficulty,
                    // ignore: deprecated_member_use
                    groupValue: _currentDifficulty,
                    // ignore: deprecated_member_use
                    onChanged: (Difficulty? value) {
                      if (value != null) {
                        Navigator.of(context).pop();
                        setState(() {
                          _currentDifficulty = value;
                        });
                        _handleRefresh();
                      }
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
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

  String _getDifficultySubtitle(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '40-45 clues';
      case Difficulty.medium:
        return '30-35 clues';
      case Difficulty.hard:
        return '25-30 clues';
      case Difficulty.expert:
        return '20-25 clues';
    }
  }

  /// Build timer display for AppBar title
  Widget _buildTimerTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'TIMER',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        TimerDisplay(
          timer: _gameTimer,
          showIcon: false, // Don't show icon in AppBar
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while game loads
    if (_isLoading || _board == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sudoku'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Menu',
          onPressed: _isPaused ? null : _handlePause, // Open pause menu
        ),
        title: _settings.showTimer ? _buildTimerTitle() : const Text('Sudoku'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Hint',
            onPressed: _hintsRemaining > 0 ? _handleHint : null,
          ),
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            tooltip: _isPaused ? 'Resume' : 'Pause',
            onPressed: _isPaused ? _handleResume : _handlePause,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              // Reload settings after returning
              final newSettings = await _settingsService.loadSettings();
              if (mounted) {
                setState(() {
                  _settings = newSettings;
                });
                // Sync theme with provider
                ref.read(themeModeProvider.notifier).state =
                    newSettings.themeMode;
              }
            },
          ),
        ],
      ),
      body: _isPaused
          ? _buildPausedOverlay()
          : Column(
              children: [
                // Sudoku Board
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: SudokuBoardWidget(
                          board: _board!,
                          selectedRow: _selectedRow,
                          selectedCol: _selectedCol,
                          errorCells: _errorCells,
                          notes: _notes,
                          onCellSelected: (row, col) {
                            setState(() {
                              _selectedRow = row;
                              _selectedCol = col;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                // Control Bar
                GameControlBar(
                  onUndo: _moveHistory.canUndo ? _handleUndo : null,
                  onToggleNotes: () {
                    setState(() {
                      _isNotesMode = !_isNotesMode;
                    });
                  },
                  onHint: _hintsRemaining > 0 ? _handleHint : null,
                  onErase: _selectedRow != null && _selectedCol != null
                      ? _handleErase
                      : null,
                  canUndo: _moveHistory.canUndo,
                  isNotesMode: _isNotesMode,
                  canUseHint: _hintsRemaining > 0,
                  canErase: _selectedRow != null &&
                      _selectedCol != null &&
                      _board != null &&
                      !_board!.cells[_selectedRow!][_selectedCol!].isFixed,
                  hintCount: _hintsRemaining < 999 ? _hintsRemaining : null,
                ),
                // Number Pad (3x3 grid)
                SizedBox(
                  height: 220,
                  child: NumberPadGridWidget(
                    onNumberSelected: _handleNumberSelected,
                    selectedNumber: _selectedRow != null &&
                            _selectedCol != null &&
                            _board != null
                        ? _board!.cells[_selectedRow!][_selectedCol!].value
                        : null,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPausedOverlay() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pause_circle_outline,
            size: 120,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Game Paused',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),
          // Action buttons
          FilledButton.icon(
            onPressed: _handleResume,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume Game'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _handleRestart,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Restart Puzzle'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _showDifficultyDialog,
            icon: const Icon(Icons.add),
            label: const Text('New Game'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart),
            label: const Text('Statistics'),
          ),
        ],
      ),
    );
  }
}

/// Widget that displays the game timer with real-time updates
class TimerDisplay extends StatefulWidget {
  const TimerDisplay({
    required this.timer,
    this.showIcon = true,
    super.key,
  });

  final GameTimer timer;
  final bool showIcon;

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    // Create a ticker that updates every second
    _ticker = createTicker((_) {
      if (widget.timer.isRunning) {
        setState(() {}); // Trigger rebuild to update time display
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showIcon) ...[
              const Icon(Icons.timer_outlined, size: 20),
              const SizedBox(width: 4),
            ],
            Text(
              widget.timer.format(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
