// lib/features/onboarding/data/onboarding_repository.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import 'onboarding_api.dart';
import '../domain/phone_until.dart';

class OnboardingRepository {
  OnboardingRepository(this.api, this.auth);
  final OnboardingApi api;
  final FirebaseAuth auth;

  /// B1: gọi backend check-phone (giữ nguyên 09...) -> lấy phone_token
  /// B2: gửi OTP bằng Firebase -> YÊU CẦU E.164 (+84...)
  Future<StartPhoneResult> startPhoneFlow(String phoneRaw) async {
    // 1) Check phone với backend (không chuẩn hoá)
    final r = await api.checkPhone(phoneRaw);
    if (r.exists) {
      throw OnboardingError('Số điện thoại đã được sử dụng');
    }
    final phoneToken = r.phoneToken;
    if (phoneToken == null) {
      throw OnboardingError('Thiếu phone_token từ server');
    }

    // 2) Firebase verifyPhoneNumber cần E.164
    final phoneE164 = toE164VN(phoneRaw);

    final completer = Completer<StartPhoneResult>();
    String? verificationId;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneE164, // ✅ E.164 cho Firebase
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential _) {
        // bỏ auto-signin; user vẫn nhập OTP thủ công
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(
          OnboardingError(e.message ?? 'Firebase error'),
        );
      },
      codeSent: (String verId, int? _) {
        verificationId = verId;
        completer.complete(
          StartPhoneResult(
            phoneToken: phoneToken,
            verificationId: verId,
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId ??= verId;
      },
    );

    return completer.future;
  }

  /// B3: người dùng nhập OTP -> xác thực local với Firebase
  Future<void> verifyOtpLocal({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await auth.signInWithCredential(credential);
    await auth.signOut(); // không giữ session Firebase
  }

  /// B4: gửi toàn bộ thông tin để tạo tài khoản trên backend
  Future<String> createAccount({
    required String phoneToken,
    required PersonalDto personal,
    required String pin,
    required String password,
    required String skillId
  }) async {
    final r = await api.signupCreate(
      phoneToken: phoneToken,
      personal: personal,
      pin: pin,
      password: password,
      skillId: skillId
    );
    if (!r.ok) throw OnboardingError('Tạo tài khoản thất bại');
    return r.userId ?? '';
  }
}

class StartPhoneResult {
  final String phoneToken;
  final String verificationId;
  StartPhoneResult({required this.phoneToken, required this.verificationId});
}

class OnboardingError implements Exception {
  final String message;
  OnboardingError(this.message);
  @override
  String toString() => message;
}
