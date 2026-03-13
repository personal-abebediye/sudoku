import 'dart:convert';
import 'package:sudoku/features/game/domain/entities/board.dart';
import 'package:sudoku/features/game/domain/entities/cell.dart';
import 'package:sudoku/features/game/domain/services/puzzle_generator.dart';

/// Represents a saved game state that can be persisted
class GameState {
  GameState({
    required this.board,
    required this.originalBoard,
    required this.difficulty,
    required this.elapsedSeconds,
    required this.notes,
  });

  /// Create from JSON
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      board: _boardFromJson(json['board'] as Map<String, dynamic>),
      originalBoard:
          _boardFromJson(json['originalBoard'] as Map<String, dynamic>),
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.easy,
      ),
      elapsedSeconds: json['elapsedSeconds'] as int,
      notes: (json['notes'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((e) => e as int).toSet(),
        ),
      ),
    );
  }

  /// Create from JSON string
  factory GameState.fromJsonString(String jsonString) =>
      GameState.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  final Board board;
  final Board originalBoard;
  final Difficulty difficulty;
  final int elapsedSeconds;
  final Map<String, Set<int>> notes;

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'board': _boardToJson(board),
      'originalBoard': _boardToJson(originalBoard),
      'difficulty': difficulty.name,
      'elapsedSeconds': elapsedSeconds,
      'notes': notes.map((key, value) => MapEntry(key, value.toList())),
    };
  }

  /// Convert to JSON string for storage
  String toJsonString() => jsonEncode(toJson());

  /// Helper: Convert Board to JSON
  static Map<String, dynamic> _boardToJson(Board board) {
    return {
      'cells': List.generate(
        9,
        (row) => List.generate(
          9,
          (col) => {
            'value': board.cells[row][col].value,
            'isFixed': board.cells[row][col].isFixed,
          },
        ),
      ),
    };
  }

  /// Helper: Create Board from JSON
  static Board _boardFromJson(Map<String, dynamic> json) {
    final cellsJson = json['cells'] as List<dynamic>;
    final cells = List.generate(
      9,
      (row) => List.generate(
        9,
        (col) {
          final cellJson = cellsJson[row][col] as Map<String, dynamic>;
          return Cell(
            value: cellJson['value'] as int,
            isFixed: cellJson['isFixed'] as bool,
          );
        },
      ),
    );
    return Board(cells: cells);
  }
}
