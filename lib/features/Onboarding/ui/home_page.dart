import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color _brandColor = Color(0xFF003E77);
  // Icon constants (reverted to original set)
  static const IconData _icHome = Icons.home_filled;
  static const IconData _icServices = Icons.widgets_rounded;
  static const IconData _icQr = Icons.qr_code_scanner_rounded;
  static const IconData _icChat = Icons.chat_rounded;
  static const IconData _icSettings = Icons.settings_rounded;
  static const IconData _icTransfer = Icons.attach_money;
  static const IconData _icHistory = Icons.history;
  static const IconData _icTime = Icons.event;
  static const IconData _icDuration = Icons.timelapse;
  static const IconData _icLocation = Icons.location_on;
  bool _isHidden = false;
  final String timeBalance = "20:45:30";
  final double rating = 4.9;
  int _currentIndex = 0;

  late final List<_NavItemData> _navItems = const [
    _NavItemData(icon: _icHome, label: "Trang chủ"),
    _NavItemData(icon: _icServices, label: "Dịch vụ"),
    _NavItemData(icon: _icQr, label: "", emphasize: true),
    _NavItemData(icon: _icChat, label: "Chat"),
    _NavItemData(icon: _icSettings, label: "Cài đặt"),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
        child: Container(
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
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              return Expanded(
                child: _bottomItem(
                  item.icon,
                  item.label,
                  isActive: _currentIndex == index,
                  emphasize: item.emphasize,
                  onTap: () => setState(() => _currentIndex = index),
                ),
              );
            }),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildQuickActions(),
            _buildActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                    Colors.black45,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: _openNotifications,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.notifications, color: Colors.white, size: 28),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage("assets/images/avatar.png"),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Số dư thời gian:",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isHidden ? "••••••" : timeBalance,
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 30),
                          icon: Icon(
                            _isHidden ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _isHidden = !_isHidden;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _menuButton(
            _icTransfer,
            "Chuyển tiền",
            color: const Color.fromARGB(255, 97, 197, 149), // green accent
            onTap: () {},
          ),
          _menuButton(
            _icQr,
            "QR",
            color: const Color(0xFFDB7A00), // amber/orange accent

            onTap: () {},
          ),
            _menuButton(
            _icHistory,
            "Lịch sử\nGiao dịch",
            color: const Color.fromARGB(255, 62, 121, 229), // purple accent
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActivities() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Text(
                "Hoạt Động",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // TODO: open activity type selector
                },
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(Icons.menu_rounded, size: 22, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _activityCard(
          user: "nam",
          time: "5 phút trước",
          title: "Rửa bát nấu cơm",
          taskTime: "11:30 06/09/2025",
          duration: "01:30:00",
          location: "Yên nghĩa - Hà Đông - Hà Nội",
          tag1: "Nội trợ",
          tag2: "Việc nhà",
          status: "Đã nhận",
        ),
        _activityCard(
          user: "nam",
          time: "15 phút trước",
          title: "Rửa bát nấu cơm",
          taskTime: "11:30 06/09/2025",
          duration: "01:30:00",
          location: "Yên nghĩa - Hà Đông - Hà Nội",
          tag1: "Nội trợ",
          tag2: "Việc nhà",
          status: "Đã nhận",
        ),
      ],
    );
  }

  static Widget _activityCard({
  required String user,
  required String time,
  required String title,
  required String taskTime,
  required String duration,
  required String location,
  required String tag1,
  required String tag2,
  required String status,
}) {
  final bool accepted = status.toLowerCase().contains('nhận');
  final Color statusColor = accepted ? Colors.green : Colors.orange;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header outside the bordered card
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                user.isNotEmpty ? user[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Card body
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Menu
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.more_vert, size: 18, color: Colors.black87),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Details
                _infoRow(icon: Icons.calendar_month, label: 'Thời gian', value: taskTime),
                const SizedBox(height: 6),
                _infoRow(
                  icon: Icons.access_time,
                  label: 'Thời lượng',
                  value: duration,
                  valueColor: Colors.red,
                ),
                const SizedBox(height: 6),
                _infoRow(
                  icon: Icons.location_on,
                  label: 'Địa điểm',
                  value: location,
                ),

                // Tags + Status
                if (status.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Tags bên trái
                      Row(
                        children: [
                          _tag(tag1),
                          const SizedBox(width: 6),
                          _tag(tag2),
                        ],
                      ),
                      const Spacer(),
                      // Status button bên phải
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _bottomItem(
    IconData icon,
    String label, {
    required bool isActive,
    required VoidCallback onTap,
    bool emphasize = false,
  }) {
    final inactiveColor = Colors.white.withValues(alpha: 0.60);

    // Specialized QR (emphasize) styling to match desired design
    final bool isQrStyle = emphasize;
    final bool showSquareInactive = isQrStyle && !isActive; // screenshot style

    final double iconSize = isQrStyle
        ? (isActive ? 30 : 30)
        : (isActive ? 26 : 22);

    final EdgeInsetsGeometry padding = isQrStyle
        ? (isActive
            ? const EdgeInsets.symmetric(vertical: 10, horizontal: 14)
            : const EdgeInsets.symmetric(vertical: 8, horizontal: 8))
        : const EdgeInsets.symmetric(vertical: 8, horizontal: 12);

    Color bgColor;
    Color iconColor;
    Color textColor;
  // Removed border usage per new design (white cards + subtle shadow)
  // BoxBorder? border;
    List<BoxShadow>? shadow;

    if (isQrStyle) {
      if (isActive) {
        // Active behaves like selected pill (white background, brand icon)
        bgColor = Colors.white;
        iconColor = _brandColor;
        textColor = _brandColor;
        shadow = const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ];
  // border removed
      } else if (showSquareInactive) {
        // Inactive emphasized: square-ish darkened glass tile + thin light border + white icon
        bgColor = Colors.white.withValues(alpha: 0.06);
        iconColor = Colors.white;
        textColor = Colors.white.withValues(alpha: 0.90);
  // border removed (design now uses shadow only)
        shadow = null; // flat per screenshot
      } else {
        // Fallback (should not occur for emphasize) – treat as regular inactive
        bgColor = Colors.transparent;
        iconColor = inactiveColor;
        textColor = inactiveColor;
      }
    } else {
      // Normal items
      if (isActive) {
        bgColor = Colors.white;
        iconColor = _brandColor;
        textColor = _brandColor;
        shadow = null;
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
        borderRadius: BorderRadius.circular(isQrStyle ? (showSquareInactive ? 18 : 24) : 22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(isQrStyle ? (showSquareInactive ? 18 : 24) : 22),
            // (border intentionally removed)
            boxShadow: shadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emphasize && icon == _icQr)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: SizedBox(
                    key: ValueKey("qr_${isActive ? 'active' : 'inactive'}"),
                    height: iconSize + 12,   // ✅ tăng size (ví dụ +12)
                    width: iconSize + 12,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Image.asset(
                          'assets/images/qr_nav.png',
                          width: iconSize + 16,   // ✅ tăng thêm width
                          height: iconSize + 16,  // ✅ tăng thêm height
                          fit: BoxFit.contain,
                          color: isActive ? _brandColor : Colors.white,
                          colorBlendMode: BlendMode.srcIn,
                          errorBuilder: (c, e, s) => Icon(
                            _icQr,
                            size: iconSize,   // tăng icon fallback
                            color: isActive ? _brandColor : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Icon(icon, size: iconSize, color: iconColor),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: emphasize ? 13 : 12,
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

  static Widget _menuButton(
    IconData icon,
    String label, {
    bool highlight = false,
    Color? color,
    VoidCallback? onTap,
  }) {
    final Color accent = color ?? _brandColor;
    const Color backgroundColor = Colors.white;
    final Border border = Border.all(
      color: accent.withValues(alpha: highlight ? 0.95 : 0.45),
      width: highlight ? 3 : 2,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: border,
              borderRadius: BorderRadius.circular(14),
              boxShadow: highlight
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.38),
                        blurRadius: 14,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 28, color: accent),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 74,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // (Removed old activityCard duplicate to avoid confusion)



  static Widget _tag(String text) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.orange,
        ),
      ),
      backgroundColor: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.orange.shade200),
      ),
    );
  }

  static Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== NOTIFICATION POPUP ====================
  void _openNotifications() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Đóng',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (c, a1, a2) => Center(
        child: _NotificationPopup(brandColor: _brandColor),
      ),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return Opacity(
          opacity: curved.value,
          child: Transform.scale(
            scale: 0.98 + curved.value * 0.02,
            child: child,
          ),
        );
      },
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final bool emphasize;

  const _NavItemData({
    required this.icon,
    required this.label,
    this.emphasize = false,
  });
}

