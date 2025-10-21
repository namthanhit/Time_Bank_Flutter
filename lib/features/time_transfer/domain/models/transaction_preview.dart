class TransactionPreview {
  final String transactionId;
  final String displayAmount; // e.g. "01:30:00"
  final String recipientName;
  final String recipientAccount;
  final String feeDisplay; // e.g. "0:00:10" or "No fee"

  TransactionPreview({
    required this.transactionId,
    required this.displayAmount,
    required this.recipientName,
    required this.recipientAccount,
    required this.feeDisplay,
  });
}
