import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/recipient_info.dart';
import '../domain/models/check_request.dart';
import '../domain/models/create_transfer_request.dart';
import '../domain/models/transfer_result.dart';
import '../domain/models/wallet_balance.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/repositories/wallet_repository.dart';
import '../data/api_transaction_repository.dart';
import '../data/api_wallet_repository.dart';
import '../../auth/providers/auth_providers.dart';


// --- PROVIDERS ---

// (1) WalletRepository
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  // SỬA LẠI: Dùng authedApiClientProvider
  final authedApi = ref.watch(authedApiClientProvider);
  return ApiWalletRepository(authedApi);
});

// (2) TransactionRepository
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  // SỬA LẠI: Dùng authedApiClientProvider
  final authedApi = ref.watch(authedApiClientProvider);
  return ApiTransactionRepository(authedApi);
});

// (3) Provider số dư
final accountBalanceProvider = FutureProvider<WalletBalance>((ref) {
  // 1. Lắng nghe trạng thái xác thực
  final isAuthenticated = ref.watch(authControllerProvider.select((s) => s.authenticated));

  // 2. Nếu chưa đăng nhập, ném lỗi
  if (!isAuthenticated) {
    throw Exception('Chưa đăng nhập');
  }

  // 3. (Giữ nguyên) Lấy repo và gọi API
  //    (Sẽ chạy lại khi isAuthenticated = true)
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getMyWallet();
});

// (4) Provider tên người gửi (lấy từ auth provider)
final senderNameProvider = Provider<String>((ref) {
  final userProfileAsync = ref.watch(userProfileProvider);
  return userProfileAsync.when(
    data: (profile) => profile.fullName,
    loading: () => 'Đang tải...',
    error: (e, st) => 'Bạn', // Tên dự phòng
  );
});

// --- STATE NOTIFIER (Giữ nguyên như cũ) ---

class TransactionFormState {
  // ... (giữ nguyên)
  final String toPhone;
  final Duration amount;
  final String note;
  final AsyncValue<RecipientInfo?> lookup;
  final AsyncValue<bool> check;
  final AsyncValue<TransferResult?> execute;

  TransactionFormState({
    this.toPhone = '',
    this.amount = const Duration(),
    this.note = '',
    this.lookup = const AsyncValue.data(null),
    this.check = const AsyncValue.data(false),
    this.execute = const AsyncValue.data(null),
  });

  TransactionFormState copyWith({
    String? toPhone,
    Duration? amount,
    String? note,
    AsyncValue<RecipientInfo?>? lookup,
    AsyncValue<bool>? check,
    AsyncValue<TransferResult?>? execute,
  }) {
    // ... (logic copyWith giữ nguyên)
    return TransactionFormState(
      toPhone: toPhone ?? this.toPhone,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      lookup: lookup ?? this.lookup,
      check: check ?? this.check,
      execute: execute ?? this.execute,
    );
  }
}

class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  final Ref ref;
  TransactionFormNotifier(this.ref) : super(TransactionFormState());

  // ... (Tất cả logic (lookup, check, execute) giữ nguyên)

  void setToPhone(String phone) => state = state.copyWith(toPhone: phone, lookup: const AsyncValue.data(null), check: const AsyncValue.data(false));
  void setAmount(Duration d) => state = state.copyWith(amount: d, check: const AsyncValue.data(false));
  void setNote(String note) => state = state.copyWith(note: note, check: const AsyncValue.data(false));

  Future<void> lookupRecipient() async {
    if (state.toPhone.isEmpty) return;
    state = state.copyWith(lookup: const AsyncValue.loading());
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final recipient = await repo.lookupRecipient(state.toPhone);
      state = state.copyWith(lookup: AsyncValue.data(recipient));
      _updateDefaultNote(recipient.fullName);
    } catch (e, st) {
      state = state.copyWith(lookup: AsyncValue.error(e, st));
    }
  }

  Future<void> submitCheck() async {
    final recipient = state.lookup.value;
    if (recipient == null) return;

    final req = CheckRequest(
      toPhone: state.toPhone,
      secs: state.amount.inSeconds,
    );

    state = state.copyWith(check: const AsyncValue.loading());
    try {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.checkTransaction(req);
      state = state.copyWith(check: const AsyncValue.data(true));
    } catch (e, st) {
      state = state.copyWith(check: AsyncValue.error(e, st));
    }
  }

  Future<void> executeTransfer(String pin) async {
    print('NOTIFIER: executeTransfer called with PIN.'); // <-- THÊM
    final recipient = state.lookup.value;
    if (recipient == null || !state.check.hasValue || !state.check.value!) {
      print('NOTIFIER: Pre-conditions failed. Aborting.'); // <-- THÊM
      return;
    }

    final req = CreateTransferRequest(
      toPhone: state.toPhone,
      secs: state.amount.inSeconds,
      note: state.note.isEmpty ? null : state.note,
      pin: pin,
    );

    state = state.copyWith(execute: const AsyncValue.loading());
    try {
      final repo = ref.read(transactionRepositoryProvider);
      print('NOTIFIER: Calling repository executeTransfer...'); // <-- THÊM
      final result = await repo.executeTransfer(req);
      print('NOTIFIER: Repository call successful. Result: ${result.id}'); // <-- THÊM
      // Chỉ set state data nếu widget còn mounted (an toàn hơn)
      if (mounted) {
        state = state.copyWith(execute: AsyncValue.data(result));
      }
    } catch (e, st) {
      print('NOTIFIER: Repository call failed: $e'); // <-- THÊM
      // Chỉ set state error nếu widget còn mounted
      if (mounted) {
        state = state.copyWith(execute: AsyncValue.error(e, st));
      }
      // Quan trọng: Ném lại lỗi để PinVerificationDialog bắt được
      throw e;
    }
  }

  void _updateDefaultNote(String recipientName) {
    final repo = ref.read(transactionRepositoryProvider);
    final senderName = ref.read(senderNameProvider);
    final d = state.amount;
    final hh = d.inHours.toString().padLeft(2, '0');
    final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    final formattedAmount = '$hh:$mm:$ss';

    final note = repo.buildDefaultNote(senderName, recipientName, formattedAmount);
    state = state.copyWith(note: note);
  }

  void reset() {
    state = TransactionFormState();
  }
}

final transactionFormProvider =
AutoDisposeStateNotifierProvider<TransactionFormNotifier, TransactionFormState>(
      (ref) => TransactionFormNotifier(ref),
);