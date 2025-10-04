import 'package:flutter/material.dart';
import '../home_typography.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.user,
    required this.time,
    required this.title,
    required this.taskTime,
    required this.duration,
    required this.location,
    required this.tag1,
    required this.tag2,
    required this.status,
  });

  final String user;
  final String time;
  final String title;
  final String taskTime;
  final String duration;
  final String location;
  final String tag1;
  final String tag2;
  final String status;

  @override
  Widget build(BuildContext context) {
    final bool accepted = status.toLowerCase().contains('nhận');
    final Color statusColor = accepted ? Colors.green : Colors.orange;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
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
                  color: Colors.black.withOpacity(0.1),
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
                  // Header row (moved inside card)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          user.isNotEmpty ? user[0].toUpperCase() : '?',
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
                              user,
                              style: HomeTypography.cardUserName.copyWith(
                                fontSize: (HomeTypography.cardUserName.fontSize ?? 14) + 2,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              time,
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
                        onPressed: () {
                          // TODO: handle more options tap
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: HomeTypography.cardTitle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0A3D66),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _alignedInfoRow(
                    label: '',
                    value: taskTime,
                    valueColor: const Color(0xFF2E8B2C),
                    icon: Icons.calendar_month,
                  ),
                  const SizedBox(height: 6),
                  _alignedInfoRow(
                    label: '',
                    value: duration,
                    valueColor: Colors.red,
                    icon: Icons.access_time,
                  ),
                  const SizedBox(height: 6),
                  _alignedInfoRow(
                    label: '',
                    value: location,
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 8),
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
                      child: Text(status, style: HomeTypography.statusLabel.copyWith(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Overlay tags (reverted style)
          Positioned(
            top: 78,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _yellowTag(tag1),
                const SizedBox(height: 6),
                _yellowTag(tag2),
              ],
            ),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(22), // pill shape
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
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

  Widget _alignedInfoRow({
    required String label,
    required String value,
    Color? valueColor,
    IconData? icon,
  }) {
    // New compact layout: only icon (optional) + value. No label / colon.
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: const Color(0xFF0B4F80)),
          const SizedBox(width: 6),
        ],
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
}
