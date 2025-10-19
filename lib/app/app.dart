import 'package:flutter/material.dart';
import 'package:time_bank_flutter/app/app_shell.dart';
import 'package:time_bank_flutter/features/auth/ui/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Bank',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/home' : (_) => const AppShell(),
      },
    );
  }
}
