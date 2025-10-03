import 'package:flutter/material.dart';
import '../home_typography.dart';

class MenuButton extends StatefulWidget {
  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.highlight = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails d) => setState(() => _pressed = true);
  void _handleTapCancel() => setState(() => _pressed = false);
  void _handleTapUp(TapUpDetails d) => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
  // Brand color giống bottom nav (#003E77) nếu không truyền màu tùy chỉnh
  final accent = widget.color ?? const Color(0xFF003E77);
    final bool highlight = widget.highlight;

    // Slightly larger
    final double scale = _pressed ? 0.94 : 1.0;

    final List<BoxShadow> shadow = [
      BoxShadow(
        color: Colors.black.withOpacity(_pressed ? 0.035 : 0.06),
        blurRadius: _pressed ? 7 : 12,
        spreadRadius: 0,
        offset: Offset(0, _pressed ? 2 : 5),
      ),
      if (highlight)
        BoxShadow(
          color: accent.withOpacity(0.20),
          blurRadius: 22,
          spreadRadius: 2,
          offset: const Offset(0, 7),
        ),
    ];

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapCancel: _handleTapCancel,
      onTapUp: _handleTapUp,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: shadow,
              ),
              alignment: Alignment.center,
              child: Icon(widget.icon, size: 30, color: accent),
            ),
            const SizedBox(height: 10), // slightly more spacing
            SizedBox(
              width: 80,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                style: HomeTypography.menuButtonLabel.copyWith(
                  color: accent.withOpacity(_pressed ? 0.55 : 0.95),
                  letterSpacing: _pressed ? 0.15 : 0,
                ),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
