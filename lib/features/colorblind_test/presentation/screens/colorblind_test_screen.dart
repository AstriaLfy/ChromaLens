import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/presentation/widgets/auth_back_button.dart';
import '../bloc/colorblind_test_bloc.dart';
import '../bloc/colorblind_test_event.dart';
import '../bloc/colorblind_test_state.dart';
import '../widgets/ishihara_plate_widget.dart';
import '../widgets/test_option_button.dart';

class ColorblindTestScreen extends StatefulWidget {
  const ColorblindTestScreen({super.key});

  @override
  State<ColorblindTestScreen> createState() => _ColorblindTestScreenState();
}

class _ColorblindTestScreenState extends State<ColorblindTestScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ColorblindTestBloc>().add(const StartColorblindTest());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<ColorblindTestBloc, ColorblindTestState>(
          listener: (context, state) {
            if (state is ColorblindTestCompleted) {
              sl<TokenStorage>().saveTestResult(state.result);
              Navigator.pushReplacementNamed(
                context,
                '/test_result',
                arguments: state.result,
              );
            } else if (state is ColorblindTestError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ColorblindTestLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.brandPurple,
                ),
              );
            }

            if (state is ColorblindTestAnalyzing) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.brandPurple,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Menganalisis hasil tes...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPurple,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is! ColorblindTestInProgress) {
              return const SizedBox.shrink();
            }

            final plate = state.currentPlate;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Navigation Bar: Back | Title | Pill Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AuthBackButton(
                        onPressed: () {
                          if (state.currentIndex > 0) {
                            context
                                .read<ColorblindTestBloc>()
                                .add(const PreviousPlateRequested());
                          } else {
                            Navigator.maybePop(context);
                          }
                        },
                      ),
                      const Text(
                        'Tes Buta Warna',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${state.currentNumber} / ${state.totalPlates}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Linear Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE5E5EA),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.brandPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Question Title
                  const Text(
                    'Angka berapa yang anda lihat?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ishihara Plate Canvas (loads real image from backend if available)
                  IshiharaPlateWidget(
                    numberText: plate.numberText,
                    imageUrl: plate.imageUrl,
                    size: 240,
                  ),
                  const SizedBox(height: 28),

                  // Answer Options
                  ...plate.options.map((option) {
                    final isSelected = state.answers[plate.id] == option;
                    return TestOptionButton(
                      text: option,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<ColorblindTestBloc>().add(
                              SelectPlateAnswer(
                                plateId: plate.id,
                                answer: option,
                              ),
                            );
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
