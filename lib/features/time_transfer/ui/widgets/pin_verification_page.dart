import 'package:flutter/material.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<String> otp = List.filled(6, '');

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF003E77);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Xác thực OTP',
                style: TextStyle(
                  color: colorPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 30),

              // Các ô tròn nhập PIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: otp[index].isNotEmpty
                          ? colorPrimary
                          : const Color(0xFFD9D9D9),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 25),
              const Text(
                'Vui lòng nhập mã PIN Digital OTP để xác thực giao dịch',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(180, 45),
                ),
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
