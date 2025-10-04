import 'package:flutter/material.dart';
import '../features/home/ui/home_page.dart';
import 'navigation/bottom_nav_bar.dart';
import 'navigation/nav_item_data.dart';
import '../features/qr/ui/qr_page.dart';
import '../common/ui/stub_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _brand = Color(0xFF003E77);
  int _currentPageIndex = 0; // index theo pages (KHÔNG có QR)

  // Pages KHÔNG chứa QR
  late final List<Widget> _pages = const [
    HomePage(),
    StubPage(label: 'Dịch vụ'),
    StubPage(label: 'Chat'),
    StubPage(label: 'Cài đặt'),
  ];

  // Nav items CÓ QR ở giữa (emphasize)
  static const List<NavItemData> _navItems = [
    NavItemData(icon: Icons.home_filled, label: 'Trang chủ'),
    NavItemData(icon: Icons.widgets_rounded, label: 'Dịch vụ'),
    NavItemData(icon: Icons.qr_code_scanner_rounded, label: 'Quét QR', emphasize: true),
    NavItemData(icon: Icons.chat_rounded, label: 'Chat'),
    NavItemData(icon: Icons.settings_rounded, label: 'Cài đặt'),
  ];

  // Map: navIndex -> pageIndex (vì nav có QR)
  int _navToPage(int i) => i > 2 - 1 ? i - 1 : i; // QR ở vị trí 2
  int get _pageToNav => _currentPageIndex >= 2 ? _currentPageIndex + 1 : _currentPageIndex;

  void _onNavTap(int i) {
    final item = _navItems[i];
    if (item.emphasize) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrPage(), fullscreenDialog: true));
      return;
    }
    final to = _navToPage(i);
    if (to != _currentPageIndex) setState(() => _currentPageIndex = to);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentPageIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: BottomNavBar(
            items: _navItems,
            currentIndexNav: _pageToNav,
            onTap: _onNavTap,
            brandColor: _brand,
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
