import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
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

class _GameScreenState extends State<GameScreen> {
  final _generator = PuzzleGenerator();
  late var _board = _generator.generatePuzzle(Difficulty.easy);
  int? _selectedRow;
  int? _selectedCol;

  void _handleNumberSelected(int number) {
    if (_selectedRow == null || _selectedCol == null) {
      return;
    }

    // Don't allow input on fixed cells
    if (_board.cells[_selectedRow!][_selectedCol!].isFixed) {
      return;
    }

    setState(() {
      _board = _board.setCell(_selectedRow!, _selectedCol!, number);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _board = _generator.generatePuzzle(Difficulty.easy);
                _selectedRow = null;
                _selectedCol = null;
              });
            },
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
