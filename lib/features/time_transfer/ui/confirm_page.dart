import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/widgets/confirm_info_card.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/widgets/confirm_warning_box.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/widgets/confirm_action_buttons.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/widgets/pin_verification_page.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/widgets/transfer_success_page.dart';
import 'package:time_bank_flutter/features/time_transfer/providers/transaction_providers.dart';

class ConfirmPage extends ConsumerWidget {
  const ConfirmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const colorPrimary = Color(0xFF003E77);

  Future<void> onRequestOtp() async {
      final notifier = ref.read(transactionFormProvider.notifier);
      // Tell provider to send OTP; provider will use current preview transaction id
      await notifier.sendOtp();
      if (!context.mounted) return;
      // show pin dialog and await result. The dialog will call the provided
      // onSubmit, which should return true if the OTP is valid.
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PinVerificationDialog(
          onSubmit: (otp) async {
            // perform confirm and return success flag
            await notifier.confirmWithOtp(otp);
            final state = ref.read(transactionFormProvider);
            final res = state.result.value;
            return res?.success ?? false;
          },
        ),
      );

      if (result == true && context.mounted) {
        final currentUiData = ref.read(transactionUiDataProvider);
        if (currentUiData != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => TransferSuccessPage(data: currentUiData)),
          );
        } else {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      }
    }

  final uiData = ref.watch(transactionUiDataProvider);

  return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Xác nhận thông tin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F8FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (uiData != null) ConfirmInfoCard(data: uiData) else const SizedBox.shrink(),
            const SizedBox(height: 16),
            const ConfirmWarningBox(),
            const SizedBox(height: 24),
            if (uiData != null)
              ConfirmActionButtons(
                data: uiData,
                onRequestOtp: onRequestOtp,
                onBack: () => Navigator.pop(context),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}