// -------------------- Notification Models & Widgets --------------------
class _NotificationItem {
  final String title;
  final List<String> lines; // body lines (excluding time)
  final String time; // e.g. 18:20
  _NotificationItem({required this.title, required this.lines, required this.time});
}

class _NotificationPopup extends StatefulWidget {
  final Color brandColor;
  const _NotificationPopup({required this.brandColor});

  @override
  State<_NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<_NotificationPopup> {
  int _tab = 0; // 0: transaction changes, 1: general notifications

  late final List<_NotificationItem> _transactionItems = List.generate(3, (i) => _NotificationItem(
        title: 'Biến động số dư thời gian:',
        lines: [
          'TK 00787xxx667 | GD: -01H:00M | SD: 30M',
          'ND: Nam ăn cắt cỏ | 22/09/2025',
          '22/09/2025',
        ],
        time: '18:2${i}',
      ));

  late final List<_NotificationItem> _generalItems = List.generate(2, (i) => _NotificationItem(
        title: 'Thông báo hệ thống:',
        lines: [
          'Tài khoản của bạn đã được xác minh.',
          'Cảm ơn bạn đã sử dụng dịch vụ!',
          '22/09/2025',
        ],
        time: '09:3${i}',
      ));

  @override
  Widget build(BuildContext context) {
    final items = _tab == 0 ? _transactionItems : _generalItems;
    final width = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height * 0.68;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width - 32,
        constraints: BoxConstraints(maxHeight: maxHeight),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Thông báo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    splashRadius: 20,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTabs(),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA)),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _notificationCard(items[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      'Biến động giao dịch',
      'Thông báo',
    ];
    return Row(
      children: List.generate(tabs.length, (i) {
        final bool active = _tab == i;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
            height: 38,
            decoration: BoxDecoration(
              color: active ? widget.brandColor : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: widget.brandColor.withValues(alpha: 0.7), width: 1.2),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: widget.brandColor.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => setState(() => _tab = i),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      color: active ? Colors.white : widget.brandColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _notificationCard(_NotificationItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E4E4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  item.lines.isNotEmpty ? item.lines.last : '',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...item.lines.take(item.lines.length - 1).map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  l,
                  style: const TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.25),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
