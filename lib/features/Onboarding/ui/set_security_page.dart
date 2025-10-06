import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:time_bank_flutter/features/Onboarding/data/onboarding_repository.dart';
import 'package:time_bank_flutter/features/Onboarding/providers/onboarding_controller.dart';
import 'package:time_bank_flutter/features/auth/ui/login_page.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _pin = "";
  String _confirmPin = "";

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Thiết lập mã PIN",
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Box trắng chứa form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Mã PIN giúp bạn xác thực trong mỗi giao dịch",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        obscureText: true,
                        obscuringWidget: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D1B4C),
                            shape: BoxShape.circle,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        onChanged: (value) => _pin = value,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.circle,
                          fieldHeight: 28,
                          fieldWidth: 28,
                          inactiveColor: Colors.grey.shade400,
                          activeColor: const Color(0xFF0D1B4C),
                          selectedColor: const Color(0xFF0F58A1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      const SizedBox(height: 30),

                      const Text(
                        "Nhập lại mã PIN đã tạo",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        obscureText: true,
                        obscuringWidget: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D1B4C),
                            shape: BoxShape.circle,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        onChanged: (value) => _confirmPin = value,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.circle,
                          fieldHeight: 28,
                          fieldWidth: 28,
                          inactiveColor: Colors.grey.shade400,
                          activeColor: const Color(0xFF0D1B4C),
                          selectedColor: const Color(0xFF0F58A1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Nút Xác Thực
                      Consumer(
                        builder: (context, ref, _) {
                          final state =
                              ref.watch(onboardingControllerProvider);
                          final isLoading = state.status.isLoading;
                          return GestureDetector(
                            onTap: isLoading
                                ? null
                                : () async {
                                    if (_pin != _confirmPin || _pin.length != 6) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            "Mã PIN không khớp hoặc chưa đủ 6 số!",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final success = await ref
                                        .read(onboardingControllerProvider
                                            .notifier)
                                        .completeRegistration(_pin);
                                    if (!mounted || !success) return;
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (_) => const LoginPage()),
                                      (route) => false,
                                    );
                                  },
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
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Nút Hủy
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: Color(0xFF0D1B4C)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Hủy",
                          style: TextStyle(color: Color(0xFF0D1B4C)),
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
