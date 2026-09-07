class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Terjadi kesalahan pada server.']);

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Autentikasi gagal.']);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Tidak ada koneksi internet.']);

  @override
  String toString() => message;
}
