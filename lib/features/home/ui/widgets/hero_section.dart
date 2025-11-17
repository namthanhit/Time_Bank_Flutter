import 'package:flutter/material.dart';
import '../../domain/models/home_models.dart';
import '../home_typography.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.summary,
    required this.isHidden,
    required this.onToggleHidden,
    required this.onNotificationsTap,
    this.backgroundAsset = "assets/images/background.png",
  });

  final HomeSummary summary;
  final bool isHidden;
  final VoidCallback onToggleHidden;
  final VoidCallback onNotificationsTap;

  final String backgroundAsset;

  Widget _buildAvatar(BuildContext context) {

    final url = summary.avatarUrl;

    if (url != null &&
        url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return CircleAvatar(
        radius: 35,
        backgroundImage: NetworkImage(url),
      );
    } else {
      return CircleAvatar(
        radius: 35,
        backgroundColor: Colors.grey.shade300,
        child: Icon(
          Icons.person_outline,
          size: 40,
          color: Colors.grey.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundAsset),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 40,
            right: 16,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onNotificationsTap,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.notifications, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),

          // content
          Positioned(
            left: 24,
            right: 24,
            bottom: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _buildAvatar(context),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 3),
                        Text(
                          summary.rating.toStringAsFixed(1),
                          style: HomeTypography.ratingValue,
                        ),
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
                              isHidden ? "••••••" : summary.timeBalance,
                              style: HomeTypography.heroBalanceValue.copyWith(color: Colors.white),
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