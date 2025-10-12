import 'package:flutter/material.dart';
import '../../domain/models/transaction_input.dart';

class TransferActionButtons extends StatelessWidget {
  final TransactionInput transferData;
  final Duration accountBalance;
  final ValueNotifier<bool> showErrorsNotifier;
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const TransferActionButtons({
    super.key,
    required this.transferData,
    required this.accountBalance,
    required this.showErrorsNotifier,
    required this.onContinue,
    this.onBack,
  });

  bool get isValid {
    final receiverNumber = transferData.recipientAccount;
    final receiverName = transferData.recipientName;
    final timeAmount = transferData.amount;

    if (receiverNumber.isEmpty || receiverName.isEmpty) return false;
    if (timeAmount == Duration.zero) return false;
    if (timeAmount > accountBalance) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF003E77);
    final colorLightBlue =
        const Color(0xFFD6E8F5).withAlpha((0.9 * 255).toInt());

    return Row(
      children: [
        // Nút quay lại
        Expanded(
          flex: 1,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.08 * 255).toInt()),
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
              onPressed: () {
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.pop(context);
                }
              },
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
        ),
        const SizedBox(width: 12),
        // Nút tiếp tục
        Expanded(
          flex: 2,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: colorLightBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorPrimary.withAlpha((0.2 * 255).toInt()),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                if (isValid) {
                  onContinue();
                } else {
                  showErrorsNotifier.value = true;
                }
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
        ),
      ],
    );
  }
}
