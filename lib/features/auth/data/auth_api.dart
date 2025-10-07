import 'package:dio/dio.dart';

class AuthApi {
  AuthApi({Dio? dio, String? baseUrl})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl ?? 'https://api.example.com'));

  final Dio _dio;

  /// POST /auth/login
  /// body: { phone: string, password: string }
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'phone': phone, 'password': password},
      options: Options(headers: {
        // Ví dụ nếu backend yêu cầu version/app headers
        'X-Client': 'TimeBank Flutter',
      }),
    );
    return res.data as Map<String, dynamic>;
  }
}
