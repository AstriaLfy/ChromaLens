import 'package:equatable/equatable.dart';

class IshiharaPlate extends Equatable {
  final int id;
  final String numberText;
  final List<String> options;
  final String correctAnswer;
  final String description;
  final String? imageUrl;

  const IshiharaPlate({
    required this.id,
    required this.numberText,
    required this.options,
    required this.correctAnswer,
    this.description = '',
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, numberText, options, correctAnswer, description, imageUrl];
}
