import '../domain/models/models.dart';

abstract class OnboardingApi {
  Future<void> signup(SignupPayload payload);
  Future<void> resendOtp(String phone);
  Future<void> verifyOtp(VerifyOtpPayload payload);
  Future<void> setPassword(SetPasswordPayload payload);
  Future<void> completeProfile(CompleteProfilePayload payload);
  Future<void> setPin(SetPinPayload payload);
}

// ví dụ triển khai bằng HTTP (Dio):
// class OnboardingApiHttp implements OnboardingApi { ... }
