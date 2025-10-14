class TransactionResult {
  final String transactionId;
  final bool success;
  final String message;

  TransactionResult({
    required this.transactionId,
    required this.success,
    required this.message,
  });
}
