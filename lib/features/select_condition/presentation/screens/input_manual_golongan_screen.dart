import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/colorblind_condition.dart';
import '../bloc/select_condition_bloc.dart';
import '../bloc/select_condition_event.dart';
import '../bloc/select_condition_state.dart';

// Model Data untuk Item
class ColorBlindOption {
  final String id;
  final String title;
  final String desc;

  ColorBlindOption({required this.id, required this.title, required this.desc});
}

// Model Data untuk Kategori
class ColorBlindGroup {
  final String category;
  final String subtitle;
  final Color themeColor;
  final List<ColorBlindOption> items;

  ColorBlindGroup({
    required this.category,
    required this.subtitle,
    required this.themeColor,
    required this.items,
  });
}

class InputManualGolonganScreen extends StatefulWidget {
  const InputManualGolonganScreen({super.key});

  @override
  State<InputManualGolonganScreen> createState() => _InputManualGolonganScreenState();
}

class _InputManualGolonganScreenState extends State<InputManualGolonganScreen> {
  String? _selectedId;

  // Mock Data
  final List<ColorBlindGroup> _data = [
    ColorBlindGroup(
      category: 'Buta Warna Merah-Hijau',
      subtitle: 'Kesulitan membedakan warna merah dan hijau',
      themeColor: const Color(0xFF2E7D32),
      items: [
        ColorBlindOption(id: 'deuteranopia', title: 'Deuteranopia', desc: 'Sulit melihat warna hijau tertentu'),
        ColorBlindOption(id: 'deuteranomali', title: 'Deuteranomali', desc: 'Warna Hijau tampak kemerahan'),
        ColorBlindOption(id: 'protanomali', title: 'Protanomali', desc: 'Warna merah tampak kehijauan'),
        ColorBlindOption(id: 'protanopia', title: 'Protanopia', desc: 'Kesulitan membedakan merah tertentu'),
      ],
    ),
    ColorBlindGroup(
      category: 'Buta Warna Biru-Kuning',
      subtitle: 'Kesulitan membedakan warna Biru dan Kuning',
      themeColor: const Color(0xFF1565C0),
      items: [
        ColorBlindOption(id: 'tritanomali', title: 'Tritanomali', desc: 'Sulit membedakan biru–hijau dan kuning–merah'),
        ColorBlindOption(id: 'tritanopia', title: 'Tritanopia', desc: 'Sulit membedakan biru–hijau dan kuning–merah muda'),
      ],
    ),
    ColorBlindGroup(
      category: 'Achromatopia',
      subtitle: 'Tipe penglihatan yang melihat warna sangat terbatas',
      themeColor: const Color(0xFF6A1B9A),
      items: [
        ColorBlindOption(id: 'akromatopsia_sebagian', title: 'Akromatopsia Sebagian', desc: 'Melihat warna dengan jumlah terbatas'),
        ColorBlindOption(id: 'akromatopsia_lengkap', title: 'Akromatopsia Lengkap', desc: 'Hanya melihat hitam, putih, abu-abu'),
      ],
    ),
  ];

  String _getDescriptionForManualId(String id) {
    switch (id) {
      case 'protanopia':
        return 'Kesulitan membedakan warna merah tertentu.';
      case 'protanomali':
        return 'Warna merah tampak kehijauan.';
      case 'deuteranopia':
        return 'Sulit melihat warna hijau tertentu.';
      case 'deuteranomali':
        return 'Warna hijau tampak kemerahan.';
      case 'tritanopia':
        return 'Sulit membedakan biru–hijau dan kuning–merah muda.';
      case 'tritanomali':
        return 'Sulit membedakan biru–hijau dan kuning–merah.';
      case 'akromatopsia_sebagian':
        return 'Melihat warna dengan jumlah terbatas pada seluruh spektrum warna.';
      case 'akromatopsia_lengkap':
        return 'Hanya melihat hitam, putih, dan abu-abu (buta warna total).';
      default:
        return 'Penglihatan warna normal pada seluruh spektrum warna.';
    }
  }

  void _onSave() {
    final selectedId = _selectedId;
    if (selectedId == null) return;
    context
        .read<SelectConditionBloc>()
        .add(ConditionSaved(ColorblindTypeExtension.fromManualId(selectedId)));
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6750A4);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocConsumer<SelectConditionBloc, SelectConditionState>(
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
              type: _selectedId ?? state.condition.code,
              description: _selectedId != null
                  ? _getDescriptionForManualId(_selectedId!)
                  : '',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kondisi tersimpan: ${state.condition.displayName}'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          final isSaving = state is SelectConditionSaving;

          return SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8DEF8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_left, color: primaryColor, size: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Input Manual Golongan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1B1F),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content List
                Expanded(
                  child: RadioGroup<String>(
                    groupValue: _selectedId,
                    onChanged: (value) {
                      setState(() {
                        _selectedId = value;
                      });
                    },
                    child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: _data.length,
                    itemBuilder: (context, groupIndex) {
                      final group = _data[groupIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Kategori
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: group.themeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                group.category,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: group.themeColor,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0, top: 2.0, bottom: 8.0),
                            child: Text(
                              group.subtitle,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ),

                          // Card List Item
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            margin: const EdgeInsets.only(bottom: 20.0),
                            child: Column(
                              children: List.generate(group.items.length, (itemIndex) {
                                final item = group.items[itemIndex];
                                final isLast = itemIndex == group.items.length - 1;

                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedId = item.id;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                        child: Row(
                                          children: [
                                            // Radio Button
                                            Radio<String>(
                                              value: item.id,
                                              activeColor: primaryColor,
                                            ),

                                            // Placeholder Lingkaran Ishihara
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: Colors.amber.shade200,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.amber.shade400),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '12',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.amber.shade900,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // Text Detail
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.title,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    item.desc,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Info Icon
                                            IconButton(
                                              icon: Icon(Icons.info_outline, size: 18, color: Colors.grey[400]),
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(item.desc),
                                                    backgroundColor: group.themeColor,
                                                    behavior: SnackBarBehavior.floating,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (!isLast)
                                      Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200, indent: 12, endIndent: 12),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                ),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _selectedId == null || isSaving
                          ? null
                          : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
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
                              'Pilih',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}