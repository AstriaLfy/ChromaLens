import 'package:equatable/equatable.dart';
import '../../domain/entities/colorblind_condition.dart';

abstract class SelectConditionState extends Equatable {
  const SelectConditionState();

  @override
  List<Object?> get props => [];
}

class SelectConditionInitial extends SelectConditionState {
  final ColorblindType? selectedCondition;

  const SelectConditionInitial({this.selectedCondition});

  @override
  List<Object?> get props => [selectedCondition];
}

class SelectConditionSaving extends SelectConditionState {
  final ColorblindType selectedCondition;

  const SelectConditionSaving(this.selectedCondition);

  @override
  List<Object?> get props => [selectedCondition];
}

class SelectConditionSavedSuccess extends SelectConditionState {
  final ColorblindType condition;

  const SelectConditionSavedSuccess(this.condition);

  @override
  List<Object?> get props => [condition];
}

class NavigateToTestState extends SelectConditionState {
  const NavigateToTestState();
}

class SelectConditionError extends SelectConditionState {
  final String message;

  const SelectConditionError(this.message);

  @override
  List<Object?> get props => [message];
}
