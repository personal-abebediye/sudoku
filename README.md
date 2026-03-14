# Sudoku

A full-featured cross-platform Sudoku game built with Flutter.

## Features

### ✅ Implemented
- 🎮 **Core Gameplay**: Classic 9x9 Sudoku with four difficulty levels (Easy, Medium, Hard, Expert)
- 🎨 **Modern Dark Theme**: Tailwind-inspired color scheme with purple influence highlighting
- 📱 **Intuitive 3x3 Number Pad**: Calculator-style input layout for easy number entry
- 💡 **Smart Hint System**: AI-powered hints find the easiest cells to solve
  - Difficulty-based limits (Easy: unlimited, Medium: 5, Hard: 3, Expert: 1)
  - Shows possible values for selected cell
- ✏️ **Pencil Marks (Notes)**: Toggle note-taking mode for tracking candidates
- ↩️ **Undo/Redo**: Full move history with up to 100 moves tracked
- ⏱️ **Timer**: Real-time elapsed time display with auto-pause on app switching
- 🎯 **Error Detection**: Real-time validation with visual error highlighting
- 💾 **Auto-Save**: Game state persists automatically
- 📊 **Statistics**: Track completed puzzles, times, and streaks
- ⚙️ **Settings**: Customizable game preferences and themes
- 🎓 **Tutorial**: Interactive tutorial for new players
- 🎮 **Game Controls**:
  - Undo: Revert moves
  - Notes: Toggle pencil mark mode
  - Hint: Get smart help when stuck
  - Erase: Clear cell value and notes
  - Pause: Pause game with quick menu access
  - Restart: Reset current puzzle
  - New Game: Start fresh with difficulty selection

### 🎨 Design Highlights
- **Purple Influence Highlighting**: Selected cell highlights its row, column, and 3x3 box
- **Simplified AppBar**: Clean interface with Timer, Pause, and Settings
- **Control Bar**: Quick access to game actions at the bottom
- **Responsive Layout**: Optimized for different screen sizes
- **Theme Options**: Light, Dark, Dark Modern, High Contrast, System

### 🚧 Planned
- 🏆 **Achievements**: Unlock badges for accomplishments
- 📅 **Daily Challenges**: Fresh puzzles every day
- ☁️ **Cloud Sync**: Optional cross-device progress sync
- 🌐 **Multi-Platform Builds**: iOS, Android, Web, macOS, Windows, Linux

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher

### Installation

```bash
# Clone the repository
git clone https://github.com/abebediye/sudoku.git
cd sudoku

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Development

See [.github/copilot-instructions.md](.github/copilot-instructions.md) for detailed development guidelines.

### Quick Commands

```bash
# Run tests (TDD workflow)
flutter test --watch                    # Continuous testing during development
flutter test path/to/test_file.dart    # Run specific test

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
flutter format .
```

## Versioning

This project uses automated semantic versioning based on [Conventional Commits](https://www.conventionalcommits.org/). See [documentation/VERSIONING.md](documentation/VERSIONING.md) for details.

## Documentation

- [Project Requirements](documentation/PROJECT_REQUIREMENTS.md) - Full requirements specification
- [TDD Guide](documentation/TDD_GUIDE.md) - Test-Driven Development workflow and examples
- [Git Workflow](documentation/GIT_WORKFLOW.md) - Trunk-based development workflow
- [Versioning Guide](documentation/VERSIONING.md) - Commit conventions and version management
- [Copilot Instructions](.github/copilot-instructions.md) - Development guidelines

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Status

**Current Phase**: Feature Complete (Core Game)  
**Version**: 0.6.0 (unreleased)  
**Test Coverage**: 175 tests passing (100%)

### Recent Updates
- ✅ Modern UI redesign with dark theme
- ✅ Smart hint system implementation
- ✅ 3x3 number pad grid layout
- ✅ Enhanced game controls and UX  
**Next Milestone**: MVP (Core Gameplay)
