import 'dart:math';
import 'package:time_bank_flutter/features/transaction_history/domain/models/transaction_entry.dart';
import 'package:time_bank_flutter/features/transaction_history/domain/repositories/transaction_history_repository.dart';

/// Mock implementation generating deterministic sample data.
class MockTransactionHistoryRepository implements TransactionHistoryRepository {
  MockTransactionHistoryRepository({int seed = 42}) : _rand = Random(seed);
  final Random _rand;

  @override
  Future<int> fetchCurrentBalanceSeconds() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return 3630; // 01:00:30
  }

  @override
  Future<List<TransactionEntry>> fetchTransactions({required DateTime from, required DateTime to}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final List<TransactionEntry> items = [];
    DateTime cursor = from;
    int balance = 3600; // start 1h
    int id = 1;
    while (cursor.isBefore(to)) {
      // maybe 0-2 transactions per day
      final count = _rand.nextInt(3);
      for (int i = 0; i < count; i++) {
        final bool outgoing = _rand.nextBool();
        final delta = (outgoing ? -1 : 1) * (600 + _rand.nextInt(1800));
        balance += delta;
        final date = DateTime(cursor.year, cursor.month, cursor.day, 10 + i, 30 + i, 20 + i);
        items.add(TransactionEntry(
          id: 'tx$id',
          direction: outgoing ? TransactionDirection.out : TransactionDirection.incoming,
          status: TransferStatus.completed,
            deltaSecs: delta,
          balanceAfterSecs: balance,
          occurredAt: date,
          senderName: outgoing ? 'LE THANH NAM' : 'BUI NGOC DUC',
          senderAccount: '29374022$id',
          receiverName: outgoing ? 'BUI NGOC DUC' : 'LE THANH NAM',
          receiverAccount: '29374055$id',
          note: outgoing ? 'Chuyen thoi gian cho ban be' : 'Nhan thoi gian tu ban',
        ));
        id++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return items;
  }
}
