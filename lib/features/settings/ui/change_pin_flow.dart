import 'package:flutter/material.dart';

class ChangePinFlow extends StatefulWidget {
  const ChangePinFlow({Key? key}) : super(key: key);

  @override
  State<ChangePinFlow> createState() => _ChangePinFlowState();
}

class _ChangePinFlowState extends State<ChangePinFlow> {
  int step = 0; // 0: current PIN, 1: new+confirm PIN
  final TextEditingController _controllerCurrent = TextEditingController();
  final FocusNode _focusNodeCurrent = FocusNode();
  String _pinCurrent = '';
  final TextEditingController _controllerNew = TextEditingController();
  final FocusNode _focusNodeNew = FocusNode();
  String _pinNew = '';
  final TextEditingController _controllerConfirm = TextEditingController();
  final FocusNode _focusNodeConfirm = FocusNode();
  String _pinConfirm = '';

  void next() {
    if (step == 0) {
      setState(() {
        step = 1;
        _controllerCurrent.clear();
        _pinCurrent = '';
      });
    } else {
      // validate new/confirm PIN here if needed
      Navigator.of(context).pop();
    }
  }

  void back() {
    if (step == 0) Navigator.of(context).pop();
    else setState(() => step = 0);
  }

  @override
  void dispose() {
    _controllerCurrent.dispose();
    _focusNodeCurrent.dispose();
    _controllerNew.dispose();
    _focusNodeNew.dispose();
    _controllerConfirm.dispose();
    _focusNodeConfirm.dispose();
    super.dispose();
  }

  Widget _pinBoxes(double maxWidth, String pin, FocusNode focusNode) {
    final Color brand = const Color(0xFF003E77);
    final int count = 6;
    final double spacing = 10;
    double boxSize = 28;
    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final filled = i < pin.length;
          return Container(
            margin: EdgeInsets.symmetric(horizontal: spacing / 2),
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? brand : Colors.transparent,
              border: Border.all(color: filled ? brand : Colors.grey[400]!, width: 1.0),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color brand = const Color(0xFF003E77); // app main color
    final titles = ['Nhập mã PIN hiện tại', 'Nhập mã PIN mới', 'Xác nhận mã PIN mới'];
    final subtitles = [
      'Vui lòng nhập mã PIN 6 số hiện tại của bạn',
      'Vui lòng nhập mã PIN 6 số mới',
      'Vui lòng nhập lại mã PIN mới để xác nhận'
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(step == 0 ? 'Nhập mã PIN hiện tại' : 'Đổi mã PIN mới'), centerTitle: true, elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 12),
            CircleAvatar(radius: 28, backgroundColor: brand.withOpacity(0.12), child: Icon(Icons.vpn_key, color: brand)),
            SizedBox(height: 12),
            Text(step == 0 ? 'Nhập mã PIN hiện tại' : 'Đổi mã PIN mới', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text(step == 0 ? 'Vui lòng nhập mã PIN 6 số hiện tại của bạn' : 'Nhập mã PIN mới và xác nhận mã PIN mới', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
            SizedBox(height: 18),
            if (step == 0)
              LayoutBuilder(builder: (context, constraints) {
                final boxes = _pinBoxes(constraints.maxWidth - 40, _pinCurrent, _focusNodeCurrent);
                return Column(children: [
                  boxes,
                  SizedBox(
                    height: 0,
                    width: 0,
                    child: TextField(
                      controller: _controllerCurrent,
                      focusNode: _focusNodeCurrent,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      maxLength: 6,
                      onChanged: (v) {
                        setState(() {
                          _pinCurrent = v.replaceAll(RegExp(r"[^0-9]"), '');
                        });
                      },
                      decoration: const InputDecoration(counterText: ''),
                    ),
                  )
                ]);
              })
            else ...[
              LayoutBuilder(builder: (context, constraints) {
                final boxesNew = _pinBoxes(constraints.maxWidth - 40, _pinNew, _focusNodeNew);
                return Column(children: [
                  Text('Mã PIN mới', style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(height: 8),
                  boxesNew,
                  SizedBox(
                    height: 0,
                    width: 0,
                    child: TextField(
                      controller: _controllerNew,
                      focusNode: _focusNodeNew,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      maxLength: 6,
                      onChanged: (v) {
                        setState(() {
                          _pinNew = v.replaceAll(RegExp(r"[^0-9]"), '');
                        });
                      },
                      decoration: const InputDecoration(counterText: ''),
                    ),
                  )
                ]);
              }),
              SizedBox(height: 18),
              LayoutBuilder(builder: (context, constraints) {
                final boxesConfirm = _pinBoxes(constraints.maxWidth - 40, _pinConfirm, _focusNodeConfirm);
                return Column(children: [
                  Text('Xác nhận mã PIN mới', style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(height: 8),
                  boxesConfirm,
                  SizedBox(
                    height: 0,
                    width: 0,
                    child: TextField(
                      controller: _controllerConfirm,
                      focusNode: _focusNodeConfirm,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      maxLength: 6,
                      onChanged: (v) {
                        setState(() {
                          _pinConfirm = v.replaceAll(RegExp(r"[^0-9]"), '');
                        });
                      },
                      decoration: const InputDecoration(counterText: ''),
                    ),
                  )
                ]);
              }),
              SizedBox(height: 18),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Text('Lưu ý: Mã PIN phải là 6 chữ số và dễ nhớ. Không nên sử dụng chuỗi đơn giản như 123456 hoặc 000000.'),
              ),
            ],
            Spacer(),
            Row(
              children: [
                Expanded(child: OutlinedButton(
                  onPressed: back,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: brand),
                  ),
                  child: Text('Hủy', style: TextStyle(color: brand)),
                )),
                SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                  ),
                  child: Text('Xác nhận', style: TextStyle(color: Colors.white)),
                )),
              ],
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
