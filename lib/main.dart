import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
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
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final _generator = PuzzleGenerator();
  final _moveHistory = MoveHistory();
  final _gameTimer = GameTimer();
  late var _board = _generator.generatePuzzle(Difficulty.easy);
  int? _selectedRow;
  int? _selectedCol;
  Set<String> _errorCells = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gameTimer.start(); // Start timer when game loads
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
    }
    // Resume timer when app comes back to foreground
    else if (state == AppLifecycleState.resumed) {
      _gameTimer.resume();
    }
  }

  void _updateErrors() {
    final errors = <String>{};
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (_board.hasConflict(row, col)) {
          errors.add('$row,$col');
        }
      }
    }
    _errorCells = errors;
  }

  void _handleNumberSelected(int number) {
    if (_selectedRow == null || _selectedCol == null) {
      return;
    }

    final row = _selectedRow!;
    final col = _selectedCol!;

    // Don't allow input on fixed cells
    if (_board.cells[row][col].isFixed) {
      return;
    }

    final oldValue = _board.cells[row][col].value;

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
      _board = _board.setCell(row, col, number);
      _updateErrors();
    });
  }

  void _handleUndo() {
    final move = _moveHistory.undo();
    if (move == null) {
      return;
    }

    setState(() {
      _board = _board.setCell(move.row, move.col, move.oldValue);
      _updateErrors();
    });
  }

  void _handleRedo() {
    final move = _moveHistory.redo();
    if (move == null) {
      return;
    }

    setState(() {
      _board = _board.setCell(move.row, move.col, move.newValue);
      _updateErrors();
    });
  }

  void _handleRefresh() {
    setState(() {
      _board = _generator.generatePuzzle(Difficulty.easy);
      _selectedRow = null;
      _selectedCol = null;
      _errorCells = {};
      _moveHistory.clear(); // Clear history when starting new puzzle
      _gameTimer
        ..reset() // Reset timer when starting new puzzle
        ..start(); // Start fresh timer
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
        actions: [
          // Timer Display
          TimerDisplay(timer: _gameTimer),
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
            icon: const Icon(Icons.refresh),
            tooltip: 'New Puzzle',
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sudoku Board
              Expanded(
                flex: 2,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: SudokuBoardWidget(
                      board: _board,
                      selectedRow: _selectedRow,
                      selectedCol: _selectedCol,
                      errorCells: _errorCells,
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
                  selectedNumber: _selectedRow != null && _selectedCol != null
                      ? _board.cells[_selectedRow!][_selectedCol!].value
                      : null,
                ),
              ),
            ],
          ),
        ),
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
