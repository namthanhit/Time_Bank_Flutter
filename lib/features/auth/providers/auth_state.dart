import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

@immutable
class AuthState {
  final bool loading;
  final bool authenticated;
  final String? error;

  // bổ sung các trường cần cho client
  final String? accessToken;
  final String? refreshToken;
  final String? firebaseToken;

  // thông tin user tối thiểu (tuỳ backend)
  final String? userId;
  final String? phone;
  final String? fullName;
  final String? status;

  const AuthState({
    this.loading = false,
    this.authenticated = false,
    this.error,
    this.accessToken,
    this.refreshToken,
    this.firebaseToken,
    this.userId,
    this.phone,
    this.fullName,
    this.status,
  });

  AuthState copyWith({
    bool? loading,
    bool? authenticated,
    String? error,
    String? accessToken,
    String? refreshToken,
    String? firebaseToken,
    String? userId,
    String? phone,
    String? fullName,
    String? status,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      authenticated: authenticated ?? this.authenticated,
      error: error,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      firebaseToken: firebaseToken ?? this.firebaseToken,
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      status: status ?? this.status,
    );
  }

  factory AuthState.initial() => const AuthState();
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.repo) : super(AuthState.initial());
  final AuthRepository repo;

  // Helper đọc key an toàn từ mọi kiểu response
  T? _pick<T>(dynamic src, String key) {
    try {
      if (src == null) return null;
      if (src is Map) {
        final v = src[key];
        if (v is T) return v;
        // nếu value lồng trong 'data'
        if (src['data'] is Map) {
          final v2 = (src['data'] as Map)[key];
          if (v2 is T) return v2;
        }
      }
    } catch (_) {}
    return null;
  }

  Map<String, dynamic>? _pickUser(dynamic src) {
    try {
      if (src is Map && src['user'] is Map<String, dynamic>) {
        return src['user'] as Map<String, dynamic>;
      }
      if (src is Map && src['data'] is Map && (src['data'] as Map)['user'] is Map<String, dynamic>) {
        return (src['data'] as Map)['user'] as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<void> signIn(String phone, String password, {String? deviceInfo}) async {
    state = state.copyWith(loading: true, error: null, authenticated: false);
    try {
      // ⚠️ YÊU CẦU: AuthRepository.signIn trả về JSON login từ backend:
      // {
      //   user: { id, phone, full_name, status, ... },
      //   access_token: "...",
      //   refresh_token: "...",
      //   expires_in: "15m",
      //   firebase_token: "..."    // dùng để FirebaseAuth.signInWithCustomToken
      // }
      final res = await repo.signIn(phone: phone, password: password, deviceInfo: deviceInfo);

      final accessToken   = _pick<String>(res, 'access_token');
      final refreshToken  = _pick<String>(res, 'refresh_token');
      final firebaseToken = _pick<String>(res, 'firebase_token');
      final user          = _pickUser(res);

      state = state.copyWith(
        loading: false,
        authenticated: true,
        error: null,
        accessToken: accessToken,
        refreshToken: refreshToken,
        firebaseToken: firebaseToken,
        userId: user?['id']?.toString(),
        phone: user?['phone']?.toString(),
        fullName: user?['full_name']?.toString(),
        status: user?['status']?.toString(),
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        authenticated: false,
        error: e.toString(),
        accessToken: null,
        refreshToken: null,
        firebaseToken: null,
        userId: null,
        phone: null,
        fullName: null,
        status: null,
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(loading: true);
    try {
      await repo.signOut();
    } finally {
      state = AuthState.initial();
    }
  }
}
