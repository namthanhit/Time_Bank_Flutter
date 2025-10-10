import 'package:time_bank_flutter/features/transaction_history/domain/models/transaction_entry.dart';

/// Abstraction for fetching transaction history and current balance.
abstract class TransactionHistoryRepository {
  Future<int> fetchCurrentBalanceSeconds();
  Future<List<TransactionEntry>> fetchTransactions({required DateTime from, required DateTime to});
}
