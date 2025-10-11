import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/confirm_page.dart';
// import '../pages/confirm_page.dart';

class TransferActionButtons extends StatelessWidget {
  const TransferActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF003E77);
    final colorLightBlue = const Color(0xFFD6E8F5).withOpacity(0.9);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Nút "Quay lại" — ngắn hơn, bóng nhẹ
        Container(
          width: 120,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 2),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Quay lại',
              style: TextStyle(
                color: colorPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Nút "Tiếp tục" — dài hơn, bóng mạnh hơn
        Container(
          width: 280,
          height: 46,
          decoration: BoxDecoration(
            color: colorLightBlue,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF003E77).withOpacity(0.2),
                offset: const Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // để lấy màu từ BoxDecoration
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConfirmPage()),
              );
            },
            child: const Text(
              'Tiếp tục',
              style: TextStyle(
                color: colorPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
