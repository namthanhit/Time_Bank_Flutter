import 'package:flutter/material.dart';
import 'package:time_bank_flutter/app/app_shell.dart'; // kept for potential revert
import 'package:time_bank_flutter/features/auth/ui/login_page.dart'; // kept for potential revert

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi động bằng AppShell để các nút chuyển trang (ví dụ Lịch sử giao dịch) có stack Navigator đúng.
    // Nếu cần debug nhanh vào TransactionHistoryPage: đổi home thành const TransactionHistoryPage().
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Bank',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AppShell(),
      // Previous config:
      // initialRoute: '/login',
      // routes: {
      //   '/login': (_) => const LoginPage(),
      //   '/home' : (_) => const AppShell(),
      // },
    );
  }
}
