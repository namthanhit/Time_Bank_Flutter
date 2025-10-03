import 'package:flutter/material.dart';

/// Card style notification item: Title + Date, message body, time footer.
class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.date,
    this.onTap,
  });

  final String title;
  final String message;
  final String time;
  final String date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const bodyColor = Color(0xCC000000); // ~80% black
    const caption = Colors.black54;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.18,
                      ),
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: caption,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.38,
                  color: bodyColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 0.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
