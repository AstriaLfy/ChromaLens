import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/colorblind_condition.dart';
import '../bloc/select_condition_bloc.dart';
import '../bloc/select_condition_event.dart';
import '../bloc/select_condition_state.dart';

class SelectConditionScreen extends StatefulWidget {
  const SelectConditionScreen({super.key});

  @override
  State<SelectConditionScreen> createState() => _SelectConditionScreenState();
}

class _SelectConditionScreenState extends State<SelectConditionScreen> {
  ColorblindType? _selectedType;

  void _showConditionPicker() {
    showModalBottomSheet<ColorblindType>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D1D6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih Jenis Buta Warna',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                ...ColorblindType.values.map((type) {
                  final isSelected = type == _selectedType;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.brandPurple : AppColors.textDark,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.brandPurple)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx, type);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    ).then((selected) {
      if (selected != null && mounted) {
        setState(() => _selectedType = selected);
        context.read<SelectConditionBloc>().add(ConditionChosen(selected));
      }
    });
  }

  String _getDescriptionForCondition(ColorblindType type) {
    switch (type) {
      case ColorblindType.protanopia:
        return 'Bentuk buta warna dengan kesulitan membedakan warna merah.';
      case ColorblindType.deuteranopia:
        return 'Bentuk buta warna yang umum untuk kesulitan membedakan merah-hijau.';
      case ColorblindType.tritanopia:
        return 'Bentuk buta warna dengan kesulitan membedakan warna biru-kuning.';
      case ColorblindType.monochromacy:
        return 'Sensitivitas warna sangat rendah pada seluruh spektrum warna (buta warna total).';
      case ColorblindType.normal:
        return 'Penglihatan warna normal pada seluruh spektrum warna.';
    }
  }

  void _onSaveCondition() {
    if (_selectedType != null) {
      context.read<SelectConditionBloc>().add(ConditionSaved(_selectedType!));
    }
  }

  void _onStartTest() {
    Navigator.pushNamed(context, '/colorblind_test');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<SelectConditionBloc, SelectConditionState>(
          listener: (context, state) {
            if (state is SelectConditionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is SelectConditionSavedSuccess) {
              sl<TokenStorage>().saveCondition(
                type: state.condition.displayName,
                description: _getDescriptionForCondition(state.condition),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Kondisi tersimpan: ${state.condition.displayName}',
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pushReplacementNamed(context, '/home');
            } else if (state is NavigateToTestState) {
              Navigator.pushNamed(context, '/colorblind_test');
            }
          },
          builder: (context, state) {
            final isSaving = state is SelectConditionSaving;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Headline
                  const Text(
                    'Apakah Anda sudah\nmengetahui jenis gangguan\npenglihatan warna Anda?',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  const Text(
                    'Bantu kami memberikan pengalaman terbaik untuk dirimu melihat warna dengan memberitahu kami tipe buta warna anda.',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: AppColors.textDark,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Custom Dropdown Box "Masukkan tipe buta warnamu"
                  GestureDetector(
                    onTap: _showConditionPicker,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.textDark,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedType != null
                                  ? _selectedType!.displayName
                                  : 'Masukkan tipe buta warnamu',
                              style: TextStyle(
                                fontSize: 15,
                                color: _selectedType != null
                                    ? AppColors.textDark
                                    : AppColors.textHint,
                                fontWeight: _selectedType != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textDark,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Optional confirm selection button if a condition is selected
                  if (_selectedType != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _onSaveCondition,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan Pilihan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Divider "Belum tau?"
                  Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          color: AppColors.dividerLine,
                          thickness: 1.2,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'Belum tau?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.dividerLine,
                          thickness: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Big Button "Ikuti Tes Buta Warna →"
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _onStartTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ikuti Tes Buta Warna →',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Footnote Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.textDark,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textDark,
                              height: 1.35,
                            ),
                            children: [
                              TextSpan(
                                text: 'Pilihan anda tetap dapat diubah melalui ',
                              ),
                              TextSpan(
                                text: 'Profile > Golongan Buta Warna',
                                style: TextStyle(
                                  color: AppColors.brandPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
