import 'dart:async';
import '../domain/models/models.dart';
import 'onboarding_repository.dart';

class MockOnboardingRepository implements OnboardingRepository {
  @override
  Future<void> signup(SignupPayload payload) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> resendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> verifyOtp(VerifyOtpPayload payload) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (payload.code != '123456') {
      throw Exception('Mã OTP không đúng');
    }
  }

  @override
  Future<void> setPassword(SetPasswordPayload payload) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> completeProfile(CompleteProfilePayload payload) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> setPin(SetPinPayload payload) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
