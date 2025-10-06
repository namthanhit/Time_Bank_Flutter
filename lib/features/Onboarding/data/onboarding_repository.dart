import '../domain/onboarding_models.dart';

abstract class OnboardingRepository {
  Future<void> requestOtp(SignUpPayload payload);
  Future<void> verifyOtp({required String phone, required String otp});
  Future<void> submitProfile({required String phone, required ProfileInfo profile});
  Future<void> setPassword({required String phone, required String password});
  Future<void> finalize(OnboardingFormData data);
}

class MockOnboardingRepository implements OnboardingRepository {
  @override
  Future<void> requestOtp(SignUpPayload payload) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (payload.phoneNumber.endsWith('000')) {
      throw OnboardingException('Số điện thoại đã tồn tại trong hệ thống');
    }
  }

  @override
  Future<void> verifyOtp({required String phone, required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (otp != '123456') {
      throw OnboardingException('Mã OTP không chính xác');
    }
  }

  @override
  Future<void> submitProfile({
    required String phone,
    required ProfileInfo profile,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> setPassword({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (password.length < 8) {
      throw OnboardingException('Mật khẩu chưa đáp ứng độ dài tối thiểu');
    }
  }

  @override
  Future<void> finalize(OnboardingFormData data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (data.pin == null || data.pin!.length != 6) {
      throw OnboardingException('Mã PIN không hợp lệ');
    }
  }
}
