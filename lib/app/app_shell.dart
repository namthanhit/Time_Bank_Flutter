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
    final item = _navItems[i];
    if (item.emphasize) {
      // Treat QR as action button: do NOT change current index.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const _QrActionPage(),
          fullscreenDialog: true,
        ),
      );
      return;
    }
    if (_currentIndex != i) {
      setState(() => _currentIndex = i);
    }
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
  final double iconSize = isQr ? 30 : 24; // constant size for non-QR
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
      // White pill background for QR button (reduced size variant).
      bgColor = isActive ? Colors.white : Colors.white.withOpacity(0.92);
      iconColor = isActive ? brandColor : brandColor.withOpacity(0.80);
      textColor = Colors.transparent; // hidden label
      shadow = const [
        BoxShadow(
          color: Color(0x1F000000), // slightly lighter shadow
          blurRadius: 8,
          offset: Offset(0, 3),
          spreadRadius: 0,
        ),
      ];
    } else {
      bgColor = Colors.transparent;
      iconColor = isActive ? Colors.white : inactiveColor;
      textColor = isActive ? Colors.white : inactiveColor;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isQr ? (squareInactive ? 18 : 24) : 22),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        enableFeedback: false,
        splashFactory: NoSplash.splashFactory,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
      padding: isQr
        ? const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
        : padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(isQr ? (squareInactive ? 18 : 24) : 22),
            boxShadow: isQr ? shadow : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isQr)
                    SizedBox(
                      height: iconSize + 16, // reduced from +22
                      width: iconSize + 16,
                      child: Center(
                        child: Image.asset(
                          'assets/images/qr_nav.png',
                          width: iconSize + 6, // reduced from +10
                          height: iconSize + 6,
                          fit: BoxFit.contain,
                          color: iconColor,
                          colorBlendMode: BlendMode.srcIn,
                          errorBuilder: (c, e, s) => Icon(
                            data.icon,
                            size: iconSize,
                            color: iconColor,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    Icon(data.icon, size: iconSize, color: iconColor),
                    const SizedBox(height: 6),
                    Text(
                      data.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ],
              ),
              if (isActive && !isQr)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -12,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: isActive ? 1 : 0),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOut,
                    builder: (context, t, _) {
                      final double boxSide = (iconSize + 72).clamp(96, 180);
                      return Opacity(
                        opacity: t,
                        child: IgnorePointer(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: boxSide,
                              height: boxSide,
                              child: CustomPaint(
                                painter: _BottomGlowPainter(
                                  intensity: t,
                                  overlay: true,
                                  circular: false,
                                  halfCircle: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

class _BottomGlowPainter extends CustomPainter {
  final double intensity; // 0..1
  final bool overlay;
  final bool circular;
  final bool halfCircle;
  _BottomGlowPainter({
    required this.intensity,
    this.overlay = false,
    this.circular = false,
    required this.halfCircle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    // If circular mode, derive radius from box size; else fallback.
  final radius = halfCircle
    ? size.width / 2 // exactly from center bottom to one side
    : (circular ? size.width * 0.46 : size.width * 0.70);
  final center = halfCircle
    ? Offset(size.width / 2, size.height)
    : Offset(size.width / 2, circular ? size.height / 2 : size.height * 0.55);
  final circleRect = Rect.fromCircle(center: center, radius: radius);

    final gradient = RadialGradient(
      center: halfCircle ? const Alignment(0, 1) : const Alignment(0, 0),
      radius: halfCircle ? 1.05 : (circular ? 0.92 : 1.15),
      colors: halfCircle
          ? const [
              Color(0xFFFFFFFF), // core
              Color(0xDDFFFFFF), // brighter mid
              Color(0x88FFFFFF),
              Color(0x33FFFFFF),
              Color(0x05FFFFFF),
              Color(0x00000000),
            ]
          : const [
              Color(0xE6FFFFFF),
              Color(0x99FFFFFF),
              Color(0x55FFFFFF),
              Color(0x1AFFFFFF),
              Color(0x07FFFFFF),
              Color(0x00FFFFFF),
            ],
      stops: halfCircle
          ? const [0.0, 0.25, 0.48, 0.72, 0.88, 1.0]
          : const [0.0, 0.26, 0.48, 0.70, 0.85, 1.0],
    );
    final paint = Paint()
      ..shader = gradient.createShader(circleRect)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus
  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.saveLayer(circleRect.inflate(radius * 0.9), Paint());
    if (halfCircle) {
      // Clip to upper half only (above bottom edge) so it forms a dome rising up.
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawCircle(center, radius, paint..color = Colors.white.withOpacity(intensity));
    } else {
      canvas.drawCircle(center, radius, paint..color = Colors.white.withOpacity(intensity));
    }

    // Inner hotspot for punchy brightness (small additive circle).
    if (!circular && !halfCircle) {
      final hotspotPaint = Paint()
        ..color = Colors.white.withOpacity(0.35 * intensity)
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius * 0.38, hotspotPaint);
    } else if (halfCircle) {
      final domeHotspot = Paint()
        ..color = Colors.white.withOpacity(0.20 * intensity)
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(center.translate(0, -radius * 0.40), radius * 0.30, domeHotspot);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BottomGlowPainter oldDelegate) => oldDelegate.intensity != intensity;
}

class _StubPage extends StatelessWidget {
  final String label;
  const _StubPage({required this.label});

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

// Placeholder page for QR action; replace with real scanner later.
class _QrActionPage extends StatelessWidget {
  const _QrActionPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF003E77),
        elevation: 0.5,
      ),
      body: const Center(
        child: Text(
          'QR Action Placeholder',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
