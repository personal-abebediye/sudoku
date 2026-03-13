import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/entities/game_timer.dart';

void main() {
  group('GameTimer', () {
    late GameTimer timer;

    setUp(() {
      timer = GameTimer();
    });

    test('should start with zero elapsed time', () {
      expect(timer.elapsed, equals(Duration.zero));
      expect(timer.isRunning, isFalse);
    });

    test('should start timer', () {
      timer.start();

      expect(timer.isRunning, isTrue);
    });

    test('should pause timer', () {
      timer
        ..start()
        ..pause();

      expect(timer.isRunning, isFalse);
    });

    test('should resume timer after pause', () {
      timer
        ..start()
        ..pause()
        ..resume();

      expect(timer.isRunning, isTrue);
    });

    test('should reset timer to zero', () {
      timer
        ..start()
        ..pause()
        ..reset();

      expect(timer.elapsed, equals(Duration.zero));
      expect(timer.isRunning, isFalse);
    });

    test('should accumulate elapsed time when running', () async {
      timer.start();
      await Future.delayed(const Duration(milliseconds: 100));
      timer.pause();

      expect(timer.elapsed.inMilliseconds, greaterThan(50));
    });

    test('should not accumulate time when paused', () async {
      timer.start();
      await Future.delayed(const Duration(milliseconds: 50));
      timer.pause();

      final elapsedAfterPause = timer.elapsed;
      await Future.delayed(const Duration(milliseconds: 50));

      expect(timer.elapsed, equals(elapsedAfterPause));
    });

    test('should accumulate time across pause/resume cycles', () async {
      timer.start();
      await Future.delayed(const Duration(milliseconds: 50));
      timer.pause();

      final firstElapsed = timer.elapsed;

      timer.resume();
      await Future.delayed(const Duration(milliseconds: 50));
      timer.pause();

      expect(timer.elapsed, greaterThan(firstElapsed));
    });

    test('should format duration as MM:SS for times under 1 hour', () {
      timer
        ..start()
        // Simulate 5 minutes 23 seconds
        ..setElapsedForTesting(const Duration(minutes: 5, seconds: 23));

      expect(timer.format(), equals('05:23'));
    });

    test('should format duration as HH:MM:SS for times over 1 hour', () {
      timer
        ..start()
        // Simulate 1 hour 23 minutes 45 seconds
        ..setElapsedForTesting(
          const Duration(hours: 1, minutes: 23, seconds: 45),
        );

      expect(timer.format(), equals('1:23:45'));
    });

    test('should format zero duration correctly', () {
      expect(timer.format(), equals('00:00'));
    });

    test('should handle multiple start calls without error', () {
      timer
        ..start()
        ..start(); // Second start should be no-op

      expect(timer.isRunning, isTrue);
    });

    test('should handle multiple pause calls without error', () {
      timer
        ..start()
        ..pause()
        ..pause(); // Second pause should be no-op

      expect(timer.isRunning, isFalse);
    });

    test('should handle resume without start', () {
      timer.resume();

      expect(timer.isRunning, isFalse);
    });

    test('should reset running timer', () {
      timer
        ..start()
        ..reset();

      expect(timer.elapsed, equals(Duration.zero));
      expect(timer.isRunning, isFalse);
    });
  });
}
