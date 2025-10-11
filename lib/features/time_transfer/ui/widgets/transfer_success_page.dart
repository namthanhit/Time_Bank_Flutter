import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/transfer_page.dart';
import '../../domain/models/transaction_ui_data.dart';
import '../../providers/transaction_providers.dart';

class TransferSuccessPage extends ConsumerWidget {
  final TransactionUiData data;

  const TransferSuccessPage({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const colorPrimary = Color(0xFF003E77);
    const colorSuccess = Color(0xFF2ECC71); // xanh lá cây

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Nền xanh phía trên
          Container(
            height: 250,
            color: colorPrimary,
          ),

          // Nội dung chính
          SingleChildScrollView(
            child: Column(
              children: [
                // Box trắng chính
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 60, left: 16, right: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.25),
                          blurRadius: 15,
                          spreadRadius: 3,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dấu tích xanh lá - nền xanh, icon trắng
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: colorSuccess,
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 12),

                        // Tiêu đề
                        const Text(
                          "Chuyển thời gian thành công",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Thời gian
                        Text(
                          data.timeAmount,
                          style: const TextStyle(
                            fontSize: 34,
                            color: colorPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('HH:mm - dd/MM/yyyy')
                              .format(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Box người nhận
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                data.recipientName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: colorPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data.recipientAccount,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                '${data.senderName} chuyển khoản',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          "Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        const SizedBox(height: 36),

                        // 3 nút chia sẻ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _ActionButton(
                                icon: Icons.share_outlined, label: "Chia sẻ"),
                            _ActionButton(
                                icon: Icons.home_outlined, label: "Trang chủ"),
                            _ActionButton(
                                icon: Icons.download_outlined,
                                label: "Lưu ảnh"),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Nút nằm ngoài box trắng, canh đều lề như box
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Reset the transaction form so previous inputs are cleared
                        ref.read(transactionFormProvider.notifier).reset();
                        // Replace this success page with a fresh TransferPage.
                        // This ensures the user lands on the Transfer flow ready to start a new transaction.
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const TransferPage()),
                        );
                      },
                      child: const Text(
                        "Thực hiện giao dịch khác",
                        style: TextStyle(fontSize: 17.5, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// WIDGET: Action Button (icon tròn + nhãn nhỏ)
// ================================================================
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFBDBDBD);
    const iconColor = Color(0xFF666666);

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(30),
          splashColor: const Color(0x22003E77),
          onTap: () {},
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
