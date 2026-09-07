import 'package:flutter/material.dart';
import '../../../../app/config/router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/presentation/widgets/auth_back_button.dart';
import '../../../colorblind_test/domain/entities/test_result_entity.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileTestResultScreen extends StatelessWidget {
  final TestResultEntity? testResult;
  final UserProfileEntity? userProfile;

  const ProfileTestResultScreen({
    super.key,
    this.testResult,
    this.userProfile,
  });

  TestResultEntity _resolveTestResult() {
    if (testResult != null) return testResult!;

    final storedTest = sl<TokenStorage>().getTestResult();
    if (storedTest != null) return storedTest;

    final condition = userProfile?.colorblindType ??
        sl<TokenStorage>().getConditionType() ??
        'Normal';

    return _createResultFromCondition(condition);
  }

  TestResultEntity _createResultFromCondition(String condition) {
    final lower = condition.toLowerCase();
    final now = DateTime.now();

    if (lower.contains('protan')) {
      return TestResultEntity(
        diagnosis: 'Protanopia',
        description:
            'Sensitivitas terhadap spektrum warna merah lebih rendah sehingga warna merah tampak lebih redup atau serupa dengan hijau dan cokelat.',
        affectedColors: 'Merah dan Hijau',
        category: 'Protanopia (Buta Warna Merah)',
        testDate: now,
        correctCount: 6,
        totalQuestions: 12,
      );
    } else if (lower.contains('deutan')) {
      return TestResultEntity(
        diagnosis: 'Deuteranopia',
        description:
            'Sensitivitas terhadap spektrum warna hijau lebih rendah sehingga warna hijau dan merah dapat terlihat serupa.',
        affectedColors: 'Merah dan Hijau',
        category: 'Deuteranopia (Buta Warna Hijau)',
        testDate: now,
        correctCount: 7,
        totalQuestions: 12,
      );
    } else if (lower.contains('tritan')) {
      return TestResultEntity(
        diagnosis: 'Tritanopia',
        description:
            'Sensitivitas terhadap spektrum warna biru lebih rendah sehingga kesulitan membedakan warna biru dan kuning.',
        affectedColors: 'Biru dan Kuning',
        category: 'Tritanopia (Buta Warna Biru)',
        testDate: now,
        correctCount: 8,
        totalQuestions: 12,
      );
    } else if (lower.contains('monochrom') || lower.contains('achromat')) {
      return TestResultEntity(
        diagnosis: 'Monokromasi',
        description:
            'Sensitivitas warna sangat rendah pada seluruh spektrum warna (buta warna total). Fitur text-based color recognition akan sangat membantu Anda.',
        affectedColors: 'Semua Warna',
        category: 'Monokromasi / Akromatopsia',
        testDate: now,
        correctCount: 2,
        totalQuestions: 12,
      );
    } else {
      return TestResultEntity(
        diagnosis: 'Penglihatan Normal',
        description:
            'Penglihatan warna Anda berada dalam rentang normal pada seluruh spektrum warna merah, hijau, dan biru.',
        affectedColors: 'Tidak Ada',
        category: 'Normal Vision',
        testDate: now,
        correctCount: 12,
        totalQuestions: 12,
      );
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final day = dt.day;
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final result = _resolveTestResult();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: AuthBackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Hasil Tes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Hasil Terbaru & Diagnosis
                    _buildSummaryCard(result),
                    const SizedBox(height: 16),

                    // Card 2: Clinical Details Breakdown
                    _buildDetailsCard(result),
                    const SizedBox(height: 16),

                    // Card 3: Warna yang Mungkin Mirip
                    _buildSimilarColorsCard(result),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action: Ulangi Tes
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.colorblindTest);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.restart_alt_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ulangi Tes',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(TestResultEntity result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E5EA),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Hasil Terbaru
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Hasil Terbaru',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.brandPurple,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            result.diagnosis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.brandPurple,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            result.description,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getColorsForDiagnosis(String diagnosis) {
    final lower = diagnosis.toLowerCase();
    if (lower.contains('protan')) {
      return [
        {'name': 'Merah', 'color': const Color(0xFFEF4444)},
        {'name': 'Cokelat', 'color': const Color(0xFFA16207)},
        {'name': 'Hijau Tua', 'color': const Color(0xFF15803D)},
        {'name': 'Abu-abu', 'color': const Color(0xFF6B7280)},
      ];
    } else if (lower.contains('deutan')) {
      return [
        {'name': 'Merah', 'color': const Color(0xFFEF4444)},
        {'name': 'Hijau', 'color': const Color(0xFF22C55E)},
        {'name': 'Cokelat', 'color': const Color(0xFFA16207)},
        {'name': 'Oranye', 'color': const Color(0xFFF97316)},
      ];
    } else if (lower.contains('tritan')) {
      return [
        {'name': 'Biru', 'color': const Color(0xFF3B82F6)},
        {'name': 'Hijau', 'color': const Color(0xFF22C55E)},
        {'name': 'Kuning', 'color': const Color(0xFFEAB308)},
        {'name': 'Merah Muda', 'color': const Color(0xFFEC4899)},
      ];
    } else if (lower.contains('monochrom') || lower.contains('achromat')) {
      return [
        {'name': 'Hitam', 'color': const Color(0xFF111827)},
        {'name': 'Abu Gelap', 'color': const Color(0xFF4B5563)},
        {'name': 'Abu Terang', 'color': const Color(0xFF9CA3AF)},
        {'name': 'Putih Abu', 'color': const Color(0xFFE5E7EB)},
      ];
    } else {
      return [
        {'name': 'Merah', 'color': const Color(0xFFEF4444)},
        {'name': 'Hijau', 'color': const Color(0xFF22C55E)},
        {'name': 'Biru', 'color': const Color(0xFF3B82F6)},
        {'name': 'Kuning', 'color': const Color(0xFFEAB308)},
      ];
    }
  }

  Widget _buildDetailsCard(TestResultEntity result) {
    final dateStr = _formatDate(result.testDate);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E5EA),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.graphic_eq_rounded,
            label: 'Warna yang terdampak',
            value: result.affectedColors,
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.category_outlined,
            label: 'Kategori',
            value: result.category,
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.public_rounded,
            label: 'Tanggal Tes',
            value: dateStr,
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.fact_check_outlined,
            label: 'Benar-salah',
            value: '${result.correctCount}/${result.totalQuestions}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textDark,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.7,
      color: Color(0xFFF2F2F7),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildSimilarColorsCard(TestResultEntity result) {
    final isNormal = result.diagnosis.toLowerCase().contains('normal');
    final title = isNormal ? 'Spektrum Warna Utama' : 'Warna yang mungkin mirip';
    final colors = _getColorsForDiagnosis(result.diagnosis);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E5EA),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: colors.map((item) {
              final color = item['color'] as Color;
              final name = item['name'] as String;

              return Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
