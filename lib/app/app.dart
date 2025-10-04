import 'package:flutter/material.dart';
import 'package:time_bank_flutter/app/app_shell.dart';
import '../features/auth/ui/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Bank',
      // TODO: sau này thay bằng AppTheme.light/dark ở core/theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AppShell(),
      // TODO: nếu dùng route:
      // routes: {
      //   '/login': (_) => const LoginPage(),
      //   '/home' : (_) => const AppShell(), // khi có AppShell
      // },
    );
  }
}
