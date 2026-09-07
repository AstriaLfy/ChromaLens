import 'package:equatable/equatable.dart';

class TestResultEntity extends Equatable {
  final String diagnosis;
  final String description;
  final String affectedColors;
  final String category;
  final DateTime testDate;
  final int correctCount;
  final int totalQuestions;

  const TestResultEntity({
    required this.diagnosis,
    required this.description,
    required this.affectedColors,
    required this.category,
    required this.testDate,
    required this.correctCount,
    this.totalQuestions = 12,
  });

  String get scoreFormatted => '$correctCount/$totalQuestions';

  Map<String, dynamic> toJson() => {
        'diagnosis': diagnosis,
        'description': description,
        'affectedColors': affectedColors,
        'category': category,
        'testDate': testDate.toIso8601String(),
        'correctCount': correctCount,
        'totalQuestions': totalQuestions,
      };

  factory TestResultEntity.fromJson(Map<String, dynamic> json) =>
      TestResultEntity(
        diagnosis: json['diagnosis'] as String? ?? 'Deuteranomaly',
        description: json['description'] as String? ?? '',
        affectedColors: json['affectedColors'] as String? ?? '',
        category: json['category'] as String? ?? '',
        testDate: json['testDate'] != null
            ? DateTime.tryParse(json['testDate'] as String) ?? DateTime.now()
            : DateTime.now(),
        correctCount: json['correctCount'] as int? ?? 0,
        totalQuestions: json['totalQuestions'] as int? ?? 12,
      );

  @override
  List<Object?> get props => [
        diagnosis,
        description,
        affectedColors,
        category,
        testDate,
        correctCount,
        totalQuestions,
      ];
}
