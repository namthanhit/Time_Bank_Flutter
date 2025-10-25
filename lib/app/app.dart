import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Thêm import
import 'package:time_bank_flutter/app/app_shell.dart';
import 'package:time_bank_flutter/features/auth/ui/login_page.dart';

// 2. Import auth provider của bạn
import 'package:time_bank_flutter/features/auth/providers/auth_providers.dart';

// 3. Chuyển thành ConsumerWidget
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // 4. Thêm WidgetRef ref

    // 5. Lắng nghe (watch) trạng thái đăng nhập
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Bank',
      theme: ThemeData(primarySwatch: Colors.blue),

      // 6. Dùng "home" để tự động quyết định trang
      home: authState.authenticated
          ? const AppShell()    // Nếu đã đăng nhập -> vào AppShell
          : const LoginPage(),   // Nếu chưa (hoặc đã logout) -> về LoginPage

      // 7. Bỏ initialRoute
      // initialRoute: '/login', // <--- Bỏ dòng này

      // Bạn có thể giữ 'routes' nếu bạn dùng Navigator.pushNamed cho các trang con
      // nhưng logic /login và /home đã được 'home:' xử lý rồi.
      routes: {
        // Có thể bạn không cần 2 dòng này nữa
        // '/login': (_) => const LoginPage(),
        // '/home' : (_) => const AppShell(),

        // Nhưng nếu có các route khác thì giữ lại
        // '/profile': (_) => const ProfilePage(),
      },
    );
  }
}