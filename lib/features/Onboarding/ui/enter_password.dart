import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/Onboarding/ui/set_security_page.dart';
import 'package:time_bank_flutter/features/auth/ui/login_page.dart';

class PasswordSetupScreen extends StatefulWidget {
  const PasswordSetupScreen({super.key});

  @override
  State<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends State<PasswordSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // Trạng thái ẩn/hiện mật khẩu
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      // Nếu hợp lệ → chuyển sang LoginPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PinSetupScreen()),
      );
    }
  }

  // Hàm kiểm tra ràng buộc mật khẩu: >=8 ký tự và có chữ hoa
  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập mật khẩu";
    }
    if (value.length < 8) {
      return "Mật khẩu phải ít nhất 8 ký tự";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Mật khẩu phải chứa ít nhất 1 chữ hoa";
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Mật khẩu phải chứa ít nhất 1 chữ số";
    }
    return null;
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Thiết lập mật khẩu",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 45),

                // Box trắng
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Label + ô nhập mật khẩu
                        const Text(
                          "Mật Khẩu:",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          obscuringCharacter: '*',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            hintText: "Nhập mật khẩu",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: _passwordValidator,
                        ),
                        const SizedBox(height: 20),

                        // Label + ô nhập lại mật khẩu
                        const Text(
                          "Nhập lại mật khẩu:",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          obscuringCharacter: '*',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            hintText: "Nhập lại mật khẩu",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập lại mật khẩu";
                            }
                            // Trước tiên kiểm tra mật khẩu chính có hợp lệ không
                            final pwError = _passwordValidator(_passwordController.text);
                            if (pwError != null) {
                              // Nếu mật khẩu chính chưa hợp lệ, báo cho user sửa trước
                              return pwError;
                            }
                            if (value != _passwordController.text) {
                              return "Mật khẩu nhập lại không khớp";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 60),

                        // Nút Hoàn tất (gradient xanh)
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Hoàn tất",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Nút Hủy
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              foregroundColor: const Color(0xFF0D1B4C),
                            ),
                            child: const Text(
                              "Hủy",
                              style: TextStyle(fontSize: 16),
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
}
