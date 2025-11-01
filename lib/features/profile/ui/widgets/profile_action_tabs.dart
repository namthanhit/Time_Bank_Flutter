import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Two circular action buttons with labels and a half-width sliding indicator below.
class ProfileActionTabs extends StatefulWidget {
  const ProfileActionTabs({
    Key? key,
    this.initialIndex = 0,
    required this.leftLabel,
    required this.rightLabel,
    required this.onLeftTap,
    required this.onRightTap,
  }) : super(key: key);

  final int initialIndex;
  final String leftLabel;
  final String rightLabel;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  @override
  State<ProfileActionTabs> createState() => _ProfileActionTabsState();
}

class _ProfileActionTabsState extends State<ProfileActionTabs>
    with SingleTickerProviderStateMixin {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 1);
  }

  void _setIndex(int i) {
    if (_index == i) return;
    setState(() => _index = i);
  }

  Widget _buildIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: Icon(icon, color: const Color(0xFF0D4C7B), size: 28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      // available space for the background line after horizontal margins (16 left + 16 right)
      final available = math.max(0.0, width - 32.0);
      // each active segment should occupy half of the available space
      final halfAvailable = available / 2.0;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // simplified layout: two halves each with a centered icon (no circular frame or label)
          Row(
            children: [
              Expanded(
                child: Center(
                  child: _buildIcon(Icons.account_box, () {
                    _setIndex(0);
                    widget.onLeftTap();
                  }),
                ),
              ),
              Expanded(
                child: Center(
                  child: _buildIcon(Icons.handyman, () {
                    _setIndex(1);
                    widget.onRightTap();
                  }),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // indicator bar full-width with active half colored
          SizedBox(
            width: width,
            height: 6,
            child: Stack(
              children: [
                // background line (with horizontal margin 16)
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                // active half indicator: use AnimatedAlign inside the padded background
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      alignment: _index == 0 ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        width: halfAvailable,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D4C7B),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF0D4C7B).withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
