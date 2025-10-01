import 'package:flutter/material.dart';

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
    final accent = widget.color ?? const Color(0xFF003E77);
    final bool highlight = widget.highlight;
    final backgroundColor = Colors.white;
    final border = Border.all(
      color: accent.withOpacity(highlight ? 0.95 : 0.45),
      width: highlight ? 3 : 2,
    );

    final double scale = _pressed ? 0.94 : 1.0;
    final List<BoxShadow> shadow = highlight
        ? [
            BoxShadow(
              color: accent.withOpacity(_pressed ? 0.25 : 0.38),
              blurRadius: _pressed ? 10 : 14,
              spreadRadius: 1,
              offset: Offset(0, _pressed ? 4 : 6),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(_pressed ? 0.03 : 0.05),
              blurRadius: _pressed ? 2 : 4,
              offset: Offset(0, _pressed ? 1 : 2),
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
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: backgroundColor,
                border: border,
                borderRadius: BorderRadius.circular(14),
                boxShadow: shadow,
              ),
              alignment: Alignment.center,
              child: Icon(widget.icon, size: 28, color: accent),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 74,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: accent.withOpacity(_pressed ? 0.65 : 1.0),
                  letterSpacing: _pressed ? 0.2 : 0,
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
