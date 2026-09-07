import 'package:equatable/equatable.dart';

abstract class ColorblindTestEvent extends Equatable {
  const ColorblindTestEvent();

  @override
  List<Object?> get props => [];
}

class StartColorblindTest extends ColorblindTestEvent {
  const StartColorblindTest();
}

class SelectPlateAnswer extends ColorblindTestEvent {
  final int plateId;
  final String answer;

  const SelectPlateAnswer({
    required this.plateId,
    required this.answer,
  });

  @override
  List<Object?> get props => [plateId, answer];
}

class PreviousPlateRequested extends ColorblindTestEvent {
  const PreviousPlateRequested();
}

class SubmitTestRequested extends ColorblindTestEvent {
  const SubmitTestRequested();
}

class ResetTestRequested extends ColorblindTestEvent {
  const ResetTestRequested();
}
