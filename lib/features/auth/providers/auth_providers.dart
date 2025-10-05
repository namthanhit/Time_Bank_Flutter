import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';
import 'dart:async';

final dioProvider = Provider<Dio>((ref) {
  // Có thể tiêm interceptors (token, logging) tại đây
  return Dio(BaseOptions(
    baseUrl: 'https://api.example.com', // TODO: đổi sang .env/app_config
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(dio: ref.watch(dioProvider));
});

final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authApiProvider));
});

/// StateNotifier điều khiển submit & error
final authControllerProvider =
StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepoProvider));
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthState.idle());

  final AuthRepository _repo;

  Future<void> loginPhone(String phone, String password) async {
    state = const AuthState.loading();
    try {
      final ok = await _repo.loginPhone(phone: phone, password: password);
      if (ok) {
        state = const AuthState.success();
      } else {
        state = const AuthState.error('Đăng nhập thất bại');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void reset() => state = const AuthState.idle();
}
