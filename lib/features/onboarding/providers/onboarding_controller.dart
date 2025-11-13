import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/onboarding_repository.dart';
import 'onboarding_state.dart';
import '../domain/models/models.dart';

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this._repo) : super(const OnboardingState());
  final OnboardingRepository _repo;

  // B1: Nhập số điện thoại -> checkPhone + gửi OTP (Firebase)
  Future<void> startWithPhone(String phone) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final r = await _repo.startPhoneFlow(phone);
      state = state.copyWith(
        loading: false,
        phone: phone,
        phoneToken: r.phoneToken,
        verificationId: r.verificationId,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // B2: Xác thực OTP cục bộ (Firebase)
  Future<void> verifyOtp(String code) async {
    final verId = state.verificationId;
    if (verId == null) {
      state = state.copyWith(error: 'Thiếu verificationId');
      return;
    }
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.verifyOtpLocal(verificationId: verId, smsCode: code);
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // Lưu bản nháp hồ sơ cá nhân
  void setPersonalDraft({
    String? fullName,
    String? email,
    String? cccd,
    DateTime? birthdate,
    String? gender,
    String? regionId,
    String? specialization,
  }) {
    state = state.copyWith(
      fullName: fullName,
      email: email,
      cccd: cccd,
      birthdate: birthdate,
      gender: gender,
      regionId: regionId,
      specialization: specialization,
    );
  }

  // Lưu bảo mật (PIN + mật khẩu)
  void setSecurity({String? pin, String? password}) {
    state = state.copyWith(pin: pin, password: password);
  }

  // B3: Gửi tạo tài khoản lên backend
  Future<String> submitCreateAccount() async {
    final phoneToken = state.phoneToken;
    if (phoneToken == null) throw Exception('Thiếu phone_token');

    if (state.fullName == null || state.fullName!.trim().isEmpty) {
      throw Exception('Thiếu họ tên');
    }
    if (state.pin == null || state.pin!.isEmpty) {
      throw Exception('Thiếu PIN');
    }
    if (state.password == null || state.password!.isEmpty) {
      throw Exception('Thiếu mật khẩu');
    }
    if (state.specialization == null || state.specialization!.isEmpty) {
      throw Exception('Thiếu skill_id (chuyên môn)');
    }
    if (state.regionId == null || state.regionId!.isEmpty) {
      throw Exception('Thiếu region_id (Xã/Phường)');
    }

    state = state.copyWith(loading: true, error: null);
    try {
      final userId = await _repo.createAccount(
        phoneToken: phoneToken,
        personal: PersonalDto(
          fullName: state.fullName!,
          citizenId: state.cccd,
          email: state.email,
          birthDate: state.birthdate,
          gender: state.gender,
          regionId: state.regionId,
          specializationOrDescription: null,
        ),
        pin: state.pin!,
        password: state.password!,
        skillId: state.specialization!,
      );
      state = state.copyWith(loading: false);
      return userId;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  // --- BẮT ĐẦU CODE THÊM MỚI ---

  /// Dùng để set lỗi thủ công từ UI (ví dụ: validate form)
  void setManualError(String errorMsg) {
    state = state.copyWith(error: errorMsg, loading: false);
  }

  /// Xóa lỗi hiện tại (ví dụ: khi người dùng bắt đầu nhập lại)
  void clearError() {
    // Chỉ set lại error, giữ nguyên các state khác
    state = state.copyWith(error: null);
  }

// --- KẾT THÚC CODE THÊM MỚI ---
}