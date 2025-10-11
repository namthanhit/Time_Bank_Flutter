import 'recipient.dart';

class TransactionRequest {
  final Recipient recipient;
  final Duration amount; // amount as duration (hh:mm:ss)
  final String? note;
  final DateTime? scheduledAt;

  TransactionRequest({
    required this.recipient,
    required this.amount,
    this.note,
    this.scheduledAt,
  });

  Map<String, dynamic> toJson() => {
    'recipient': recipient.toJson(),
    'amountSeconds': amount.inSeconds,
    'note': note,
    'scheduledAt': scheduledAt?.toIso8601String(),
  };
}
