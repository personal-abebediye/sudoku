import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/features/game/domain/entities/tutorial_step.dart';

// ignore_for_file: prefer_int_literals

/// Interactive tutorial screen for onboarding
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentStep = 0;

  static const _tutorialSteps = [
    TutorialStep(
      title: 'Welcome to Sudoku!',
      description:
          'Sudoku is a logic puzzle where you fill a 9x9 grid with numbers 1-9. '
          'Each row, column, and 3x3 box must contain all digits from 1 to 9 without repeating.',
      stepNumber: 1,
    ),
    TutorialStep(
      title: 'How to Play',
      description:
          'Tap any empty cell to select it, then tap a number from the number pad '
          'to fill it in. Your goal is to complete the entire grid!',
      stepNumber: 2,
      highlightWidget: 'board',
    ),
    TutorialStep(
      title: 'Number Pad',
      description:
          'Use the number pad to enter numbers. The number pad shows counts of how many '
          'times each number appears on the board.',
      stepNumber: 3,
      highlightWidget: 'number_pad',
    ),
    TutorialStep(
      title: 'Pencil Marks',
      description:
          'Toggle notes mode to add small numbers as reminders. This helps you track '
          'possible candidates for each cell.',
      stepNumber: 4,
      highlightWidget: 'notes_button',
    ),
    TutorialStep(
      title: 'Error Checking',
      description:
          'If auto-check is enabled, cells with conflicts will be highlighted in red. '
          'Fix these errors to complete the puzzle!',
      stepNumber: 5,
    ),
    TutorialStep(
      title: 'Undo & Redo',
      description:
          'Made a mistake? Use undo and redo buttons to correct your moves. '
          'You can undo up to 100 moves!',
      stepNumber: 6,
      highlightWidget: 'undo_redo',
    ),
    TutorialStep(
      title: 'Game Controls',
      description:
          'Use the toolbar to start a new game, pause/resume, restart, and access '
          'your statistics and settings.',
      stepNumber: 7,
      highlightWidget: 'toolbar',
    ),
    TutorialStep(
      title: 'You\'re Ready!',
      description:
          'That\'s all you need to know! Start playing and enjoy solving Sudoku puzzles. '
          'You can replay this tutorial anytime from Settings.',
      stepNumber: 8,
    ),
  ];

  Future<void> _markTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
  }

  void _nextStep() {
    if (_currentStep < _tutorialSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _finishTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _skipTutorial() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Tutorial'),
        content: const Text(
          'Are you sure you want to skip the tutorial? You can replay it anytime from Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _finishTutorial();
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  void _finishTutorial() {
    _markTutorialComplete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final step = _tutorialSteps[_currentStep];
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == _tutorialSteps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _skipTutorial,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / _tutorialSteps.length,
              ),
              const SizedBox(height: 24),

              // Step counter
              Text(
                'Step ${step.stepNumber} of ${_tutorialSteps.length}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                step.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              // Description
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Navigation buttons
              Row(
                children: [
                  if (!isFirstStep)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Back'),
                      ),
                    ),
                  if (!isFirstStep) const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _nextStep,
                      child: Text(isLastStep ? 'Finish' : 'Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
