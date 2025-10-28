// lib/features/time_transfer/ui/transfer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/time_transfer/providers/transaction_providers.dart';
import 'package:time_bank_flutter/features/time_transfer/ui/confirm_page.dart';
import 'widgets/source_time_card.dart';
import 'widgets/transfer_action_buttons.dart';
import 'widgets/transfer_destination_card.dart';
import 'package:time_bank_flutter/features/auth/providers/auth_providers.dart';
// 1. IMPORT TRANG QR SCANNER
import 'package:time_bank_flutter/features/qr/ui/qr_scanner_page.dart';

// 2. CHUYỂN TỪ ConsumerWidget SANG ConsumerStatefulWidget
class TransferPage extends ConsumerStatefulWidget {
  // 3. THÊM THAM SỐ NÀY ĐỂ NHẬN SĐT
  final String? prefilledPhoneNumber;

  // 4. THÊM VÀO CONSTRUCTOR
  const TransferPage({super.key, this.prefilledPhoneNumber});

  @override
  ConsumerState<TransferPage> createState() => _TransferPageState();
}

// 5. TẠO CLASS STATE (thay cho hàm build gốc)
class _TransferPageState extends ConsumerState<TransferPage> {

  // 6. DÙNG initState ĐỂ CẬP NHẬT SĐT VÀO PROVIDER
  @override
  void initState() {
    super.initState();

    // Lấy SĐT được truyền vào
    final prefilledPhone = widget.prefilledPhoneNumber;

    if (prefilledPhone != null && prefilledPhone.isNotEmpty) {
      // Dùng postFrameCallback để đảm bảo build xong
      // mới gọi notifier, tránh lỗi
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 'ref' có sẵn trong ConsumerState
        final notifier = ref.read(transactionFormProvider.notifier);

        // Cập nhật SĐT vào state
        notifier.setToPhone(prefilledPhone);

        // Tự động tra cứu SĐT đó luôn
        notifier.lookupRecipient();
      });
    }
  }

  /// 7. HÀM ĐỂ MỞ TRANG QUÉT MÃ QR (như đã làm)
  void _openQrScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (pageContext) => QrScannerPage(
          onScanSuccess: (scannedPhone) {
            // Khi quét xong, thay thế trang scan
            // bằng một trang Transfer MỚI với SĐT mới
            Navigator.of(pageContext).pushReplacement(
              MaterialPageRoute(
                builder: (_) => TransferPage(
                  prefilledPhoneNumber: scannedPhone,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 8. DI CHUYỂN TOÀN BỘ CODE TRONG HÀM BUILD CŨ VÀO ĐÂY
  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF003E77);

    // 'ref' đã có sẵn, không cần tham số 'WidgetRef ref'
    final formState = ref.watch(transactionFormProvider);
    final notifier = ref.read(transactionFormProvider.notifier);
    final balanceAsync = ref.watch(accountBalanceProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    ref.listen<AsyncValue<bool>>(
      transactionFormProvider.select((state) => state.check),
          (previous, next) {
        if (next.isLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } else if (next.hasError) {
          Navigator.pop(context); // Tắt loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text((next.error as Exception).toString().replaceFirst("Exception: ", ""))),
          );
        } else if (next.hasValue && next.value == true) {
          Navigator.pop(context); // Tắt loading
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ConfirmPage()),
          );
        }
      },
    );

    void handleContinue() {
      if (formState.toPhone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập số tài khoản')),
        );
        return;
      }
      if (formState.lookup.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đang tra cứu, vui lòng đợi...')),
        );
        return;
      }
      if (formState.lookup.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy người nhận này')),
        );
        return;
      }
      if (formState.amount.inSeconds <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số thời gian phải lớn hơn 0')),
        );
        return;
      }

      notifier.submitCheck();
    }

    ref.listen<TransactionFormState>(transactionFormProvider, (previous, next) {
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        // ... (code AppBar y hệt)
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
            SourceTimeCard(
              balanceAsync: balanceAsync,
              userProfileAsync: userProfileAsync,
            ),
            const SizedBox(height: 18),

            TransferDestinationCard(
              phone: formState.toPhone,
              amount: formState.amount,
              note: formState.note,
              lookupState: formState.lookup,
              onPhoneChanged: notifier.setToPhone,
              onPhoneSubmitted: (phone) => notifier.lookupRecipient(),
              onAmountChanged: notifier.setAmount,
              onNoteChanged: notifier.setNote,
              onLookupPressed: notifier.lookupRecipient,
              showFieldErrors: formState.check.hasError,
              // 9. THÊM NÚT QR VÀO ĐÂY (GIẢ SỬ)
              // (Tôi đoán là widget này có tham số để thêm icon)
              // (Nếu không có, ông phải sửa 'TransferDestinationCard')
              //
              // NẾU `TransferDestinationCard` không hỗ trợ, ông có
              // thể bọc nó trong 1 Column và thêm nút QR bên cạnh
              onQrPressed: () => _openQrScanner(context),
            ),
            const SizedBox(height: 32),

            TransferActionButtons(
              isEnabled: formState.lookup.hasValue &&
                  formState.lookup.value != null &&
                  formState.amount.inSeconds > 0 &&
                  !formState.check.isLoading &&
                  !formState.lookup.isLoading,
              onContinue: handleContinue,
              onBack: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}