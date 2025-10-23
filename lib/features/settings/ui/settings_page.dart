import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'widgets/account_header.dart';
import 'widgets/settings_item.dart';
import 'change_password_page.dart';
import 'change_pin_flow.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: profileAsync.when(
            data: (user) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountHeader(user: user),
                const SizedBox(height: 8),
                // list area on gray background
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        SettingsItem(icon: Icons.person, title: 'Hồ sơ cá nhân', onTap: () {}),
                        SettingsItem(icon: Icons.notifications, title: 'Thông báo', onTap: () {}),
                        SettingsItem(icon: Icons.place, title: 'Địa chỉ', onTap: () {}),
                        SettingsItem(icon: Icons.lock, title: 'Đổi mật khẩu', onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
                        }),
                        SettingsItem(icon: Icons.vpn_key, title: 'Đổi mã PIN', onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePinFlow()));
                        }),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD81B3A),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => const Center(child: Text('Lỗi khi tải thông tin')),
          ),
        ),
      ),
    );
  }
}
