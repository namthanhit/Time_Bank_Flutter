// no timer/async needed here anymore
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinVerificationDialog extends StatefulWidget {
  /// onSubmit should return true when the OTP is valid.
  final Future<bool> Function(String otp)? onSubmit;

  const PinVerificationDialog({super.key, this.onSubmit});

  @override
  State<PinVerificationDialog> createState() => _PinVerificationDialogState();
}

class _PinVerificationDialogState extends State<PinVerificationDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;
  bool _hasError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF003E77);
  final double sheetHeight = MediaQuery.of(context).size.height * 0.55;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: sheetHeight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Xác thực mã PIN',
                style: TextStyle(
                  color: colorPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 36),

              // 🔹 Các ô nhập mã PIN — gần nhau hơn
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  obscureText: true,
                  obscuringWidget: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: colorPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.circle,
                    fieldHeight: 30,
                    fieldWidth: 30,
                    activeColor: colorPrimary,
                    selectedColor: colorPrimary,
                    inactiveColor: Colors.grey.shade300, // 🔹 Các ô tròn gần nhau hơn
                  ),
                  onChanged: (_) {},
                  onCompleted: (value) async {
                    setState(() {
                      _isSubmitting = true;
                      _hasError = false;
                    });

                    bool success = false;
                    try {
                      success = await (widget.onSubmit?.call(value) ?? Future.value(false));
                    } catch (_) {
                      success = false;
                    }

                    if (!mounted) return;
                    setState(() {
                      _isSubmitting = false;
                    });

                    if (success) {
                      Navigator.of(context).pop(true);
                    } else {
                      setState(() {
                        _hasError = true;
                      });
                      _controller.clear();
                    }
                  },
                ),
              ),

              if (_isSubmitting) ...[
                const SizedBox(height: 12),
                const CircularProgressIndicator(),
              ] else ...[
                const SizedBox(height: 24),
                Text(
                  _hasError ? 'Nhập sai mã PIN' : 'Vui lòng nhập mã PIN để xác thực giao dịch',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _hasError ? Colors.red : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
