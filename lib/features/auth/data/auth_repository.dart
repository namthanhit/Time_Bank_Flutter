import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_api.dart';

class AuthRepository {
  // Thật
  AuthRepository(AuthApi api, {FlutterSecureStorage? storage})
      : _api = api,
        _storage = storage ?? const FlutterSecureStorage();

  // Mock: KHÔNG gọi API, sẽ override method ở subclass mock
  AuthRepository.forMock({FlutterSecureStorage? storage})
      : _api = null,
        _storage = storage ?? const FlutterSecureStorage();

  final AuthApi? _api; // <- cho phép null ở bản mock
  final FlutterSecureStorage _storage;

  Future<bool> loginPhone({
    required String phone,
    required String password,
  }) async {
    // Nếu dùng bản thật thì _api phải có
    final api = _api;
    if (api == null) {
      // Bản mock phải override method này
      throw UnsupportedError(
        'AuthRepository.forMock: loginPhone must be overridden in MockAuthRepository',
      );
    }

    final json = await api.login(phone: phone, password: password);

    final access = json['access_token'] as String?;
    if (access == null || access.isEmpty) return false;

    await _storage.write(key: 'access_token', value: access);
    final refresh = json['refresh_token'] as String?;
    if (refresh != null) {
      await _storage.write(key: 'refresh_token', value: refresh);
    }
    return true;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<String?> get token async => _storage.read(key: 'access_token');
}
