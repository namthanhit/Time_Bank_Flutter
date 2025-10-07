import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/transaction_history/data/mock_transaction_history_repository.dart';
import 'package:time_bank_flutter/features/transaction_history/domain/models/transaction_entry.dart';
import 'package:time_bank_flutter/features/transaction_history/domain/repositories/transaction_history_repository.dart';

// Repository provider (swap to HTTP implementation later)
final transactionHistoryRepositoryProvider = Provider<TransactionHistoryRepository>((ref) {
  return MockTransactionHistoryRepository();
});

// Date range state (initial: last 30 days)
final transactionRangeProvider = StateProvider<({DateTime from, DateTime to})>((ref) {
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
  final to = DateTime(now.year, now.month, now.day);
  return (from: from, to: to);
});

// Current balance
final currentBalanceProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(transactionHistoryRepositoryProvider);
  return repo.fetchCurrentBalanceSeconds();
});

// Transactions list
final transactionsProvider = FutureProvider<List<TransactionEntry>>((ref) async {
  final range = ref.watch(transactionRangeProvider);
  final repo = ref.watch(transactionHistoryRepositoryProvider);
  return repo.fetchTransactions(from: range.from, to: range.to);
});
