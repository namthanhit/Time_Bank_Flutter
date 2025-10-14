class TransactionUiData {
  final String recipientName;
  final String recipientAccount;
  final String timeAmount;
  final String fee;
  final String transactionId;
  final String note;
  final String senderName;
  final String senderNumber;

  TransactionUiData({
    required this.recipientName,
    required this.recipientAccount,
    required this.timeAmount,
    required this.fee,
    required this.transactionId,
    this.note = '',
    this.senderName = 'LE THANH NAM',
    this.senderNumber = '0123456789',
  });
}
