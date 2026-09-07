import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chroma_lens/features/colorblind_test/data/services/colorblind_test_api_service.dart';

class MockDioAdapter implements HttpClientAdapter {
  final Map<String, dynamic> responseData;
  final int statusCode;

  MockDioAdapter({required this.responseData, this.statusCode = 200});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(responseData),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('getPlates correctly parses plates from Backend API response', () async {
    final dio = Dio();
    dio.httpClientAdapter = MockDioAdapter(
      responseData: {
        'success': true,
        'message': 'Ishihara plates retrieved successfully',
        'data': [
          {
            'id': 1,
            'plate_number': 1,
            'image_url': 'https://upload.wikimedia.org/wikipedia/commons/e/e0/Ishihara_9.png',
            'options': ['12', 'nothing', 'others'],
            'description': 'Lempeng demonstrasi',
          },
          {
            'id': 2,
            'plate_number': 2,
            'image_url': 'https://upload.wikimedia.org/wikipedia/commons/b/b1/Ishihara_Plate_2.png',
            'options': ['8', '3', 'nothing', 'others'],
            'description': 'Lempeng transformasi',
          }
        ],
        'errors': null,
      },
    );

    final service = ColorblindTestApiService(dio: dio);
    final plates = await service.getPlates();

    expect(plates.length, 2);
    expect(plates[0].id, 1);
    expect(plates[0].numberText, '12');
    expect(plates[0].imageUrl, 'https://upload.wikimedia.org/wikipedia/commons/e/e0/Ishihara_9.png');
    expect(plates[0].options, ['12', 'Tidak Melihat Angka', 'Melihat Angka Lain']);
    expect(plates[0].description, 'Lempeng demonstrasi');

    expect(plates[1].id, 2);
    expect(plates[1].numberText, '8');
    expect(plates[1].imageUrl, 'https://upload.wikimedia.org/wikipedia/commons/b/b1/Ishihara_Plate_2.png');
    expect(plates[1].options, ['8', '3', 'Tidak Melihat Angka', 'Melihat Angka Lain']);
  });

  test('submitAnswers maps user friendly answers to backend format and parses result', () async {
    final dio = Dio();
    dio.httpClientAdapter = MockDioAdapter(
      responseData: {
        'success': true,
        'message': 'Ishihara test evaluated successfully',
        'data': {
          'id': 1,
          'diagnosis': 'Normal',
          'category': 'Normal',
          'description': 'Penglihatan normal',
          'affected_colors': 'Tidak Ada',
          'test_date': '2026-09-07T00:00:00Z',
          'correct_count': 12,
          'total_questions': 12,
        },
        'errors': null,
      },
    );

    final service = ColorblindTestApiService(dio: dio);
    final result = await service.submitAnswers({
      1: '12',
      2: 'Tidak Melihat Angka',
    });

    expect(result.diagnosis, 'Normal');
    expect(result.correctCount, 12);
    expect(result.totalQuestions, 12);
    expect(result.category, 'Normal');
  });
}
