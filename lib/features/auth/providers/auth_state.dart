import 'package:flutter/foundation.dart';
import '../data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AuthState {
  final bool loading;
  final bool authenticated;
  final String? error;
  const AuthState({this.loading=false, this.authenticated=false, this.error});
  AuthState copyWith({bool? loading, bool? authenticated, String? error}) =>
      AuthState(loading: loading??this.loading, authenticated: authenticated??this.authenticated, error: error);
  factory AuthState.initial() => const AuthState();
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.repo): super(AuthState.initial());
  final AuthRepository repo;

  Future<void> signIn(String phone, String password, {String? deviceInfo}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await repo.signIn(phone: phone, password: password, deviceInfo: deviceInfo);
      state = state.copyWith(loading: false, authenticated: true);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString(), authenticated: false);
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(loading: true);
    await repo.signOut();
    state = AuthState.initial();
  }
}
