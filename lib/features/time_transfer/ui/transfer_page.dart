import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/time_transfer/providers/transaction_providers.dart';
import 'package:time_bank_flutter/features/time_transfer/domain/models/recipient.dart';
import 'package:time_bank_flutter/features/time_transfer/domain/models/transaction_input.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/confirm_page.dart';
import 'widgets/source_time_card.dart';
import 'widgets/transfer_action_buttons.dart';
import 'widgets/transfer_destination_card.dart';

class TransferPage extends ConsumerStatefulWidget {
  const TransferPage({super.key});

  @override
  ConsumerState<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends ConsumerState<TransferPage> {
  TransactionInput transferData = const TransactionInput(recipientName: '', recipientAccount: '', amount: Duration.zero, note: '');

  final ValueNotifier<bool> showErrorsNotifier = ValueNotifier(false);

  void _updateTransferData(TransactionInput newData) {
    // Container nhận input từ widget presentational. Thực hiện lookup
    // saved accounts tại đây (container layer) và tự động điền tên nếu tìm thấy.
    final accountsAsync = ref.read(savedAccountsProvider);
    final accounts = accountsAsync.value;
    String resolvedName = newData.recipientName;
    if ((resolvedName.isEmpty) && (accounts != null)) {
      try {
        final found = accounts.firstWhere((a) => a.number == newData.recipientAccount);
        resolvedName = found.name;
      } catch (_) {
        // không tìm thấy, giữ nguyên
      }
    }

    setState(() {
      transferData = newData.copyWith(recipientName: resolvedName);
    });
  }

  bool _listenersAttached = false;

  // Duration parsing is handled by TransactionInput.amount; helper removed.

  Future<void> _handleContinue(BuildContext context) async {
    // Push data into provider and ask provider to create preview
    final notifier = ref.read(transactionFormProvider.notifier);
  // map transferData into domain fields inside notifier
  final receiverName = transferData.recipientName;
  final receiverNumber = transferData.recipientAccount;
  final amount = transferData.amount;

    // set recipient model
    notifier.setRecipient(Recipient(accountNumber: receiverNumber, name: receiverName));
    notifier.setAmount(amount);
    // Build default note via provider helper (moved into notifier)
    final senderName = ref.read(senderNameProvider);
    await notifier.setNoteFromSender(senderName);

    // Nếu widget unmounted sau các await trước đó thì không show dialog
    if (!mounted) return;
    // Show a loading dialog while preview is being fetched
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await notifier.submitPreview();

      final state = ref.read(transactionFormProvider);
      final preview = state.preview.value;
      if (!context.mounted) return;
      if (preview != null) {
        Navigator.pop(context); // close loading
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ConfirmPage(),
          ),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tạo preview')),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tạo preview: $e')),
      );
    }
  }

  String _formatDuration(Duration d) {
    final hh = d.inHours.toString().padLeft(2, '0');
    final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    // Attach the provider listener from inside build (Riverpod requires
    // ref.listen to be called during build). Guard to register only once.
    if (!_listenersAttached) {
      _listenersAttached = true;
      ref.listen<TransactionFormState>(transactionFormProvider, (previous, next) {
            final wasNonEmpty = previous != null && (
              previous.recipient != null ||
              (previous.note).isNotEmpty ||
              previous.amount != Duration.zero ||
              previous.preview.value != null
            );
            final isReset = (next.recipient == null) && (next.note.isEmpty) && (next.amount == Duration.zero) && (next.preview.value == null);
        if (wasNonEmpty && isReset) {
          if (mounted) {
            setState(() {
              transferData = const TransactionInput(recipientName: '', recipientAccount: '', amount: Duration.zero, note: '');
              showErrorsNotifier.value = false;
            });
          }
        }
      });
    }
    const colorPrimary = Color(0xFF003E77);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Chuyển thời gian đến số tài khoản',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SourceTimeCard could be wired to accountBalanceProvider if needed; keep as-is for presentational UI
            SourceTimeCard(balance: ref.read(accountBalanceProvider)),
            const SizedBox(height: 18),
            TransferDestinationCard(
              // Truyền giá trị hiện tại từ container xuống presentational widget
              value: transferData,
              accountBalance: ref.read(accountBalanceProvider),
              onChanged: _updateTransferData,
              showErrorsNotifier: showErrorsNotifier,
            ),
            const SizedBox(height: 32),
            TransferActionButtons(
              transferData: transferData,
              accountBalance: ref.read(accountBalanceProvider),
              showErrorsNotifier: showErrorsNotifier,
              onContinue: () => _handleContinue(context),
              onBack: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
