import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/transaction_input.dart';
import '../../domain/models/saved_account.dart';
import 'package:time_bank_flutter/features/time_transfer/providers/transaction_providers.dart';
import 'saved_accounts_bottomsheet.dart';
import 'time_picker_dialog.dart';

class TransferDestinationCard extends ConsumerStatefulWidget {
  final ValueChanged<TransactionInput>? onChanged;
  final Duration accountBalance;
  final ValueNotifier<bool> showErrorsNotifier;
  final TransactionInput? value; // giá trị hiện tại được truyền từ container

  const TransferDestinationCard({
    super.key,
    required this.accountBalance,
    required this.showErrorsNotifier,
    this.onChanged,
    this.value,
  });

  @override
  ConsumerState<TransferDestinationCard> createState() => _TransferDestinationCardState();
}

class _TransferDestinationCardState extends ConsumerState<TransferDestinationCard> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final FocusNode accountFocus = FocusNode();
  Duration selectedTime = Duration.zero;

  final Color colorPrimary = const Color(0xFF003E77);
  bool _listenerAttached = false;
  // Khi widget được cập nhật bởi parent (container) chúng ta không muốn
  // phát lại event onChanged (tránh vòng lặp). Dùng flag này để tạm ẩn emit.
  bool _suppressEmit = false;

  // Validation
  bool get isAccountEmpty => accountController.text.trim().isEmpty;
  bool get isNameEmpty => nameController.text.trim().isEmpty;
  bool get isTimeEmpty => selectedTime == Duration.zero;

  @override
  void initState() {
    super.initState();
    accountController.addListener(_onAccountChanged);
    // Khi parent ban đầu truyền value, áp dụng vào controllers ngay lập tức
    final incoming = widget.value;
    if (incoming != null) {
      accountController.text = incoming.recipientAccount;
      nameController.text = incoming.recipientName;
      selectedTime = incoming.amount;
    }
  }

  @override
  void dispose() {
    accountController.removeListener(_onAccountChanged);
    accountController.dispose();
    nameController.dispose();
    accountFocus.dispose();
    super.dispose();
  }

  void _onAccountChanged() async {
    final input = accountController.text.trim();
    if (input.isEmpty) return;

    // Chỉ phát event khi người dùng thay đổi, không phát khi parent cập nhật giá trị
    if (_suppressEmit) return;
    _emitData();
  }

  void _emitData() {
    if (_suppressEmit) return;
    widget.onChanged?.call(TransactionInput(
      recipientName: nameController.text,
      recipientAccount: accountController.text,
      amount: selectedTime,
      note: '',
    ));
    // Không cập nhật controllers ở đây nữa — parent/TransferPage sẽ set lại
    // giá trị bằng cách tái tạo widget với `value` và chúng ta chỉ dùng
    // flag _suppressEmit khi parent cập nhật controllers từ bên ngoài.
  }

  Future<void> _openSavedAccounts() async {
    final savedAccount = await showModalBottomSheet<SavedAccount>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const SavedAccountsBottomSheet(),
    );
    if (savedAccount != null) {
      setState(() {
        accountController.text = savedAccount.number;
        nameController.text = savedAccount.name;
        _emitData();
      });
    }
  }

  Future<void> _openTimePicker() async {
    final Duration? picked = await showDialog<Duration>(
      context: context,
      builder: (_) => const TimePickerDialogCustom(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _emitData();
      });
    }
  }

  String _formatDuration(Duration d) {
    final hh = d.inHours.toString().padLeft(2, '0');
    final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    if (!_listenerAttached) {
      _listenerAttached = true;
      // Lắng nghe provider để reset form khi TransactionFormNotifier.reset() được gọi
      ref.listen<TransactionFormState>(transactionFormProvider, (previous, next) {
          final wasNonEmpty = previous != null && (
            previous.recipient != null ||
            (previous.note).isNotEmpty ||
            previous.amount != Duration.zero ||
            previous.preview.value != null
          );
          final isReset = (next.recipient == null) && (next.note.isEmpty) && (next.amount == Duration.zero) && (next.preview.value == null);
        if (wasNonEmpty && isReset) {
          if (mounted) {
            setState(() {
              accountController.clear();
              nameController.clear();
              selectedTime = Duration.zero;
            });
            FocusScope.of(context).requestFocus(accountFocus);
          }
        }
      });
    }

    // Nếu parent truyền `value` mới, cập nhật controllers nhưng không phát onChanged
    final incoming = widget.value;
    if (incoming != null) {
      if (accountController.text != incoming.recipientAccount || nameController.text != incoming.recipientName || selectedTime != incoming.amount) {
        _suppressEmit = true;
        accountController.text = incoming.recipientAccount;
        nameController.text = incoming.recipientName;
        selectedTime = incoming.amount;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _suppressEmit = false;
        });
      }
    }

    final balance = widget.accountBalance;
    final enough = selectedTime <= balance;

    return ValueListenableBuilder<bool>(
      valueListenable: widget.showErrorsNotifier,
      builder: (context, showErrors, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chuyển đến',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 16),
            _buildInputBox(
              title: 'Số tài khoản',
              hint: 'Nhập số tài khoản',
              controller: accountController,
              icon: Icons.person_outline,
              onIconTap: _openSavedAccounts,
              showError: showErrors && isAccountEmpty,
              errorText: 'Số tài khoản không được để trống',
              focusNode: accountFocus,
            ),
            const SizedBox(height: 20),
            _buildInputBox(
              title: 'Tên người nhận',
              hint: 'Nhập tên người nhận',
              controller: nameController,
              showError: showErrors && isNameEmpty,
              errorText: 'Tên người nhận không được để trống',
            ),
            const SizedBox(height: 20),
            _buildTimeBox(balance, enough, showErrors && isTimeEmpty),
            const SizedBox(height: 20),
            _buildInputBox(
              title: 'Nội dung chuyển',
              hint: '',
              controller: TextEditingController(text: 'LE THANH NAM chuyển: ${_formatDuration(selectedTime)}'),
              maxLines: 2,
              readOnly: true,
            )
          ],
        );
      },
    );
  }

  Widget _buildInputBox({
    required String title,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    VoidCallback? onIconTap,
    int maxLines = 1,
    bool readOnly = false,
    bool showError = false,
    String errorText = '',
    FocusNode? focusNode,
  }) {
    const colorPrimary = Color(0xFF003E77);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha((0.08 * 255).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      maxLines: maxLines,
                      readOnly: readOnly,
                      onChanged: (_) => _emitData(),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.only(top: 4),
                      ),
                    ),
                  ),
                  if (icon != null)
                    GestureDetector(
                      onTap: onIconTap,
                      child: Icon(icon, color: colorPrimary, size: 22),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          )
      ],
    );
  }

  Widget _buildTimeBox(Duration balance, bool enough, bool showError) {
    const colorPrimary = Color(0xFF003E77);

    return GestureDetector(
      onTap: _openTimePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha((0.08 * 255).toInt()),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thời gian cần chuyển',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDuration(selectedTime),
                    style: TextStyle(
                      fontSize: 16,
                      color: enough && !showError ? colorPrimary : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.access_time,
                    color: enough && !showError ? colorPrimary : Colors.red,
                    size: 22),
              ],
            ),
            if (!enough)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Thời gian của bạn không đủ để thanh toán',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            if (showError && selectedTime == Duration.zero)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Bạn chưa chọn thời gian',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
