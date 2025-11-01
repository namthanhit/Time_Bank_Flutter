import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProfileHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? avatarUrl;
  final bool isSelf;
  /// Height of the AppBar toolbar area (used to avoid avatar overlapping icons).
  final double appBarHeight;
  final int followers;
  final int points;
  final int following;

  const ProfileHeader({
    Key? key,
    required this.name,
    required this.subtitle,
    this.avatarUrl,
    this.isSelf = false,
    this.followers = 0,
    this.points = 0,
    this.following = 0,
    this.appBarHeight = 64,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  // colors tuned to match screenshots; tweak if you have a brand color in Theme
  // use the darker blue so it matches the AppBar used elsewhere in the app/mock
  const headerBlue = Color(0xFF0D4C7B);
  // layout constants so it's easier to tweak spacing
  // Reduce the blue band height to avoid the "too much blue" look when AppBar
  // also uses a similar color. This makes the band closer to the mock.
  // increase the band height so the header visually matches the provided mock
  const double bandHeight = 140.0;
  // larger avatar ring to make avatar more prominent per request
  const double outerSize = 112.0; // outer white ring diameter
  const double outerPadding = 2.0; // white ring padding

  // compute an avatar top that centers the avatar on the blue/white boundary.
  // We want the avatar to sit at the seam by default, but still avoid placing
  // it under the status bar icons. Use a small safety margin (statusBar + 8)
  // instead of including the full AppBar height so the avatar can move up.
  final statusBar = MediaQuery.of(context).padding.top;
  final safeTop = statusBar + 8; // minimal margin to keep icons readable
  final preferredTop = bandHeight - (outerSize / 2);
  // prefer the seam position unless the status bar forces it lower
  final double avatarTop = math.max(preferredTop, safeTop);

  // compute derived spacing so the content below the header always sits after
  // the avatar bottom (no overlap). avatarBottom is relative to the stack top.
  final avatarBottom = avatarTop + outerSize;
  // reduce the extra spacing so the white card area sits closer to the band
  final contentSpacing = math.max(0.0, avatarBottom - bandHeight + 6.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top blue band with avatar overlapping
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: bandHeight,
              width: double.infinity,
              color: headerBlue,
            ),

            // Avatar centered and overlapping the blue band and the white area below
            Positioned(
              top: avatarTop,
              left: 0,
              right: 0,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Outer white ring
                    Container(
                      width: outerSize,
                      height: outerSize,
                      padding: const EdgeInsets.all(outerPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: (outerSize / 2) - outerPadding,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl!)
                            : const AssetImage('assets/images/avatar.png') as ImageProvider,
                        // no placeholder icon — use provided asset
                      ),
                    ),

                    // (status dot removed) — keep avatar clean and avoid overlaying UI
                  ],
                ),
              ),
            ),
          ],
        ),

  // spacing so content (name/subtitle) sits below the avatar.
  SizedBox(height: contentSpacing),

        // content area (name, subtitle, stats)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            children: [
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
              const SizedBox(height: 6),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 12),

              // stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statColumn(following, 'Đã follow'),
                  Container(height: 44, width: 1, color: Colors.grey[300]),
                  _statColumn(points, 'Điểm văn hóa'),
                  Container(height: 44, width: 1, color: Colors.grey[300]),
                  _statColumn(followers, 'Follower'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statColumn(int value, String label) {
    final display = value >= 1000000 ? '${(value / 1000000).toStringAsFixed(0)}M' : value.toString();
    return Column(
      children: [
        Text(display, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
