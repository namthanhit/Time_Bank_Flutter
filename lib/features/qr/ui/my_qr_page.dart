import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/domain/user_profile.dart';

class MyQrCodePage extends ConsumerWidget {
  const MyQrCodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileState = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã QR của tôi'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D1B4C),
                Color(0xFF0F58A1)
              ],
              begin: Alignment.centerLeft, // Bắt đầu gradient
              end: Alignment.centerRight,   // Kết thúc gradient
            ),
          ),
        ),
      ),
      body: Center(
        child: userProfileState.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Đã xảy ra lỗi: $err'),
          data: (user) {
            // Đây là widget UI (presentational)
            return _buildQrCodeView(user);
          },
        ),
      ),
    );
  }

  Widget _buildQrCodeView(UserProfile user) {
    if (user.qrCode == null || user.qrCode!.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tạo mã QR...'),
          Text('Vui lòng thử lại sau giây lát.'),
        ],
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D1B4C),
            Color(0xFF0F58A1)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            user.qrCode!,
            width: 250,
            height: 250,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error_outline, size: 100, color: Colors.yellow);
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Đưa mã này cho người khác để nhận Time',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Tài khoản: ${user.phone}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}