import 'package:flutter/material.dart';
import 'dart:ui';
import '../home_typography.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.rating,
    required this.timeBalance,
    required this.isHidden,
    required this.onToggleHidden,
    required this.onNotificationsTap,
  });

  final double rating;
  final String timeBalance;
  final bool isHidden;
  final VoidCallback onToggleHidden;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
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
              onTap: onNotificationsTap,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.notifications, color: Colors.white, size: 28),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 50, // increased from 30 to accommodate overlapping rounded container
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
                        Text(rating.toStringAsFixed(1), style: HomeTypography.ratingValue),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      // Gần như trong suốt: chỉ một lớp tint trắng rất nhẹ
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Số Dư Thời Gian:",
                              style: HomeTypography.heroBalanceLabel.copyWith(
                                color: Colors.white.withOpacity(0.92),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isHidden ? "••••••" : timeBalance,
                              style: HomeTypography.heroBalanceValue.copyWith(
                                color: Colors.white,
                                shadows: const [
                                  Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 2)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 30),
                          icon: Icon(
                            isHidden ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: onToggleHidden,
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
}
