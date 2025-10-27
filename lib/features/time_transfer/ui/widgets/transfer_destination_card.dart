import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/time_transfer/domain/models/recipient_info.dart';
import 'package:time_bank_flutter/features/time_transfer/providers/transaction_providers.dart';
import 'time_picker_dialog.dart';


class TransferDestinationCard extends ConsumerStatefulWidget {
  final String phone;
  final Duration amount;
  final String note;
  final AsyncValue<RecipientInfo?> lookupState;
  final Function(String) onPhoneChanged;
  final Function(String) onPhoneSubmitted;
  final Function(Duration) onAmountChanged;
  final Function(String) onNoteChanged;
  final VoidCallback onLookupPressed;

  const TransferDestinationCard({
    super.key,
    required this.phone,
    required this.amount,
    required this.note,
    required this.lookupState,
    required this.onPhoneChanged,
    required this.onPhoneSubmitted,
    required this.onAmountChanged,
    required this.onNoteChanged,
    required this.onLookupPressed,
  });

  @override
  ConsumerState<TransferDestinationCard> createState() => _TransferDestinationCardState();
}

class _TransferDestinationCardState extends ConsumerState<TransferDestinationCard> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController(); // MỚI
  final FocusNode accountFocus = FocusNode();

  bool _isSyncingNote = false;

  final Color colorPrimary = const Color(0xFF003E77);

  @override
  void initState() {
    super.initState();
    accountController.text = widget.phone;
    noteController.text = widget.note;
    _updateNameController(widget.lookupState);

    accountController.addListener(_onAccountChanged);
    noteController.addListener(_onNoteChanged);
  }

  @override
  void didUpdateWidget(covariant TransferDestinationCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.phone != oldWidget.phone && widget.phone != accountController.text) {
      accountController.text = widget.phone;
    }

    if (widget.note != oldWidget.note && widget.note != noteController.text) {
      _isSyncingNote = true;      // <-- 1. Bật cờ
      noteController.text = widget.note; // <-- 2. Gây ra listener
      _isSyncingNote = false;     // <-- 3. Tắt cờ
    }

    if (widget.lookupState != oldWidget.lookupState) {
      _updateNameController(widget.lookupState);
    }
  }

  void _updateNameController(AsyncValue<RecipientInfo?> lookupState) {
    final newName = lookupState.when(
      data: (recipient) => recipient?.fullName ?? '',
      loading: () => 'Đang tra cứu...',
      error: (e, s) => 'Không tìm thấy',
    );
    if (nameController.text != newName) {
      nameController.text = newName;
    }
  }

  @override
  void dispose() {
    accountController.removeListener(_onAccountChanged);
    noteController.removeListener(_onNoteChanged);
    accountController.dispose();
    nameController.dispose();
    noteController.dispose();
    accountFocus.dispose();
    super.dispose();
  }

  void _onAccountChanged() {
    widget.onPhoneChanged(accountController.text);
  }


  void _onNoteChanged() {
    if (_isSyncingNote) return; // <-- KIỂM TRA CỜ
    widget.onNoteChanged(noteController.text);
  }


  Future<void> _openTimePicker() async {
    final Duration? picked = await showDialog<Duration>(
      context: context,
      builder: (_) => const TimePickerDialogCustom(),
    );
    if (picked != null) {
      widget.onAmountChanged(picked);
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

    // Lấy số dư thật (để check)
    final balanceAsync = ref.watch(accountBalanceProvider);
    final balance = balanceAsync.value?.secs ?? 0;
    final enough = widget.amount.inSeconds <= balance;

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
          hint: 'Nhập số tài khoản (SĐT)',
          controller: accountController,
          icon: Icons.person_search_outlined,
          onIconTap: widget.onLookupPressed,
          onSubmitted: widget.onPhoneSubmitted,
          focusNode: accountFocus,
          keyboardType: TextInputType.phone,
          errorText: widget.lookupState.hasError && !widget.lookupState.isLoading
              ? widget.lookupState.error.toString()
              : null,
        ),
        const SizedBox(height: 20),
        _buildInputBox(
          title: 'Tên người nhận',
          hint: 'Tên hiển thị sau khi tra cứu',
          controller: nameController,
          readOnly: true,
          isLoading: widget.lookupState.isLoading,
        ),
        const SizedBox(height: 20),
        _buildTimeBox(enough),
        const SizedBox(height: 20),
        _buildInputBox(
          title: 'Nội dung chuyển',
          hint: 'Thêm nội dung (không bắt buộc)',
          controller: noteController,
          maxLines: 2,
        )
      ],
    );
  }

  Widget _buildInputBox({
    required String title,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    VoidCallback? onIconTap,
    Function(String)? onSubmitted,
    int maxLines = 1,
    bool readOnly = false,
    bool isLoading = false,
    String? errorText,
    TextInputType? keyboardType,
    FocusNode? focusNode,
  }) {
    const colorPrimary = Color(0xFF003E77);
    final bool showError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: showError ? Colors.red : Colors.transparent), // MỚI
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
                      keyboardType: keyboardType,
                      onSubmitted: onSubmitted, // MỚI
                      // XOÁ: onChanged (đã chuyển lên addListener)
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.only(top: 4),
                      ),
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (icon != null)
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

  Widget _buildTimeBox(bool enough) {
    const colorPrimary = Color(0xFF003E77);
    final bool showError = widget.amount == Duration.zero;

    return GestureDetector(
      onTap: _openTimePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: (enough && !showError) ? Colors.transparent : Colors.red
          ),
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
                    _formatDuration(widget.amount),
                    style: TextStyle(
                      fontSize: 16,
                      color: (enough && !showError) ? colorPrimary : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.access_time,
                    color: (enough && !showError) ? colorPrimary : Colors.red,
                    size: 22),
              ],
            ),
            if (!enough)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Số dư của bạn không đủ',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            if (showError && widget.amount == Duration.zero)
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