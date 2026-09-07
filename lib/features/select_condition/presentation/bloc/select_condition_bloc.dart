import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/save_condition_usecase.dart';
import 'select_condition_event.dart';
import 'select_condition_state.dart';

class SelectConditionBloc extends Bloc<SelectConditionEvent, SelectConditionState> {
  final SaveConditionUseCase saveConditionUseCase;

  SelectConditionBloc({required this.saveConditionUseCase})
      : super(const SelectConditionInitial()) {
    on<ConditionChosen>(_onConditionChosen);
    on<ConditionSaved>(_onConditionSaved);
    on<SkipToColorblindTest>(_onSkipToColorblindTest);
  }

  void _onConditionChosen(
    ConditionChosen event,
    Emitter<SelectConditionState> emit,
  ) {
    emit(SelectConditionInitial(selectedCondition: event.condition));
  }

  Future<void> _onConditionSaved(
    ConditionSaved event,
    Emitter<SelectConditionState> emit,
  ) async {
    emit(SelectConditionSaving(event.condition));

    final result = await saveConditionUseCase(event.condition);

    result.fold(
      (failure) => emit(SelectConditionError(failure.message)),
      (_) => emit(SelectConditionSavedSuccess(event.condition)),
    );
  }

  void _onSkipToColorblindTest(
    SkipToColorblindTest event,
    Emitter<SelectConditionState> emit,
  ) {
    emit(const NavigateToTestState());
  }
}
