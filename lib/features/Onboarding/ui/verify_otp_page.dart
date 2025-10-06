import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:time_bank_flutter/features/Onboarding/data/onboarding_repository.dart';
import 'package:time_bank_flutter/features/Onboarding/providers/onboarding_controller.dart';
import 'package:time_bank_flutter/features/Onboarding/ui/profile_page.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  int _timeLeft = 20; // thời gian đếm ngược (giây)
  Timer? _timer;

  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startCountdown();
    ref.listen<OnboardingState>(onboardingControllerProvider, (prev, next) {
      next.status.whenOrNull(error: (error, __) {
        final message =
            error is OnboardingException ? error.message : error.toString();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        ref.read(onboardingControllerProvider.notifier).clearStatus();
      });
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập OTP")),
      );
      return;
    }

    final success =
        await ref.read(onboardingControllerProvider.notifier).verifyOtp(otp);
    if (!mounted || !success) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final phone = state.data.signUp?.phoneNumber ?? '';
    final isLoading = state.status.isLoading;
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
                        controller: _otpController,
                        length: 6,
                        appContext: context,
                        onChanged: (_) {},
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

                      // Thông báo + Thời gian
                      Column(
                        children: [
                          Text(
                            "Đã gửi mã xác minh đến số điện thoại $phone.",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Thời gian còn lại: ${_timeLeft}s",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Nút Xác Thực
                      GestureDetector(
                        onTap: isLoading ? null : _verifyOtp,
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
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
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
