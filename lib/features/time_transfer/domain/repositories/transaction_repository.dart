import '../transaction_request.dart';
import '../transaction_preview.dart';
import '../transaction_result.dart';

abstract class TransactionRepository {
  /// Create a preview (calculate fee, reserve transaction id, etc.)
  Future<TransactionPreview> createPreview(TransactionRequest request);

  /// Send OTP for a reserved transaction id
  /// returns otpId or similar
  Future<String> sendOtp(String transactionId);

  /// Verify OTP and finalize transaction
  Future<TransactionResult> confirmWithOtp(String transactionId, String otp);
}
