import 'package:flutter/material.dart';
import 'package:sudoku/features/game/data/services/settings_service.dart';
import 'package:sudoku/features/game/domain/entities/user_settings.dart';
import 'package:sudoku/shared/providers/theme_provider.dart';

// ignore_for_file: prefer_const_constructors, prefer_int_literals, deprecated_member_use

/// Settings screen for user preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService();
  UserSettings _settings = UserSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsService.initialize();
    final settings = await _settingsService.loadSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _updateSettings(UserSettings newSettings) async {
    await _settingsService.saveSettings(newSettings);
    setState(() {
      _settings = newSettings;
    });
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to defaults?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _settingsService.resetSettings();
      await _loadSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetSettings,
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildGameSettingsSection(),
          const Divider(),
          _buildDisplaySettingsSection(),
        ],
      ),
    );
  }

  Widget _buildGameSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Game Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SwitchListTile(
          title: const Text('Auto-check errors'),
          subtitle: const Text('Automatically highlight incorrect numbers'),
          value: _settings.autoCheckErrors,
          onChanged: (value) {
            _updateSettings(_settings.copyWith(autoCheckErrors: value));
          },
        ),
        SwitchListTile(
          title: const Text('Show timer'),
          subtitle: const Text('Display elapsed time while playing'),
          value: _settings.showTimer,
          onChanged: (value) {
            _updateSettings(_settings.copyWith(showTimer: value));
          },
        ),
        SwitchListTile(
          title: const Text('Haptic feedback'),
          subtitle: const Text('Vibrate on button presses'),
          value: _settings.enableHaptics,
          onChanged: (value) {
            _updateSettings(_settings.copyWith(enableHaptics: value));
          },
        ),
      ],
    );
  }

  Widget _buildDisplaySettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Display Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListTile(
          title: const Text('Theme'),
          subtitle: Text(_getThemeLabel(_settings.themeMode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showThemePicker,
        ),
        SwitchListTile(
          title: const Text('Highlight same numbers'),
          subtitle: const Text('Highlight cells with the selected number'),
          value: _settings.highlightSameNumbers,
          onChanged: (value) {
            _updateSettings(_settings.copyWith(highlightSameNumbers: value));
          },
        ),
        SwitchListTile(
          title: const Text('Highlight row'),
          subtitle: const Text('Highlight the selected row'),
          value: _settings.highlightRow,
          onChanged: (value) {
            _updateSettings(_settings.copyWith(highlightRow: value));
          },
        ),
        SwitchListTile(
          title: const Text('Highlight column'),
          subtitle: const Text('Highlight the selected column'),
          value: _settings.highlightColumn,
          onChanged: (value) {
            _updateSettings(_settings.copyWith(highlightColumn: value));
          },
        ),
        SwitchListTile(
          title: const Text('Highlight box'),
          subtitle: const Text('Highlight the selected 3x3 box'),
          value: _settings.highlightBox,
          onChanged: (value) {
            _updateSettings(_settings.copyWith(highlightBox: value));
          },
        ),
        SwitchListTile(
          title: const Text('Number pad at bottom'),
          subtitle: const Text('Show number pad below the board'),
          value: _settings.numberPadAtBottom,
          onChanged: (value) {
            _updateSettings(_settings.copyWith(numberPadAtBottom: value));
          },
        ),
      ],
    );
  }

  String _getThemeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.highContrast:
        return 'High Contrast';
      case AppThemeMode.system:
        return 'System Default';
    }
  }

  Future<void> _showThemePicker() async {
    final selected = await showDialog<AppThemeMode>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppThemeMode.values.map((mode) {
              return RadioListTile<AppThemeMode>(
                title: Text(_getThemeLabel(mode)),
                value: mode,
                groupValue: _settings.themeMode,
                onChanged: (value) {
                  Navigator.of(context).pop(value);
                },
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected != null) {
      await _updateSettings(_settings.copyWith(themeMode: selected));
    }
  }
}
