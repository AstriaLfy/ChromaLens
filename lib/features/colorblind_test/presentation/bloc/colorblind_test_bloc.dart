import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/analyze_test_result_usecase.dart';
import '../../domain/usecases/get_test_plates_usecase.dart';
import 'colorblind_test_event.dart';
import 'colorblind_test_state.dart';

class ColorblindTestBloc extends Bloc<ColorblindTestEvent, ColorblindTestState> {
  final GetTestPlatesUseCase getPlatesUseCase;
  final AnalyzeTestResultUseCase analyzeResultUseCase;

  ColorblindTestBloc({
    required this.getPlatesUseCase,
    required this.analyzeResultUseCase,
  }) : super(const ColorblindTestInitial()) {
    on<StartColorblindTest>(_onStartTest);
    on<SelectPlateAnswer>(_onSelectAnswer);
    on<PreviousPlateRequested>(_onPreviousPlate);
    on<SubmitTestRequested>(_onSubmitTest);
    on<ResetTestRequested>(_onResetTest);
  }

  Future<void> _onStartTest(
    StartColorblindTest event,
    Emitter<ColorblindTestState> emit,
  ) async {
    emit(const ColorblindTestLoading());

    final result = await getPlatesUseCase();

    result.fold(
      (failure) => emit(ColorblindTestError(failure.message)),
      (plates) => emit(ColorblindTestInProgress(
        plates: plates,
        currentIndex: 0,
        answers: const {},
      )),
    );
  }

  Future<void> _onSelectAnswer(
    SelectPlateAnswer event,
    Emitter<ColorblindTestState> emit,
  ) async {
    if (state is! ColorblindTestInProgress) return;

    final current = state as ColorblindTestInProgress;
    final updatedAnswers = Map<int, String>.from(current.answers);
    updatedAnswers[event.plateId] = event.answer;

    if (current.isLastPlate) {
      // Selesai 12 lempeng -> Jalankan analisis
      emit(const ColorblindTestAnalyzing());
      final result = await analyzeResultUseCase(updatedAnswers);

      result.fold(
        (failure) => emit(ColorblindTestError(failure.message)),
        (testResult) => emit(ColorblindTestCompleted(testResult)),
      );
    } else {
      // Lanjut ke lempeng berikutnya
      emit(ColorblindTestInProgress(
        plates: current.plates,
        currentIndex: current.currentIndex + 1,
        answers: updatedAnswers,
      ));
    }
  }

  void _onPreviousPlate(
    PreviousPlateRequested event,
    Emitter<ColorblindTestState> emit,
  ) {
    if (state is! ColorblindTestInProgress) return;

    final current = state as ColorblindTestInProgress;
    if (current.currentIndex > 0) {
      emit(ColorblindTestInProgress(
        plates: current.plates,
        currentIndex: current.currentIndex - 1,
        answers: current.answers,
      ));
    }
  }

  Future<void> _onSubmitTest(
    SubmitTestRequested event,
    Emitter<ColorblindTestState> emit,
  ) async {
    if (state is! ColorblindTestInProgress) return;

    final current = state as ColorblindTestInProgress;
    emit(const ColorblindTestAnalyzing());

    final result = await analyzeResultUseCase(current.answers);

    result.fold(
      (failure) => emit(ColorblindTestError(failure.message)),
      (testResult) => emit(ColorblindTestCompleted(testResult)),
    );
  }

  void _onResetTest(
    ResetTestRequested event,
    Emitter<ColorblindTestState> emit,
  ) {
    add(const StartColorblindTest());
  }
}
