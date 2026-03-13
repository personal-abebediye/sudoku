// ignore_for_file: sort_constructors_first

/// A single step in the tutorial sequence
class TutorialStep {
  final String title;
  final String description;
  final int stepNumber;
  final String? highlightWidget;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.stepNumber,
    this.highlightWidget,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'stepNumber': stepNumber,
      'highlightWidget': highlightWidget,
    };
  }

  factory TutorialStep.fromJson(Map<String, dynamic> json) {
    return TutorialStep(
      title: json['title'] as String,
      description: json['description'] as String,
      stepNumber: json['stepNumber'] as int,
      highlightWidget: json['highlightWidget'] as String?,
    );
  }
}
