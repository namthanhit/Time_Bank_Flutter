import 'package:flutter/foundation.dart';

@immutable
class TransactionInput {
  final String recipientName;
  final String recipientAccount;
  final Duration amount;
  final String note;

  const TransactionInput({
    required this.recipientName,
    required this.recipientAccount,
    required this.amount,
    required this.note,
  });

  TransactionInput copyWith({
    String? recipientName,
    String? recipientAccount,
    Duration? amount,
    String? note,
  }) {
    return TransactionInput(
      recipientName: recipientName ?? this.recipientName,
      recipientAccount: recipientAccount ?? this.recipientAccount,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }
}
