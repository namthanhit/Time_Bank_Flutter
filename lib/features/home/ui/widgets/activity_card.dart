import 'package:flutter/material.dart';
import '../../domain/models/home_models.dart';
import '../home_typography.dart';

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (activity.tag1.isNotEmpty) _yellowTag(activity.tag1),
                    const SizedBox(height: 6),
                    if (activity.tag2.isNotEmpty) _yellowTag(activity.tag2),
                  ],
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

  Widget _yellowTag(String text) {
    final icon = _pickTagIcon(text);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1DF3C),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF08415C)),
          const SizedBox(width: 6),
          Text(
            text,
            style: HomeTypography.tag.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF08415C),
            ),
          ),
        ],
      ),
    );
  }

  IconData _pickTagIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('nội')) return Icons.home_rounded;
    if (l.contains('việc')) return Icons.task_alt_rounded;
    if (l.contains('chăm')) return Icons.favorite_rounded;
    if (l.contains('học')) return Icons.school_rounded;
    if (l.contains('sửa')) return Icons.build_rounded;
    return Icons.label_rounded;
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
