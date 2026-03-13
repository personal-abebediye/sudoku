/// Test helper utilities for the Sudoku app.
///
/// This file contains common test utilities, matchers, and helper functions
/// used across multiple test files.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a widget and settles all animations.
///
/// Useful for widget tests to ensure all animations complete.
Future<void> pumpAndSettleWidget(
  WidgetTester tester,
  Widget widget,
) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

/// Custom matcher for verifying Sudoku board dimensions.
Matcher isValidBoardSize(int expectedSize) => predicate<List<List<int>>>(
      (board) =>
          board.length == expectedSize &&
          board.every((row) => row.length == expectedSize),
      'is a ${expectedSize}x$expectedSize board',
    );

/// Custom matcher for checking if a board is empty (all zeros).
Matcher isEmptyBoard() => predicate<List<List<int>>>(
      (board) => board.every((row) => row.every((cell) => cell == 0)),
      'is an empty board (all cells are 0)',
    );

/// Custom matcher for checking if a number is a valid Sudoku value (1-9).
Matcher isValidSudokuNumber() => predicate<int>(
      (number) => number >= 1 && number <= 9,
      'is a valid Sudoku number (1-9)',
    );
