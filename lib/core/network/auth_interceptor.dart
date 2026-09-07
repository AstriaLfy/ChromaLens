import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio dio;

  AuthInterceptor({
    required this.tokenStorage,
    required this.dio,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Use a fresh Dio instance to prevent infinite interceptor loops
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: ApiEndpoints.baseUrl,
              headers: {'Content-Type': 'application/json'},
            ),
          );

          final response = await refreshDio.post(
            ApiEndpoints.refreshToken,
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200 && response.data['success'] == true) {
            final data = response.data['data'] as Map<String, dynamic>;
            final newAccessToken = data['access_token'] as String;
            final newRefreshToken = data['refresh_token'] as String?;

            await tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Retry original request with new token
            final originalOptions = err.requestOptions;
            originalOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await dio.fetch(originalOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          await tokenStorage.clearTokens();
        }
      }
    }
    handler.next(err);
  }
}
