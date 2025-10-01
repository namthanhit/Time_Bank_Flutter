import 'package:flutter/material.dart';
import '../features/home/ui/home_page.dart';

/// AppShell hosts the persistent bottom navigation bar and switches pages.
/// HomePage now should only contain the scrollable home content (will be refactored).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const Color _brandColor = Color(0xFF003E77);

  int _currentIndex = 0;

  // Placeholder pages list. Replace with real feature pages when implemented.
  late final List<Widget> _pages = [
    const HomePage(),
    const _StubPage(label: 'Dịch vụ'),
    const _StubPage(label: 'QR'), // Will open scanner or action later.
    const _StubPage(label: 'Chat'),
    const _StubPage(label: 'Cài đặt'),
  ];

  // Navigation item metadata (mirrors previous implementation).
  static const IconData _icHome = Icons.home_filled;
  static const IconData _icServices = Icons.widgets_rounded;
  static const IconData _icQr = Icons.qr_code_scanner_rounded;
  static const IconData _icChat = Icons.chat_rounded;
  static const IconData _icSettings = Icons.settings_rounded;

  late final List<_NavItemData> _navItems = const [
    _NavItemData(icon: _icHome, label: 'Trang chủ'),
    _NavItemData(icon: _icServices, label: 'Dịch vụ'),
    _NavItemData(icon: _icQr, label: '', emphasize: true),
    _NavItemData(icon: _icChat, label: 'Chat'),
    _NavItemData(icon: _icSettings, label: 'Cài đặt'),
  ];

  void _onTap(int i) {
    setState(() => _currentIndex = i);
    // TODO: handle special QR index action if needed.
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
        child: _BottomNavBar(
          items: _navItems,
            currentIndex: _currentIndex,
          onTap: _onTap,
          brandColor: _brandColor,
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.brandColor,
  });

  final List<_NavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003E77), Color(0xFF0A569D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Row(
        children: [
          for (int index = 0; index < items.length; index++)
            Expanded(
              child: _BottomNavItem(
                data: items[index],
                isActive: currentIndex == index,
                brandColor: brandColor,
                onTap: () => onTap(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.data,
    required this.isActive,
    required this.brandColor,
    required this.onTap,
  });
  final _NavItemData data;
  final bool isActive;
  final Color brandColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Colors.white.withOpacity(0.60);
    final bool isQr = data.emphasize;
    final bool squareInactive = isQr && !isActive;
    final double iconSize = isQr ? 30 : (isActive ? 26 : 22);
    final EdgeInsets padding = isQr
        ? (isActive
            ? const EdgeInsets.symmetric(vertical: 10, horizontal: 14)
            : const EdgeInsets.symmetric(vertical: 8, horizontal: 8))
        : const EdgeInsets.symmetric(vertical: 8, horizontal: 12);

    Color bgColor;
    Color iconColor;
    Color textColor;
    List<BoxShadow>? shadow;

    if (isQr) {
      if (isActive) {
        bgColor = Colors.white;
        iconColor = brandColor;
        textColor = brandColor;
        shadow = const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ];
      } else if (squareInactive) {
        bgColor = Colors.white.withOpacity(0.06);
        iconColor = Colors.white;
        textColor = Colors.white.withOpacity(0.90);
      } else {
        bgColor = Colors.transparent;
        iconColor = inactiveColor;
        textColor = inactiveColor;
      }
    } else {
      if (isActive) {
        bgColor = Colors.white;
        iconColor = brandColor;
        textColor = brandColor;
      } else {
        bgColor = Colors.transparent;
        iconColor = inactiveColor;
        textColor = inactiveColor;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isQr ? (squareInactive ? 18 : 24) : 22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(isQr ? (squareInactive ? 18 : 24) : 22),
            boxShadow: shadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isQr)
                SizedBox(
                  height: iconSize + 12,
                  width: iconSize + 12,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Image.asset(
                        'assets/images/qr_nav.png',
                        width: iconSize + 16,
                        height: iconSize + 16,
                        fit: BoxFit.contain,
                        color: isActive ? brandColor : Colors.white,
                        colorBlendMode: BlendMode.srcIn,
                        errorBuilder: (c, e, s) => Icon(
                          data.icon,
                          size: iconSize,
                          color: isActive ? brandColor : Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Icon(data.icon, size: iconSize, color: iconColor),
              const SizedBox(height: 6),
              Text(
                data.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isQr ? 13 : 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final bool emphasize;
  const _NavItemData({required this.icon, required this.label, this.emphasize = false});
}

class _StubPage extends StatelessWidget {
  final String label;
  const _StubPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
    );
  }
}
