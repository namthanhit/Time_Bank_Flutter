import 'dart:async';
import 'package:uuid/uuid.dart';

import '../domain/models/transaction_request.dart';
import '../domain/models/transaction_preview.dart';
import '../domain/models/transaction_result.dart';
import '../domain/models/saved_account.dart';
import '../domain/repositories/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  final _uuid = Uuid();

  @override
  Future<TransactionPreview> createPreview(TransactionRequest request) async {
    await Future.delayed(const Duration(milliseconds: 700)); // simulate network
    final id = _uuid.v4();

  // Fee is free for transfers — set fee to zero
  final feeSeconds = 0;

    String formatDur(Duration d) {
      final hh = d.inHours.toString().padLeft(2, '0');
      final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
      final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
      return '$hh:$mm:$ss';
    }

    return TransactionPreview(
      transactionId: id,
      displayAmount: formatDur(request.amount),
      recipientName: request.recipient.name,
      recipientAccount: request.recipient.accountNumber,
  feeDisplay: feeSeconds == 0 ? 'Miễn phí' : formatDur(Duration(seconds: feeSeconds)),
    );
  }

  @override
  Future<String> sendOtp(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In mock, OTP is always "123456"
    return 'otp_id_$transactionId';
  }

  @override
  Future<TransactionResult> confirmWithOtp(String transactionId, String otp) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (otp.trim() == '123456') {
      return TransactionResult(
        transactionId: transactionId,
        success: true,
        message: 'Giao dịch thành công',
      );
    }
    return TransactionResult(
      transactionId: transactionId,
      success: false,
      message: 'OTP không chính xác',
    );
  }

  @override
  @override
  Future<List<SavedAccount>> getSavedAccounts() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return const [
      SavedAccount(name: 'LE THANH NAM', number: '0123456789'),
      SavedAccount(name: 'NGUYEN DANH HIEU', number: '9876543210'),
      SavedAccount(name: 'NGUYEN VAN A', number: '7777777777'),
      SavedAccount(name: 'TRAN THI B', number: '0123654987'),
      SavedAccount(name: 'PHAM VAN C', number: '9999999999'),
    ];
  }

  @override
  String buildDefaultNote(String senderName, String recipientName, String formattedAmount) {
    final content = '$senderName chuyển $formattedAmount cho $recipientName';
    return content.length > 200 ? content.substring(0, 200) : content;
  }
}
