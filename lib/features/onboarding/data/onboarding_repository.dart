import '../domain/models/models.dart';
import 'onboarding_api.dart';

abstract class OnboardingRepository {
  Future<void> signup(SignupPayload payload);
  Future<void> resendOtp(String phone);
  Future<void> verifyOtp(VerifyOtpPayload payload);
  Future<void> setPassword(SetPasswordPayload payload);
  Future<void> completeProfile(CompleteProfilePayload payload);
  Future<void> setPin(SetPinPayload payload);
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingApi api;
  OnboardingRepositoryImpl(this.api);

  @override
  Future<void> signup(SignupPayload payload) => api.signup(payload);

  @override
  Future<void> resendOtp(String phone) => api.resendOtp(phone);

  @override
  Future<void> verifyOtp(VerifyOtpPayload payload) => api.verifyOtp(payload);

  @override
  Future<void> setPassword(SetPasswordPayload payload) =>
      api.setPassword(payload);

  @override
  Future<void> completeProfile(CompleteProfilePayload payload) =>
      api.completeProfile(payload);

  @override
  Future<void> setPin(SetPinPayload payload) => api.setPin(payload);
}
