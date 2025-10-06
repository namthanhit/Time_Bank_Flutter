import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/Onboarding/domain/onboarding_models.dart';
import 'package:time_bank_flutter/features/Onboarding/providers/onboarding_controller.dart';
import 'package:time_bank_flutter/features/Onboarding/ui/verify_otp_page.dart';
import 'package:time_bank_flutter/features/auth/ui/login_page.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _cccdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _cccdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OnboardingState>(onboardingControllerProvider, (prev, next) {
      next.status.whenOrNull(error: (error, __) {
        final message = onboardingErrorMessage(error);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        ref.read(onboardingControllerProvider.notifier).clearStatus();
      });
    });

    return Scaffold(
      body: Container(
        // Nền gradient xanh
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  "WELCOME!",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Box trắng chứa form
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInput(
                          label: "Căn cước công dân",
                          hint: "Nhập số CCCD",
                          controller: _cccdController,
                          keyboardType: TextInputType.number,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập CCCD";
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return "CCCD chỉ được chứa số";
                            }
                            if (value.length != 12) {
                              return "CCCD phải đủ 12 số";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildInput(
                          label: "Số điện thoại",
                          hint: "Nhập số điện thoại",
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập số điện thoại";
                            }
                            if (!RegExp(r'^0[0-9]{9}$').hasMatch(value)) {
                              return "SĐT không hợp lệ";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildInput(
                          label: "Email",
                          hint: "Nhập email",
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          isRequired: false, // 👈 không bắt buộc
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return "Email không hợp lệ";
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildInput(
                          label: "Họ và tên",
                          hint: "Nhập họ và tên",
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập họ và tên";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Nút Tiếp theo gradient
                        _SubmitButton(
                          formKey: _formKey,
                          buildPayload: () => SignUpPayload(
                            citizenId: _cccdController.text.trim(),
                            phoneNumber: _phoneController.text.trim(),
                            email: _emailController.text.trim().isEmpty
                                ? null
                                : _emailController.text.trim(),
                            fullName: _nameController.text.trim(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Divider với chữ "hoặc"
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(thickness: 1, color: Colors.grey),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "hoặc",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            const Expanded(
                              child: Divider(thickness: 1, color: Colors.grey),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Nút đăng nhập chữ xanh
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()));
                          },
                          child: const Text(
                            "Đăng nhập",
                            style: TextStyle(
                              color: Color(0xFF0F58A1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Input có label + hint text mờ
  Widget _buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            children: isRequired
                ? const <TextSpan>[
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends ConsumerStatefulWidget {
  const _SubmitButton({
    required this.formKey,
    required this.buildPayload,
  });

  final GlobalKey<FormState> formKey;
  final SignUpPayload Function() buildPayload;

  @override
  ConsumerState<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends ConsumerState<_SubmitButton> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final isLoading = state.status.isLoading;
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
        ),
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                FocusScope.of(context).unfocus();
                if (!widget.formKey.currentState!.validate()) {
                  return;
                }
                final success = await ref
                    .read(onboardingControllerProvider.notifier)
                    .requestOtp(widget.buildPayload());
                if (!mounted || !success) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OtpScreen()),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                "Tiếp theo",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
      ),
    );
  }
}
