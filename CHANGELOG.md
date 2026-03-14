# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Modern Dark Theme**: New darkModernTheme with Tailwind colors (#137FEC primary, #0A0A0A background, #1C1C1E charcoal)
- **3x3 Number Pad Grid**: Calculator-style number input layout replacing horizontal row
- **Game Control Bar**: Bottom bar with Undo, Notes, Hint, and Erase buttons
- **Smart Hint System**: AI-powered hints that find cells with fewest candidates
  - Difficulty-based limits: Easy (unlimited), Medium (5), Hard (3), Expert (1)
  - Hint dialog shows cell location and possible values
  - Hint counter badge on control bar button
- **Purple Influence Highlighting**: Selected cell highlights its row, column, and 3x3 box with purple tint
- **Erase Functionality**: Clear cell value and notes with single button (control bar)
- **Enhanced Pause Menu**: Access to Restart, New Game, and Statistics from pause screen

### Changed
- **Simplified AppBar**: Reduced from 7+ buttons to 3 (Timer, Pause, Settings)
- **Layout Restructure**: Board (flexible) → Control Bar → Number Pad (fixed height)
- **Theme System**: Added darkModern as default theme option
- **Board Styling**: Updated cell highlighting with purple influence for better visual feedback
- **Difficulty Ranges**: Fixed and improved clue counts based on Sudoku mathematics
  - Easy: 45-50 clues (was 40-45)
  - Medium: 35-40 clues (was 45-50)
  - Hard: 27-32 clues (was 50-55)
  - Expert: 22-26 clues (was 55-60)

### Fixed
- Difficulty levels were inverted (Expert was easier than Easy) - now uses correct clue ranges

### Technical
- Added HintService with candidate calculation algorithm
- Added Hint entity (row, col, candidates)
- Created NumberPadGridWidget with 3x3 grid layout
- Created GameControlBar widget with state management
- 21 new tests (11 hint service, 4 widget, 6 integration)
- Total test count: 175 (100% passing)

## 0.5.0 - 2026-03-13
## 0.4.0 - 2026-03-13
## 0.3.2 - 2026-03-13
## 0.3.1 - 2026-03-13
## 0.3.0 - 2026-03-13
## 0.2.0 - 2026-03-12
### Added
- Initial project setup with Flutter
- Semantic versioning automation with Cider
- GitHub Actions workflow for automatic version bumping
- Project requirements specification
- Copilot instructions for development
