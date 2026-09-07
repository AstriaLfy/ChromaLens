import '../../domain/entities/ishihara_plate.dart';
import '../../domain/entities/test_result_entity.dart';

abstract class ColorblindTestDataSource {
  Future<List<IshiharaPlate>> getPlates();
  Future<TestResultEntity> analyzeAnswers(Map<int, String> answers);
}

class LocalColorblindTestDataSourceImpl implements ColorblindTestDataSource {
  final List<IshiharaPlate> _plates = const [
    IshiharaPlate(
      id: 1,
      numberText: '12',
      options: ['7', '1', '12', 'Tidak Melihat Angka', 'Melihat Angka Lain'],
      correctAnswer: '12',
      description: 'Lempeng demonstrasi yang dapat dilihat oleh semua mata normal maupun buta warna.',
    ),
    IshiharaPlate(
      id: 2,
      numberText: '8',
      options: ['8', '11', '9', 'Tidak Melihat Angka', 'Melihat Angka Lain'],
      correctAnswer: '8',
      description: 'Mata normal melihat angka 8. Penderita buta warna merah-hijau cenderung melihat angka 3.',
    ),
    IshiharaPlate(
      id: 3,
      numberText: '6',
      options: ['6', '5', '8', 'Tidak Melihat Angka', 'Melihat Angka Lain'],
      correctAnswer: '6',
      description: 'Mata normal melihat angka 6. Penderita buta warna merah-hijau melihat angka 5.',
    ),
    IshiharaPlate(
      id: 4,
      numberText: '29',
      options: ['70', '29', '2', 'Tidak Melihat Angka', 'Melihat Angka Lain'],
      correctAnswer: '29',
      description: 'Mata normal melihat angka 29. Penderita buta warna merah-hijau melihat angka 70.',
    ),
    IshiharaPlate(
      id: 5,
      numberText: '57',
      options: ['35', '57', '5', 'Tidak Melihat Angka', 'Melihat Angka Lain'],
      correctAnswer: '57',
      description: 'Mata normal melihat angka 57. Penderita buta warna merah-hijau melihat angka 35.',
    ),
    IshiharaPlate(
      id: 6,
      numberText: '5',
      options: ['2', '5', '3', 'Tidak Melihat Angka', 'Melihat Angka Lain'],
      correctAnswer: '5',
      description: 'Mata normal melihat angka 5. Penderita buta warna merah-hijau melihat angka 2.',
    ),
    IshiharaPlate(
      id: 7,
      numberText: '3',
      options: ['5', '8', '3', 'Tidak Melihat Angka', 'Melihat Angka Lain'],
      correctAnswer: '3',
      description: 'Mata normal melihat angka 3. Penderita buta warna merah-hijau melihat angka 5.',
    ),
    IshiharaPlate(
      id: 8,
      numberText: '15',
      options: ['17', '15', '13', 'Tidak Melihat Angka', 'Melihat Angka Lain'],
      correctAnswer: '15',
      description: 'Mata normal melihat angka 15. Penderita buta warna merah-hijau melihat angka 17.',
    ),
    IshiharaPlate(
      id: 9,
      numberText: '74',
      options: ['21', '74', '71', 'Tidak Melihat Angka', 'Melihat Angka Lain'],
      correctAnswer: '74',
      description: 'Mata normal melihat angka 74. Penderita buta warna merah-hijau melihat angka 21.',
    ),
    IshiharaPlate(
      id: 10,
      numberText: '2',
      options: ['7', '2', '6', 'Tidak Melihat Angka', 'Melihat Angka Lain'],
      correctAnswer: '2',
      description: 'Mata normal melihat angka 2. Penderita buta warna tidak melihat apa-apa.',
    ),
    IshiharaPlate(
      id: 11,
      numberText: '6',
      options: ['9', '6', '8', 'Tidak Melihat Angka', 'Melihat Angka Lain'],
      correctAnswer: '6',
      description: 'Mata normal melihat angka 6. Sebagian penderita buta warna tidak melihat angka.',
    ),
    IshiharaPlate(
      id: 12,
      numberText: '26',
      options: ['97', '26', '95', 'Tidak Melihat Angka', 'Melihat Angka Lain'],
      correctAnswer: '26',
      description: 'Lempeng klasifikasi: Penderita protan melihat 6, penderita deutan melihat 2.',
    ),
  ];

  @override
  Future<List<IshiharaPlate>> getPlates() async {
    // Simulasi loading lempeng
    await Future.delayed(const Duration(milliseconds: 300));
    return _plates;
  }

  @override
  Future<TestResultEntity> analyzeAnswers(Map<int, String> answers) async {
    // Simulasi proses analisis algoritma
    await Future.delayed(const Duration(milliseconds: 1000));

    int correctCount = 0;
    for (final plate in _plates) {
      if (answers[plate.id] == plate.correctAnswer) {
        correctCount++;
      }
    }

    // Default test date format
    final now = DateTime.now();

    if (correctCount >= 11) {
      return TestResultEntity(
        diagnosis: 'Penglihatan Normal',
        description:
            'Anda memiliki penglihatan warna yang normal. Anda dapat membedakan seluruh spektrum warna merah, hijau, dan biru dengan baik.',
        affectedColors: 'Tidak Ada',
        category: 'Normal Vision',
        testDate: now,
        correctCount: correctCount,
        totalQuestions: _plates.length,
      );
    } else if (correctCount <= 4) {
      return TestResultEntity(
        diagnosis: 'Monokromasi',
        description:
            'Anda terdeteksi memiliki sensitivitas warna yang sangat rendah pada seluruh spektrum warna (buta warna total). Fitur text-based color recognition akan sangat membantu Anda.',
        affectedColors: 'Semua Warna',
        category: 'Achromatopsia',
        testDate: now,
        correctCount: correctCount,
        totalQuestions: _plates.length,
      );
    } else {
      // Deuteranomaly vs Protanomaly
      // Sesuai screenshot, defaultnya mendeteksi Deuteranomaly
      return TestResultEntity(
        diagnosis: 'Deuteranomaly',
        description:
            'Anda cenderung kesulitan membedakan warna hijau dan beberapa warna yang memiliki kemiripan dengan merah.',
        affectedColors: 'Merah dan Hijau',
        category: 'Deuteranomaly',
        testDate: now,
        correctCount: correctCount,
        totalQuestions: _plates.length,
      );
    }
  }
}
