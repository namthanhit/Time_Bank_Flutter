import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/onboarding_repository.dart';
import '../domain/models/models.dart';
import 'onboarding_state.dart';
import '../data/mock_onboarding_repository.dart';

final onboardingRepoProvider = Provider<OnboardingRepository>((ref) {
  // TODO: đổi sang OnboardingRepositoryImpl(apiHttp) khi có API thật
  return MockOnboardingRepository();
});

final onboardingControllerProvider =
NotifierProvider<OnboardingController, OnboardingState>(
    OnboardingController.new);

class OnboardingController extends Notifier<OnboardingState> {
  OnboardingRepository get _repo => ref.read(onboardingRepoProvider);

  @override
  OnboardingState build() => const OnboardingState();

  void _start() => state = state.copyWith(loading: true, error: null);
  void _done() => state = state.copyWith(loading: false);
  void _fail(Object e) =>
      state = state.copyWith(loading: false, error: e.toString());

  Future<void> signup(SignupPayload payload) async {
    _start();
    try {
      await _repo.signup(payload);
      state = state.copyWith(phone: payload.phone);
      _done();
    } catch (e) {
      _fail(e);
    }
  }

  Future<void> resendOtp() async {
    if (state.phone == null) return;
    _start();
    try {
      await _repo.resendOtp(state.phone!);
      _done();
    } catch (e) {
      _fail(e);
    }
  }

  Future<void> verifyOtp(String code) async {
    if (state.phone == null) return;
    _start();
    try {
      await _repo.verifyOtp(
        VerifyOtpPayload(phone: state.phone!, code: code),
      );
      _done();
    } catch (e) {
      _fail(e);
    }
  }

  Future<void> setPassword(String password) async {
    if (state.phone == null) return;
    _start();
    try {
      await _repo.setPassword(
        SetPasswordPayload(phone: state.phone!, password: password),
      );
      _done();
    } catch (e) {
      _fail(e);
    }
  }

  Future<void> completeProfile(CompleteProfilePayload payload) async {
    _start();
    try {
      await _repo.completeProfile(payload);
      _done();
    } catch (e) {
      _fail(e);
    }
  }

  Future<void> setPin(String pin) async {
    if (state.phone == null) return;
    _start();
    try {
      await _repo.setPin(SetPinPayload(phone: state.phone!, pin: pin));
      _done();
    } catch (e) {
      _fail(e);
    }
  }
}
