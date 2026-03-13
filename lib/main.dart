import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/game/data/services/game_persistence_service.dart';
import 'features/game/domain/entities/board.dart';
import 'features/game/domain/entities/game_state.dart';
import 'features/game/domain/entities/game_timer.dart';
import 'features/game/domain/entities/move.dart';
import 'features/game/domain/entities/move_history.dart';
import 'features/game/domain/services/puzzle_generator.dart';
import 'features/game/presentation/widgets/number_pad_widget.dart';
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

    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: AppTheme.darkTheme,
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

  @override
  void initState() {
    super.initState();
    _loadOrCreateGame();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _loadOrCreateGame() async {
    final savedGame = await _persistenceService.loadGame();

    if (savedGame != null) {
      // Resume saved game
      setState(() {
        _board = savedGame.board;
        _originalBoard = savedGame.originalBoard;
        _currentDifficulty = savedGame.difficulty;
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
        _board = _generator.generatePuzzle(_currentDifficulty);
        _originalBoard = _board;
        _isLoading = false;
      });
    }

    _gameTimer.start();
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

    final errors = <String>{};
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (_board!.hasConflict(row, col)) {
          errors.add('$row,$col');
        }
      }
    }
    _errorCells = errors;
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
      _gameTimer
        ..reset() // Reset timer when starting new puzzle
        ..start(); // Start fresh timer
    });
    _saveGameState(); // Save new game
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
      _gameTimer
        ..reset()
        ..start(); // Restart timer
    });
    _saveGameState(); // Save restarted game
  }

  void _showThemeDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final currentTheme = ref.read(themeModeProvider);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Choose Theme'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ignore: deprecated_member_use
                  RadioListTile<AppThemeMode>(
                    title: const Text('Light'),
                    subtitle: const Text('Bright and clean'),
                    value: AppThemeMode.light,
                    // ignore: deprecated_member_use
                    groupValue: currentTheme,
                    // ignore: deprecated_member_use
                    onChanged: (AppThemeMode? value) {
                      if (value != null) {
                        ref.read(themeModeProvider.notifier).state = value;
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  // ignore: deprecated_member_use
                  RadioListTile<AppThemeMode>(
                    title: const Text('Dark'),
                    subtitle: const Text('Easy on the eyes'),
                    value: AppThemeMode.dark,
                    // ignore: deprecated_member_use
                    groupValue: currentTheme,
                    // ignore: deprecated_member_use
                    onChanged: (AppThemeMode? value) {
                      if (value != null) {
                        ref.read(themeModeProvider.notifier).state = value;
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  // ignore: deprecated_member_use
                  RadioListTile<AppThemeMode>(
                    title: const Text('High Contrast'),
                    subtitle: const Text('Maximum readability'),
                    value: AppThemeMode.highContrast,
                    // ignore: deprecated_member_use
                    groupValue: currentTheme,
                    // ignore: deprecated_member_use
                    onChanged: (AppThemeMode? value) {
                      if (value != null) {
                        ref.read(themeModeProvider.notifier).state = value;
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  // ignore: deprecated_member_use
                  RadioListTile<AppThemeMode>(
                    title: const Text('System'),
                    subtitle: const Text('Match device settings'),
                    value: AppThemeMode.system,
                    // ignore: deprecated_member_use
                    groupValue: currentTheme,
                    // ignore: deprecated_member_use
                    onChanged: (AppThemeMode? value) {
                      if (value != null) {
                        ref.read(themeModeProvider.notifier).state = value;
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
        title: const Text('Sudoku'),
        actions: [
          // Timer Display
          TimerDisplay(timer: _gameTimer),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Change Theme',
            onPressed: _showThemeDialog,
          ),
          IconButton(
            icon: Icon(_isNotesMode ? Icons.edit : Icons.edit_outlined),
            tooltip: _isNotesMode ? 'Notes Mode (ON)' : 'Notes Mode (OFF)',
            onPressed: () {
              setState(() {
                _isNotesMode = !_isNotesMode;
              });
            },
            color: _isNotesMode ? Theme.of(context).colorScheme.primary : null,
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _moveHistory.canUndo ? _handleUndo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: _moveHistory.canRedo ? _handleRedo : null,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Game',
            onPressed: _showDifficultyDialog,
          ),
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            tooltip: _isPaused ? 'Resume' : 'Pause',
            onPressed: _isPaused ? _handleResume : _handlePause,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Restart Puzzle',
            onPressed: _handleRestart,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isPaused
              ? _buildPausedOverlay()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Sudoku Board
                    Expanded(
                      flex: 2,
                      child: Center(
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
                    const SizedBox(height: 24),
                    // Number Pad
                    Expanded(
                      child: NumberPadWidget(
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
        ),
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
          const SizedBox(height: 16),
          Text(
            'Tap Resume to continue',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _handleResume,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume Game'),
          ),
        ],
      ),
    );
  }
}

/// Widget that displays the game timer with real-time updates
class TimerDisplay extends StatefulWidget {
  const TimerDisplay({required this.timer, super.key});

  final GameTimer timer;

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
            const Icon(Icons.timer_outlined, size: 20),
            const SizedBox(width: 4),
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
