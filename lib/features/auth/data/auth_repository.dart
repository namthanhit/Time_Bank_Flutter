import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/i_auth_api.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  AuthTokens({required this.accessToken, required this.refreshToken});
}

class AuthRepository {
  AuthRepository(this.api, this.storage);
  final IAuthApi api;
  final FlutterSecureStorage storage;

  static const _kRefresh = 'refresh_token';

  String? _access; // giữ trong RAM
  String? get accessToken => _access;

  /// Đăng nhập hệ thống:
  /// - Gọi API /auth/login
  /// - Lưu refresh token vào secure storage
  /// - Ghi access token vào RAM
  /// - TRẢ VỀ NGUYÊN payload từ server (có cả firebase_token)
  Future<Map<String, dynamic>> signIn({
    required String phone,
    required String password,
    String? deviceInfo,
  }) async {
    final data = await api.login(
      phone: phone,
      password: password,
      deviceInfo: deviceInfo,
    );

    final access = data['access_token'] as String?;
    final refresh = data['refresh_token'] as String?;
    if (access != null) _access = access;
    if (refresh != null) {
      await storage.write(key: _kRefresh, value: refresh);
    }
    // data có thể chứa: user, access_token, refresh_token, expires_in, firebase_token
    return data;
  }

  Future<void> signOut() async {
    final r = await storage.read(key: _kRefresh);
    if (r != null) {
      try {
        await api.logout(r);
      } catch (_) {}
    }
    _access = null;
    await storage.delete(key: _kRefresh);
  }

  Future<bool> isSignedIn() async =>
      (await storage.read(key: _kRefresh)) != null;

  // tránh refresh song song
  Future<String?>? _refreshing;

  Future<String?> refreshIfPossible({String? deviceInfo}) {
    _refreshing ??= _refreshInternal(deviceInfo: deviceInfo);
    return _refreshing!.whenComplete(() => _refreshing = null);
  }

  /// Làm mới access/refresh token từ refresh token lưu trong secure storage.
  /// Trả về access token mới (hoặc null nếu refresh thất bại).
  Future<String?> _refreshInternal({String? deviceInfo}) async {
    final r = await storage.read(key: _kRefresh);
    if (r == null) return null;
    try {
      final data = await api.refresh(r, deviceInfo: deviceInfo);
      final newAccess = data['access_token'] as String?;
      final newRefresh = data['refresh_token'] as String?;

      if (newAccess != null) _access = newAccess;
      if (newRefresh != null) {
        await storage.write(key: _kRefresh, value: newRefresh);
      }

      // Nếu bạn muốn dùng firebase_token mới (nếu server trả),
      // có thể đọc data['firebase_token'] ở nơi gọi hàm này.
      return newAccess;
    } catch (_) {
      _access = null;
      await storage.delete(key: _kRefresh);
      return null;
    }
  }

  void setAccess(String? token) => _access = token;
}
