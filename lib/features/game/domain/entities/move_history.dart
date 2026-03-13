import 'package:sudoku/features/game/domain/entities/move.dart';

/// Manages move history for undo/redo functionality
/// Uses two stacks: undo stack and redo stack
class MoveHistory {
  /// Creates a move history with optional max size limit
  /// [maxSize] limits the number of moves stored (default: 100)
  MoveHistory({this.maxSize = 100});

  /// Maximum number of moves to store
  final int maxSize;

  final List<Move> _undoStack = [];
  final List<Move> _redoStack = [];

  /// Returns true if undo operation is available
  bool get canUndo => _undoStack.isNotEmpty;

  /// Returns true if redo operation is available
  bool get canRedo => _redoStack.isNotEmpty;

  /// Pushes a new move onto the undo stack
  /// Clears the redo stack (new moves invalidate redo history)
  /// Removes oldest move if stack exceeds maxSize
  void push(Move move) {
    _undoStack.add(move);
    _redoStack.clear();

    // Remove oldest moves if we exceed max size
    while (_undoStack.length > maxSize) {
      _undoStack.removeAt(0);
    }
  }

  /// Undoes the last move
  /// Returns the undone move, or null if undo stack is empty
  /// Moves the undone move to the redo stack
  Move? undo() {
    if (!canUndo) {
      return null;
    }

    final move = _undoStack.removeLast();
    _redoStack.add(move);
    return move;
  }

  /// Redoes a previously undone move
  /// Returns the redone move, or null if redo stack is empty
  /// Moves the redone move back to the undo stack
  Move? redo() {
    if (!canRedo) {
      return null;
    }

    final move = _redoStack.removeLast();
    _undoStack.add(move);
    return move;
  }

  /// Clears both undo and redo stacks
  /// Used when starting a new puzzle
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
