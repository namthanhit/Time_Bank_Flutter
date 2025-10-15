import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/onboarding_repository.dart';
import 'onboarding_state.dart';
import '../domain/models/models.dart'; // nếu cần types cho method

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this._repo) : super(const OnboardingState());
  final OnboardingRepository _repo;

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

  void setPersonalDraft({
    String? fullName,
    String? email,
    String? cccd,
    DateTime? birthdate,
    String? gender,
    String? address,
    String? specialization, // đang giữ skill_id
  }) {
    state = state.copyWith(
      fullName: fullName,
      email: email,
      cccd: cccd,
      birthdate: birthdate,
      gender: gender,
      address: address,
      specialization: specialization,
    );
  }

  void setSecurity({String? pin, String? password}) {
    state = state.copyWith(pin: pin, password: password);
  }

  Future<String> submitCreateAccount() async {
    final phoneToken = state.phoneToken;
    if (phoneToken == null) throw Exception('Thiếu phone_token');
    if (state.fullName == null || state.pin == null || state.password == null) {
      throw Exception('Thiếu thông tin bắt buộc');
    }
    if (state.specialization == null || state.specialization!.isEmpty) {
      throw Exception('Thiếu skill_id (chuyên môn)');
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
          address: state.address,
          specializationOrDescription: null,
        ),
        pin: state.pin!,
        password: state.password!,
        skillId: state.specialization!, // specialization giữ skill_id
      );
      state = state.copyWith(loading: false);
      return userId;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }
}
