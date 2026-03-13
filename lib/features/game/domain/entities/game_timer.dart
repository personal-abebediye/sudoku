/// Tracks elapsed time for a Sudoku game
/// Supports start, pause, resume, and reset operations
class GameTimer {
  /// Creates a new game timer starting at zero
  GameTimer();

  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  bool _isRunning = false;

  /// Returns the current elapsed time
  Duration get elapsed {
    if (_isRunning && _startTime != null) {
      return _elapsed + DateTime.now().difference(_startTime!);
    }
    return _elapsed;
  }

  /// Returns true if the timer is currently running
  bool get isRunning => _isRunning;

  /// Starts the timer
  /// If already running, this is a no-op
  void start() {
    if (_isRunning) {
      return;
    }

    _startTime = DateTime.now();
    _isRunning = true;
  }

  /// Pauses the timer
  /// Accumulated elapsed time is preserved
  void pause() {
    if (!_isRunning) {
      return;
    }

    if (_startTime != null) {
      _elapsed = _elapsed + DateTime.now().difference(_startTime!);
      _startTime = null;
    }
    _isRunning = false;
  }

  /// Resumes the timer after a pause
  /// If never started, this is a no-op
  void resume() {
    if (_isRunning || _elapsed == Duration.zero) {
      return;
    }

    _startTime = DateTime.now();
    _isRunning = true;
  }

  /// Resets the timer to zero and stops it
  void reset() {
    _elapsed = Duration.zero;
    _startTime = null;
    _isRunning = false;
  }

  /// Formats the elapsed time as MM:SS or HH:MM:SS
  /// Returns MM:SS for times under 1 hour
  /// Returns HH:MM:SS for times 1 hour or longer
  String format() {
    final duration = elapsed;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Sets elapsed time for testing purposes
  /// Should only be used in tests
  void setElapsedForTesting(Duration duration) {
    _elapsed = duration;
  }
}
