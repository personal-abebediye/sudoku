import 'package:sudoku/shared/providers/theme_provider.dart';

// ignore_for_file: sort_constructors_first

/// User preferences and settings for the game
class UserSettings {
  final bool autoCheckErrors;
  final bool showTimer;
  final bool enableHaptics;
  final bool highlightSameNumbers;
  final bool highlightRow;
  final bool highlightColumn;
  final bool highlightBox;
  final AppThemeMode themeMode;
  final bool numberPadAtBottom;

  const UserSettings({
    this.autoCheckErrors = true,
    this.showTimer = true,
    this.enableHaptics = true,
    this.highlightSameNumbers = true,
    this.highlightRow = true,
    this.highlightColumn = true,
    this.highlightBox = true,
    this.themeMode = AppThemeMode.system,
    this.numberPadAtBottom = true,
  });

  UserSettings copyWith({
    bool? autoCheckErrors,
    bool? showTimer,
    bool? enableHaptics,
    bool? highlightSameNumbers,
    bool? highlightRow,
    bool? highlightColumn,
    bool? highlightBox,
    AppThemeMode? themeMode,
    bool? numberPadAtBottom,
  }) {
    return UserSettings(
      autoCheckErrors: autoCheckErrors ?? this.autoCheckErrors,
      showTimer: showTimer ?? this.showTimer,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      highlightSameNumbers: highlightSameNumbers ?? this.highlightSameNumbers,
      highlightRow: highlightRow ?? this.highlightRow,
      highlightColumn: highlightColumn ?? this.highlightColumn,
      highlightBox: highlightBox ?? this.highlightBox,
      themeMode: themeMode ?? this.themeMode,
      numberPadAtBottom: numberPadAtBottom ?? this.numberPadAtBottom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoCheckErrors': autoCheckErrors,
      'showTimer': showTimer,
      'enableHaptics': enableHaptics,
      'highlightSameNumbers': highlightSameNumbers,
      'highlightRow': highlightRow,
      'highlightColumn': highlightColumn,
      'highlightBox': highlightBox,
      'themeMode': themeMode.name,
      'numberPadAtBottom': numberPadAtBottom,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    AppThemeMode parseThemeMode(String? value) {
      if (value == null) {
        return AppThemeMode.system;
      }
      try {
        return AppThemeMode.values.firstWhere(
          (mode) => mode.name == value,
          orElse: () => AppThemeMode.system,
        );
      } catch (_) {
        return AppThemeMode.system;
      }
    }

    return UserSettings(
      autoCheckErrors: json['autoCheckErrors'] as bool? ?? true,
      showTimer: json['showTimer'] as bool? ?? true,
      enableHaptics: json['enableHaptics'] as bool? ?? true,
      highlightSameNumbers: json['highlightSameNumbers'] as bool? ?? true,
      highlightRow: json['highlightRow'] as bool? ?? true,
      highlightColumn: json['highlightColumn'] as bool? ?? true,
      highlightBox: json['highlightBox'] as bool? ?? true,
      themeMode: parseThemeMode(json['themeMode'] as String?),
      numberPadAtBottom: json['numberPadAtBottom'] as bool? ?? true,
    );
  }
}
