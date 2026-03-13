import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/entities/tutorial_step.dart';

void main() {
  group('TutorialStep', () {
    test('should create with required fields', () {
      const step = TutorialStep(
        title: 'Welcome',
        description: 'Learn Sudoku basics',
        stepNumber: 1,
      );

      expect(step.title, 'Welcome');
      expect(step.description, 'Learn Sudoku basics');
      expect(step.stepNumber, 1);
      expect(step.highlightWidget, null);
    });

    test('should create with highlight widget', () {
      const step = TutorialStep(
        title: 'Number Pad',
        description: 'Tap a number to select',
        stepNumber: 2,
        highlightWidget: 'number_pad',
      );

      expect(step.highlightWidget, 'number_pad');
    });

    test('should serialize to JSON', () {
      const step = TutorialStep(
        title: 'Test',
        description: 'Test description',
        stepNumber: 1,
        highlightWidget: 'test_widget',
      );
      final json = step.toJson();

      expect(json['title'], 'Test');
      expect(json['description'], 'Test description');
      expect(json['stepNumber'], 1);
      expect(json['highlightWidget'], 'test_widget');
    });

    test('should deserialize from JSON', () {
      final json = {
        'title': 'Test',
        'description': 'Test description',
        'stepNumber': 2,
        'highlightWidget': 'test_widget',
      };
      final step = TutorialStep.fromJson(json);

      expect(step.title, 'Test');
      expect(step.description, 'Test description');
      expect(step.stepNumber, 2);
      expect(step.highlightWidget, 'test_widget');
    });

    test('should handle null highlight widget in JSON', () {
      final json = {
        'title': 'Test',
        'description': 'Test description',
        'stepNumber': 1,
      };
      final step = TutorialStep.fromJson(json);

      expect(step.highlightWidget, null);
    });
  });
}
