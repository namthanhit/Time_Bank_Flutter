import 'package:flutter/material.dart';

class PillTabButton extends StatelessWidget {
  const PillTabButton({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF003E77);
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: active ? activeColor : const Color(0xFF003E77).withOpacity(0.55),
            width: 1.1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: onTap,
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active ? Colors.white : activeColor.withOpacity(0.85),
                  letterSpacing: active ? 0.25 : 0,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
