import 'package:flutter/material.dart';
import 'menu_button.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, this.onTransfer, this.onQr, this.onHistory});

  final VoidCallback? onTransfer;
  final VoidCallback? onQr;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuButton(
            icon: Icons.attach_money,
            label: 'Chuyển tiền',
            color: const Color.fromARGB(255, 97, 197, 149),
            onTap: onTransfer,
          ),
          MenuButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'QR',
            color: const Color(0xFFDB7A00),
            onTap: onQr,
          ),
          MenuButton(
            icon: Icons.history,
            label: 'Lịch sử\nGiao dịch',
            color: const Color.fromARGB(255, 62, 121, 229),
            onTap: onHistory,
          ),
        ],
      ),
    );
  }
}
