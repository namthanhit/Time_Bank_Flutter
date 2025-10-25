import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Thêm import Firebase

import '../data/auth_repository.dart';
import '../../chat/providers/chat_providers.dart'; // 2. Thêm import chat provider
import 'package:firebase_database/firebase_database.dart';

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
  // 3. SỬA HÀM TẠO
  // Nhận 'ref' TRƯỚC, 'repo' SAU
  // (để khớp với file auth_providers.dart)
  AuthController(this._ref, this.repo) : super(AuthState.initial());
  final Ref _ref;
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

  // 4. THÊM HÀM _firebaseSignIn VÀO ĐÂY
  Future<void> _firebaseSignIn(String? firebaseToken) async {
    final auth = FirebaseAuth.instance;
    try {
      if (firebaseToken != null && firebaseToken.isNotEmpty) {
        if (auth.currentUser != null) {
          await auth.signOut();
        }
        await auth.signInWithCustomToken(firebaseToken);
        debugPrint('Firebase sign-in successful.');
      } else {
        await auth.signInAnonymously();
        debugPrint('Firebase sign-in anonymous.');
      }
    } catch (e) {
      debugPrint('Firebase login error: $e');
    }
  }

  Future<void> signIn(String phone, String password, {String? deviceInfo}) async {
    state = state.copyWith(loading: true, error: null, authenticated: false);
    try {
      final res = await repo.signIn(phone: phone, password: password, deviceInfo: deviceInfo);

      final accessToken   = _pick<String>(res, 'access_token');
      final refreshToken  = _pick<String>(res, 'refresh_token');
      final firebaseToken = _pick<String>(res, 'firebase_token');
      final user          = _pickUser(res);

      // BƯỚC 1: Đăng nhập Firebase (currentUser giờ là User B)
      await _firebaseSignIn(firebaseToken);

      // BƯỚC 2: (FIX LỖI) Invalidate các provider đã bị cache "null"
      // Phải làm điều này SAU KHI _firebaseSignIn
      // VÀ TRƯỚC KHI gọi các provider khác
      _ref.invalidate(currentUidProvider); // <-- Bắt buộc
      _ref.invalidate(threadsProvider);    // <-- Bắt buộc
      _ref.invalidate(messagesProvider);   // <-- (Cho an toàn)

      // BƯỚC 3: Bây giờ mới gọi provider phụ thuộc (presence)
      // (Nó sẽ read() currentUidProvider mới, đã có UID B)
      // ignore: unused_result
      _ref.read(startPresenceProvider);

      // BƯỚC 4: Cập nhật state để AuthWrapper điều hướng
      state = state.copyWith(
        loading: false,
        authenticated: true, // <-- AuthWrapper sẽ bắt state này
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

    // BƯỚC 1: Lấy UID của user HIỆN TẠI (trước khi logout)
    final String? currentUid = _ref.read(currentUidProvider);

    try {
      // BƯỚC 2: Cập nhật trạng thái "offline" thủ công (RẤT QUAN TRỌNG)
      if (currentUid != null) {
        final db = FirebaseDatabase.instance;
        final userRef = db.ref('status/$currentUid');

        // Ghi đè trạng thái 'offline'
        await userRef.set({
          'state': 'offline',
          'last_changed': ServerValue.timestamp,
        });

        // Hủy bỏ onDisconnect() đã đăng ký trước đó
        await userRef.onDisconnect().cancel();
      }

      // BƯỚC 3: Đăng xuất khỏi Firebase
      await FirebaseAuth.instance.signOut();

      // BƯỚC 4: Đăng xuất khỏi backend (NestJS)
      await repo.signOut();

      // BƯỚC 5: Invalidate (dọn dẹp state Riverpod)
      _ref.invalidate(startPresenceProvider);
      _ref.invalidate(currentUidProvider);
      _ref.invalidate(threadsProvider);
      _ref.invalidate(messagesProvider);

    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      // BƯỚC 6: Reset state để AuthWrapper điều hướng
      state = AuthState.initial();
    }
  }
}
