import 'package:flutter/material.dart';
import 'menu_button.dart';
import '../home_typography.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, this.onTransfer, this.onQr, this.onHistory});

  final VoidCallback? onTransfer;
  final VoidCallback? onQr;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('Tiện ích', style: HomeTypography.sectionTitle),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuButton(
                icon: Icons.attach_money,
                label: 'Chuyển tiền',
                onTap: onTransfer,
              ),
              const SizedBox(width: 50),
              MenuButton(
                icon: Icons.qr_code_scanner_rounded,
                label: 'QR',
                onTap: onQr,
              ),
              const SizedBox(width: 50),
              MenuButton(
                icon: Icons.history,
                label: 'Lịch sử\nGiao dịch',
                onTap: onHistory,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
