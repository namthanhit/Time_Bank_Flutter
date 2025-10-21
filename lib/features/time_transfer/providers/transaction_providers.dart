import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/recipient.dart';
import '../domain/models/transaction_request.dart';
import '../domain/models/transaction_preview.dart';
import '../domain/models/transaction_result.dart';
import '../domain/repositories/transaction_repository.dart';
import '../data/mock_transaction_repository.dart';
import '../domain/models/transaction_ui_data.dart';
import '../domain/models/saved_account.dart';

// Repository binding: swap to HttpTransactionRepository when backend ready
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return MockTransactionRepository();
});

/// Form state kept in a StateNotifier
class TransactionFormState {
  final Recipient? recipient;
  final Duration amount;
  final String note;
  final DateTime? scheduledAt;
  final AsyncValue<TransactionPreview?> preview; // null = no preview yet
  final bool sendingOtp;
  final AsyncValue<TransactionResult?> result; // result after confirm

  TransactionFormState({
    this.recipient,
    this.amount = const Duration(),
    this.note = '',
    this.scheduledAt,
    this.preview = const AsyncValue.data(null),
    this.sendingOtp = false,
    this.result = const AsyncValue.data(null),
  });

  TransactionFormState copyWith({
    Recipient? recipient,
    Duration? amount,
    String? note,
    DateTime? scheduledAt,
    AsyncValue<TransactionPreview?>? preview,
    bool? sendingOtp,
    AsyncValue<TransactionResult?>? result,
  }) {
    return TransactionFormState(
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      preview: preview ?? this.preview,
      sendingOtp: sendingOtp ?? this.sendingOtp,
      result: result ?? this.result,
    );
  }
}

class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  final Ref ref;
  TransactionFormNotifier(this.ref) : super(TransactionFormState());

  void setRecipient(Recipient r) => state = state.copyWith(recipient: r);

  void setAmount(Duration d) => state = state.copyWith(amount: d);

  void setNote(String note) => state = state.copyWith(note: note);

  void setScheduledAt(DateTime dt) => state = state.copyWith(scheduledAt: dt);

  /// Build a default note using the repository and set it on the form state.
  Future<void> setNoteFromSender(String senderName) async {
    final repo = ref.read(transactionRepositoryProvider);
    final recipient = state.recipient;
    if (recipient == null) return;
    final formattedAmount = (() {
      final d = state.amount;
      final hh = d.inHours.toString().padLeft(2, '0');
      final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
      final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
      return '$hh:$mm:$ss';
    })();

    final note = repo.buildDefaultNote(senderName, recipient.name, formattedAmount);
    state = state.copyWith(note: note);
  }

  /// Create preview via repository
  Future<void> submitPreview() async {
    final repo = ref.read(transactionRepositoryProvider);
    final recipient = state.recipient;
    if (recipient == null) {
      state = state.copyWith(preview: AsyncValue.error('Vui lòng nhập thông tin người nhận', StackTrace.current));
      return;
    }
    final req = TransactionRequest(
      recipient: recipient,
      amount: state.amount,
      note: state.note,
      scheduledAt: state.scheduledAt,
    );
    state = state.copyWith(preview: const AsyncValue.loading());
    try {
      final preview = await repo.createPreview(req);
      state = state.copyWith(preview: AsyncValue.data(preview));
    } catch (e, st) {
      state = state.copyWith(preview: AsyncValue.error(e, st));
    }
  }

  /// Send OTP for current preview transactionId
  Future<void> sendOtp() async {
    final repo = ref.read(transactionRepositoryProvider);
    final preview = state.preview.value;
    if (preview == null) {
      return;
    }
    state = state.copyWith(sendingOtp: true);
    try {
      await repo.sendOtp(preview.transactionId);
    } catch (e) {
      // for mock we ignore
    } finally {
      state = state.copyWith(sendingOtp: false);
    }
  }

  /// Verify OTP and finalize
  Future<void> confirmWithOtp(String otp) async {
    final repo = ref.read(transactionRepositoryProvider);
    final preview = state.preview.value;
    if (preview == null) return;
    state = state.copyWith(result: const AsyncValue.loading());
    try {
      final res = await repo.confirmWithOtp(preview.transactionId, otp);
      state = state.copyWith(result: AsyncValue.data(res));
    } catch (e, st) {
      state = state.copyWith(result: AsyncValue.error(e, st));
    }
  }

  /// Reset state (after success)
  void reset() {
    state = TransactionFormState();
  }
}

final transactionFormProvider = StateNotifierProvider<TransactionFormNotifier, TransactionFormState>(
      (ref) => TransactionFormNotifier(ref),
);

/// UI-level mapping from form state + preview -> TransactionUiData
final transactionUiDataProvider = Provider<TransactionUiData?>((ref) {
  final state = ref.watch(transactionFormProvider);
  final preview = state.preview.value;
  if (preview == null) return null;
  return TransactionUiData(
    recipientName: preview.recipientName,
    recipientAccount: preview.recipientAccount,
    timeAmount: preview.displayAmount,
    fee: preview.feeDisplay,
    transactionId: preview.transactionId,
    note: state.note,
  );
});

/// Provide saved accounts from repository (mock or http)
final savedAccountsProvider = FutureProvider<List<SavedAccount>>((ref) async {
  final repo = ref.read(transactionRepositoryProvider);
  return repo.getSavedAccounts();
});

/// Current account balance for the sender. Can be made mutable with StateProvider when needed.
final accountBalanceProvider = Provider<Duration>((ref) {
  // default mock balance: 10h45m
  return const Duration(hours: 10, minutes: 45);
});

/// Mock sender name provider — replace with real profile provider later.
final senderNameProvider = Provider<String>((ref) {
  return 'LE THANH NAM';
});

