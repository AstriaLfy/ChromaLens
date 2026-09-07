import 'package:flutter_test/flutter_test.dart';

import 'package:chroma_lens/features/colorblind_test/data/datasources/colorblind_test_data_source.dart';
import 'package:chroma_lens/features/colorblind_test/data/repositories/colorblind_test_repository_impl.dart';
import 'package:chroma_lens/features/colorblind_test/domain/usecases/analyze_test_result_usecase.dart';
import 'package:chroma_lens/features/colorblind_test/domain/usecases/get_test_plates_usecase.dart';
import 'package:chroma_lens/features/colorblind_test/presentation/bloc/colorblind_test_bloc.dart';
import 'package:chroma_lens/features/colorblind_test/presentation/bloc/colorblind_test_event.dart';
import 'package:chroma_lens/features/colorblind_test/presentation/bloc/colorblind_test_state.dart';

void main() {
  late ColorblindTestBloc bloc;
  late LocalColorblindTestDataSourceImpl dataSource;
  late ColorblindTestRepositoryImpl repository;

  setUp(() {
    dataSource = LocalColorblindTestDataSourceImpl();
    repository = ColorblindTestRepositoryImpl(dataSource: dataSource);
    bloc = ColorblindTestBloc(
      getPlatesUseCase: GetTestPlatesUseCase(repository),
      analyzeResultUseCase: AnalyzeTestResultUseCase(repository),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be ColorblindTestInitial', () {
    expect(bloc.state, const ColorblindTestInitial());
  });

  test('StartColorblindTest loads 12 plates and emits InProgress', () async {
    final expected = [
      const ColorblindTestLoading(),
      isA<ColorblindTestInProgress>().having(
        (s) => s.totalPlates,
        'totalPlates',
        12,
      ),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    bloc.add(const StartColorblindTest());
  });

  test('SelectPlateAnswer progresses through plates and completes test', () async {
    // Start test
    bloc.add(const StartColorblindTest());
    await Future.delayed(const Duration(milliseconds: 350));

    // Answer plate 1 (correct answer: '12')
    bloc.add(const SelectPlateAnswer(plateId: 1, answer: '12'));
    await Future.delayed(const Duration(milliseconds: 50));

    expect(bloc.state, isA<ColorblindTestInProgress>());
    final inProgress = bloc.state as ColorblindTestInProgress;
    expect(inProgress.currentIndex, 1);
    expect(inProgress.answers[1], '12');
  });

  test('Clinical evaluation evaluates Deuteranomaly for partial scores', () async {
    // Answers with 9 correct, 3 wrong (matching the screenshot "9/12")
    final answers = <int, String>{
      1: '12',
      2: '8',
      3: '6',
      4: '29',
      5: '57',
      6: '5',
      7: '3',
      8: '15',
      9: '74',
      10: 'Tidak Melihat Angka',
      11: 'Tidak Melihat Angka',
      12: 'Tidak Melihat Angka',
    };

    final result = await dataSource.analyzeAnswers(answers);

    expect(result.diagnosis, 'Deuteranomaly');
    expect(result.correctCount, 9);
    expect(result.totalQuestions, 12);
    expect(result.affectedColors, 'Merah dan Hijau');
    expect(result.scoreFormatted, '9/12');
  });

  test('Clinical evaluation evaluates Normal Vision for 11+ correct', () async {
    final answers = <int, String>{
      1: '12',
      2: '8',
      3: '6',
      4: '29',
      5: '57',
      6: '5',
      7: '3',
      8: '15',
      9: '74',
      10: '2',
      11: '6',
      12: '26',
    };

    final result = await dataSource.analyzeAnswers(answers);

    expect(result.diagnosis, 'Penglihatan Normal');
    expect(result.correctCount, 12);
    expect(result.affectedColors, 'Tidak Ada');
  });
}
