import '../models/transaction_request.dart';
import '../models/transaction_preview.dart';
import '../models/transaction_result.dart';
import '../models/saved_account.dart';

abstract class TransactionRepository {
  /// Create a preview (calculate fee, reserve transaction id, etc.)
  Future<TransactionPreview> createPreview(TransactionRequest request);

  /// Send OTP for a reserved transaction id
  /// returns otpId or similar
  Future<String> sendOtp(String transactionId);

  /// Verify OTP and finalize transaction
  Future<TransactionResult> confirmWithOtp(String transactionId, String otp);

  /// Return a list of saved accounts for the current user (mocked)
  Future<List<SavedAccount>> getSavedAccounts();

  /// Build a default note string for a transfer given recipient name and amount
  String buildDefaultNote(String senderName, String recipientName, String formattedAmount);
}
