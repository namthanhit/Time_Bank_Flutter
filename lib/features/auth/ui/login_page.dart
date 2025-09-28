import 'package:flutter/material.dart';

import '../../Onboarding/ui/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Trạng thái ẩn/hiện mật khẩu
  bool _obscurePassword = true;

  // (Tùy chọn) controller cho username / password nếu muốn truy xuất
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Nền gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // WELCOME
                const Text(
                  "WELCOME!",
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),

                // Logo
                Image.asset(
                  "assets/images/logo_log_in.png",
                  height: 200,
                ),
                const SizedBox(height: 30),
                // FORM trắng
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Username Title
                      const Text(
                        "Tên đăng nhập",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Username Input (hint mờ)
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "Nhập số điện thoại hoặc email",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400, // ← hint mờ ở đây
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Password Title
                      const Text(
                        "Mật khẩu",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Password (hint mờ) + eye icon
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "Nhập mật khẩu",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400, // ← hint mờ ở đây
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nút đăng nhập
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: xử lý đăng nhập với _usernameController.text & _passwordController.text
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // trong suốt
                              shadowColor: Colors.transparent, // bỏ bóng mặc định
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Đăng Nhập",
                              style:
                              TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Quên mật khẩu
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Quên mật khẩu?",
                            style: TextStyle(
                                color: Color(0xFF0D1B4C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Hoặc
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "hoặc",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Đăng ký
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpPage()));
                        },
                        child: const Text(
                          "Tạo tài khoản mới",
                          style: TextStyle(
                            color: Color(0xFF0D1B4C),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
