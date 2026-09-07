import 'package:flutter_test/flutter_test.dart';

import 'package:chroma_lens/features/select_condition/data/datasources/condition_remote_data_source.dart';
import 'package:chroma_lens/features/select_condition/data/repositories/condition_repository_impl.dart';
import 'package:chroma_lens/features/select_condition/domain/entities/colorblind_condition.dart';
import 'package:chroma_lens/features/select_condition/domain/usecases/save_condition_usecase.dart';
import 'package:chroma_lens/features/select_condition/presentation/bloc/select_condition_bloc.dart';
import 'package:chroma_lens/features/select_condition/presentation/bloc/select_condition_event.dart';
import 'package:chroma_lens/features/select_condition/presentation/bloc/select_condition_state.dart';

void main() {
  late SelectConditionBloc bloc;
  late DummyConditionRemoteDataSourceImpl dataSource;
  late ConditionRepositoryImpl repository;

  setUp(() {
    dataSource = DummyConditionRemoteDataSourceImpl();
    repository = ConditionRepositoryImpl(remoteDataSource: dataSource);
    bloc = SelectConditionBloc(
      saveConditionUseCase: SaveConditionUseCase(repository),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be SelectConditionInitial', () {
    expect(bloc.state, const SelectConditionInitial());
  });

  test('ConditionChosen emits SelectConditionInitial with selectedCondition', () {
    bloc.add(const ConditionChosen(ColorblindType.protanopia));

    expectLater(
      bloc.stream,
      emits(const SelectConditionInitial(
        selectedCondition: ColorblindType.protanopia,
      )),
    );
  });

  test('ConditionSaved emits [Saving, SavedSuccess] on success', () async {
    final expected = [
      const SelectConditionSaving(ColorblindType.deuteranopia),
      const SelectConditionSavedSuccess(ColorblindType.deuteranopia),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    bloc.add(const ConditionSaved(ColorblindType.deuteranopia));
  });

  test('SkipToColorblindTest emits NavigateToTestState', () {
    bloc.add(const SkipToColorblindTest());

    expectLater(
      bloc.stream,
      emits(const NavigateToTestState()),
    );
  });
}
