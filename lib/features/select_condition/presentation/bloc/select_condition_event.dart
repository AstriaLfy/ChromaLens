import 'package:equatable/equatable.dart';
import '../../domain/entities/colorblind_condition.dart';

abstract class SelectConditionEvent extends Equatable {
  const SelectConditionEvent();

  @override
  List<Object?> get props => [];
}

class ConditionChosen extends SelectConditionEvent {
  final ColorblindType condition;

  const ConditionChosen(this.condition);

  @override
  List<Object?> get props => [condition];
}

class ConditionSaved extends SelectConditionEvent {
  final ColorblindType condition;

  const ConditionSaved(this.condition);

  @override
  List<Object?> get props => [condition];
}

class SkipToColorblindTest extends SelectConditionEvent {
  const SkipToColorblindTest();
}
