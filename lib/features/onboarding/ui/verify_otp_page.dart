import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:time_bank_flutter/features/onboarding/ui/profile_page.dart';
import 'package:time_bank_flutter/features/onboarding/providers/onboarding_providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  /// thời gian chờ để được bấm "Gửi lại mã" (giây)
  static const int _resendCooldownSec = 60;

  int _resendLeft = _resendCooldownSec;
  Timer? _resendTimer;

  String _otp = ""; // không dùng controller để tránh lỗi dispose

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  // ---------------- cooldown resend ----------------
  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendLeft = _resendCooldownSec);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendLeft > 0) {
        setState(() => _resendLeft--);
      } else {
        t.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    final state = ref.read(onboardingControllerProvider);
    final phone = state.phone;
    if (phone == null || phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thiếu số điện thoại để gửi lại OTP")),
      );
      return;
    }
    // gọi lại startWithPhone để Firebase gửi OTP + cập nhật verificationId/phoneToken
    try {
      await ref.read(onboardingControllerProvider.notifier).startWithPhone(phone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã gửi lại mã OTP")),
      );
      _otp = "";
      _startResendCooldown(); // reset đếm chờ resend
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // ---------------- verify ----------------
  Future<void> _verifyOtp() async {
    if (_otp.isEmpty || _otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ 6 số OTP")),
      );
      return;
    }

    await ref.read(onboardingControllerProvider.notifier).verifyOtp(_otp);

    final state = ref.read(onboardingControllerProvider);
    if (state.error == null && mounted) {
      // ✅ OTP đã verify local → sang trang nhập thông tin
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);

    // Lắng nghe lỗi để show SnackBar
    ref.listen(onboardingControllerProvider, (prev, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    final bool isBusy = state.loading; // loading chung từ controller
    final bool canResend = _resendLeft == 0 && !isBusy;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tiêu đề
                const Text(
                  "Xác Thực OTP",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Box trắng
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ô nhập OTP
                      PinCodeTextField(
                        length: 6,
                        appContext: context,
                        onChanged: (value) {
                          _otp = value;
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        autoFocus: true,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          selectedFillColor: Colors.grey[200],
                          inactiveFillColor: Colors.grey[100],
                          activeColor: Colors.blue,
                          selectedColor: Colors.blueAccent,
                          inactiveColor: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Thông báo + Đếm thời gian được gửi lại
                      Column(
                        children: [
                          const Text(
                            "Đã gửi mã xác minh đến số điện thoại bạn đăng ký.",
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          // hiển thị đếm để được gửi lại
                          Text(
                            _resendLeft > 0
                                ? "Bạn có thể gửi lại OTP sau: ${_resendLeft}s"
                                : "Bạn có thể gửi lại OTP ngay bây giờ",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Nút Gửi lại mã
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: canResend ? _resendOtp : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0D1B4C),
                            side: const BorderSide(color: Color(0xFF0D1B4C)),
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isBusy
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text("Gửi lại mã"),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Nút Xác Thực
                      GestureDetector(
                        onTap: isBusy ? null : _verifyOtp,
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: isBusy
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            "Xác Thực",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
