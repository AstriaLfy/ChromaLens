import 'package:flutter_test/flutter_test.dart';
import 'package:chroma_lens/core/network/api_response.dart';

void main() {
  test('ApiResponse parses successful response correctly', () {
    final json = {
      'success': true,
      'message': 'OK',
      'data': {'id': 1, 'name': 'John'},
      'errors': null,
    };

    final res = ApiResponse<Map<String, dynamic>>.fromJson(
      json,
      (d) => d as Map<String, dynamic>,
    );

    expect(res.success, isTrue);
    expect(res.message, 'OK');
    expect(res.data?['name'], 'John');
  });

  test('ApiResponse parses failure response correctly', () {
    final json = {
      'success': false,
      'message': 'Invalid credentials',
      'data': null,
      'errors': 'Unauthorized',
    };

    final res = ApiResponse<Map<String, dynamic>>.fromJson(
      json,
      (d) => d as Map<String, dynamic>,
    );

    expect(res.success, isFalse);
    expect(res.message, 'Invalid credentials');
    expect(res.data, isNull);
    expect(res.errors, 'Unauthorized');
  });
}
