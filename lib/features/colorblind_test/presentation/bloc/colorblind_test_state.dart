import 'package:equatable/equatable.dart';
import '../../domain/entities/ishihara_plate.dart';
import '../../domain/entities/test_result_entity.dart';

abstract class ColorblindTestState extends Equatable {
  const ColorblindTestState();

  @override
  List<Object?> get props => [];
}

class ColorblindTestInitial extends ColorblindTestState {
  const ColorblindTestInitial();
}

class ColorblindTestLoading extends ColorblindTestState {
  const ColorblindTestLoading();
}

class ColorblindTestInProgress extends ColorblindTestState {
  final List<IshiharaPlate> plates;
  final int currentIndex; // 0 to 11
  final Map<int, String> answers;

  const ColorblindTestInProgress({
    required this.plates,
    required this.currentIndex,
    required this.answers,
  });

  IshiharaPlate get currentPlate => plates[currentIndex];
  int get currentNumber => currentIndex + 1;
  int get totalPlates => plates.length;
  double get progress => (currentIndex + 1) / plates.length;
  bool get isLastPlate => currentIndex == plates.length - 1;

  @override
  List<Object?> get props => [plates, currentIndex, answers];
}

class ColorblindTestAnalyzing extends ColorblindTestState {
  const ColorblindTestAnalyzing();
}

class ColorblindTestCompleted extends ColorblindTestState {
  final TestResultEntity result;

  const ColorblindTestCompleted(this.result);

  @override
  List<Object?> get props => [result];
}

class ColorblindTestError extends ColorblindTestState {
  final String message;

  const ColorblindTestError(this.message);

  @override
  List<Object?> get props => [message];
}
