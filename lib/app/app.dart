import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/app/app_shell.dart';
import 'package:time_bank_flutter/features/auth/ui/login_page.dart';
import 'package:time_bank_flutter/features/auth/providers/auth_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Bank',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: authState.authenticated
          ? const AppShell()    // Nếu đã đăng nhập -> vào AppShell
          : const LoginPage(),   // Nếu chưa (hoặc đã logout) -> về LoginPage

      routes: {
      },
    );
  }
}