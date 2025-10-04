import 'package:flutter/material.dart';
import '../../domain/models/home_models.dart';
import '../home_typography.dart';
import 'tag_chip_fixed_width.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.onMoreTap,
  });

  final Activity activity;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(activity.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Card body
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 22,
                      spreadRadius: 1,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              activity.user.isNotEmpty ? activity.user[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.user,
                                  style: HomeTypography.cardUserName.copyWith(
                                    fontSize: (HomeTypography.cardUserName.fontSize ?? 14) + 2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  activity.timeAgo,
                                  style: HomeTypography.cardUserTime.copyWith(
                                    fontSize: (HomeTypography.cardUserTime.fontSize ?? 12) + 1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.more_horiz, color: Color(0xFF0B4F80)),
                            onPressed: onMoreTap,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        activity.title,
                        style: HomeTypography.cardTitle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A3D66),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info rows
                      _info(icon: Icons.calendar_month, value: activity.taskTime, valueColor: const Color(0xFF2E8B2C)),
                      const SizedBox(height: 6),
                      _info(icon: Icons.access_time, value: activity.duration, valueColor: Colors.red),
                      const SizedBox(height: 6),
                      _info(icon: Icons.location_on, value: activity.location),

                      const SizedBox(height: 8),

                      // Status pill
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.40),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            activity.status,
                            style: HomeTypography.statusLabel.copyWith(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tags overlay
              Positioned(
                top: 78,
                right: 8,
                left: null,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Giới hạn vùng tag (tuỳ bạn, 220 là ví dụ cũ)
                    const double maxWrapWidth = 220;
                    const int cols = 2;           // => 2 cột, tag = nhau
                    const double spacing = 6.0;   // khoảng cách giữa các chip

                    final width = maxWrapWidth;
                    final cellWidth = (width - spacing * (cols - 1)) / cols;

                    final tags = activity.tags;
                    // Giới hạn số tag hiển thị và thêm "+N" nếu quá
                    const maxShow = 4;
                    final show = tags.length > maxShow
                        ? [...tags.take(maxShow - 1), '+${tags.length - (maxShow - 1)}']
                        : tags;

                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxWrapWidth),
                      child: Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        alignment: WrapAlignment.end,
                        children: [
                          for (final t in show)
                            TagChipFixedWidth(text: t, width: cellWidth),
                        ],
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

  // === helpers ===
  Widget _info({required IconData icon, required String value, Color? valueColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0B4F80)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            style: HomeTypography.cardInfoValue.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF0B3252),
            ),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String s) {
    final x = s.toLowerCase();
    if (x.contains('đã nhận') || x.contains('nhận')) return Colors.green;
    if (x.contains('đang làm') || x.contains('in progress')) return const Color(0xFF0B4F80);
    if (x.contains('hoàn thành') || x.contains('done')) return const Color(0xFF2E8B2C);
    if (x.contains('hủy')) return Colors.red;
    return Colors.orange;
  }
}
