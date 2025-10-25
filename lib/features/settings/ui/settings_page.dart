import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'widgets/account_header.dart';
// import 'widgets/settings_item.dart'; // Chúng ta sẽ tùy chỉnh SettingsItem
import 'change_password_page.dart';
import 'change_pin_flow.dart';

// Import Auth Provider (đảm bảo đường dẫn này đúng)
import '../../auth/providers/auth_providers.dart';

// CÁC MÀU SẮC TÙY CHỈNH DỰA TRÊN ẢNH CỦA BẠN
const Color kPrimaryColor = Color(0xFF1A3870); // Xanh đậm chủ đạo
const Color kAccentColor = Color(0xFF007BFF); // Màu xanh nhấn (có thể là màu xanh sáng hơn một chút)
const Color kLightBackgroundColor = Color(0xFFF0F2F5); // Màu nền nhẹ cho các phần tử
const Color kDarkTextColor = Color(0xFF333333); // Màu chữ tối
const Color kGreyTextColor = Color(0xFF757575); // Màu chữ xám
const Color kLogoutButtonColor = Color(0xFFD81B3A); // Màu đỏ cho nút đăng xuất

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đăng xuất', style: TextStyle(color: kDarkTextColor)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?', style: TextStyle(color: kGreyTextColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ', style: TextStyle(color: kGreyTextColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Đăng xuất', style: TextStyle(color: kLogoutButtonColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: kLightBackgroundColor, // Nền chung của trang
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor, // Header màu xanh đậm
        elevation: 0, // Bỏ đổ bóng cho AppBar
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Icon back màu trắng
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: profileAsync.when(
            data: (user) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Phần AccountHeader có thể cần được chỉnh sửa để phù hợp hơn
                // với thiết kế mới, hoặc bạn có thể tạo một widget tương tự.
                // Hiện tại, tôi giữ nguyên nó nhưng khuyến nghị xem xét lại.
                AccountHeader(user: user),
                const SizedBox(height: 16),

                // Group các item cài đặt trong một card hiện đại hơn
                _buildSettingsCard(
                  context,
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline,
                      title: 'Hồ sơ cá nhân',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_none,
                      title: 'Thông báo',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.location_on_outlined,
                      title: 'Địa chỉ',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Đổi mật khẩu',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.vpn_key_outlined,
                      title: 'Đổi mã PIN',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePinFlow()));
                      },
                      isLast: true, // Đánh dấu item cuối cùng để không có divider
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Khoảng cách lớn hơn trước nút Logout

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () => _handleLogout(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kLogoutButtonColor, // Màu đỏ cho nút đăng xuất
                      minimumSize: const Size.fromHeight(52), // Nút cao hơn một chút
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Bo tròn góc
                      elevation: 4, // Đổ bóng nhẹ cho nút
                      shadowColor: kLogoutButtonColor.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700, // Chữ đậm hơn
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
            error: (e, st) => Center(child: Text('Lỗi khi tải thông tin: $e', style: const TextStyle(color: kDarkTextColor))),
          ),
        ),
      ),
    );
  }

  // Helper function để tạo card chứa các item cài đặt
  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Bo tròn góc card
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // Đổ bóng nhẹ
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// Custom Settings Item (thay thế cho SettingsItem cũ của bạn)
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLast = false,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLast; // Để kiểm soát divider

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: kPrimaryColor), // Icon màu xanh đậm
          title: Text(title, style: const TextStyle(color: kDarkTextColor, fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, color: kGreyTextColor, size: 18), // Icon mũi tên nhỏ hơn
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Padding tăng nhẹ
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: kLightBackgroundColor, // Divider mỏng, màu nền nhẹ
          ),
      ],
    );
  }
}