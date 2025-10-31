import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool obscureOld = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    final brand = const Color(0xFF003E77);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Đổi Mật Khẩu'), centerTitle: true, backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 12),
            CircleAvatar(radius: 28, backgroundColor: brand.withOpacity(0.12), child: Icon(Icons.lock_outline, color: brand)),
            SizedBox(height: 12),
            Text('Đổi Mật Khẩu', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text('Vui lòng nhập mật khẩu hiện tại và mật khẩu mới', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 20),
            TextField(obscureText: obscureOld, decoration: InputDecoration(labelText: 'Mật khẩu hiện tại', border: OutlineInputBorder(), hintText: 'Nhập mật khẩu hiện tại', suffixIcon: IconButton(icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => obscureOld = !obscureOld)))),
            SizedBox(height: 12),
            TextField(obscureText: obscureNew, decoration: InputDecoration(labelText: 'Mật khẩu mới', border: OutlineInputBorder(), hintText: 'Nhập mật khẩu mới', suffixIcon: IconButton(icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => obscureNew = !obscureNew)))),
            SizedBox(height: 12),
            TextField(obscureText: obscureConfirm, decoration: InputDecoration(labelText: 'Xác nhận mật khẩu mới', border: OutlineInputBorder(), hintText: 'Nhập lại mật khẩu mới', suffixIcon: IconButton(icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => obscureConfirm = !obscureConfirm)))),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Row(children: [Icon(Icons.info_outline, color: Colors.black54), SizedBox(width: 8), Expanded(child: Text('Lưu ý: Mật khẩu phải có ít nhất 6 ký tự và nên bao gồm chữ cái, số và ký tự đặc biệt.'))]),
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: brand),
                  ),
                  child: Text('Hủy', style: TextStyle(color: brand)),
                )),
                SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                  ),
                  child: Text('Xác nhận', style: TextStyle(color: Colors.white)),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
