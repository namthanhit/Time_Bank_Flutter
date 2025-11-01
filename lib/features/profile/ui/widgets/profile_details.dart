import 'package:flutter/material.dart';
import '../../domain/profile.dart';

class ProfileDetails extends StatefulWidget {
  final Profile profile;
  final Map<String, bool>? visibility;
  final VoidCallback? onEdit;
  final bool showEditButton;

  const ProfileDetails({Key? key, required this.profile, this.visibility, this.onEdit, this.showEditButton = true}) : super(key: key);

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).primaryColor;
    bool isVisibleKey(String key) => widget.visibility == null ? true : (widget.visibility![key] ?? true);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Chi tiết', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (isVisibleKey('region') && widget.profile.regionId != null) ...[
              _row(context, Icons.location_on, 'Đến từ ${widget.profile.regionId}', iconColor),
              const SizedBox(height: 8),
            ],
            if (isVisibleKey('work') && widget.profile.workAddress != null) ...[
              _row(context, Icons.work, 'Làm việc tại ${widget.profile.workAddress}', iconColor),
              const SizedBox(height: 8),
            ],
            if (isVisibleKey('birthDate') && widget.profile.birthDate != null) ...[
              _row(context, Icons.cake, _formatDate(widget.profile.birthDate!), iconColor),
              const SizedBox(height: 8),
            ],
            if (widget.profile.description != null) ...[
              _row(context, Icons.info_outline, widget.profile.description!, iconColor),
              const SizedBox(height: 8),
            ],
            if (isVisibleKey('street') && widget.profile.street != null) ...[
              _row(context, Icons.home, widget.profile.street!, iconColor),
              const SizedBox(height: 8),
            ],
            if (isVisibleKey('study') && widget.profile.studyAddress != null) ...[
              _row(context, Icons.school, 'Học tập tại ${widget.profile.studyAddress}', iconColor),
              const SizedBox(height: 8),
            ],
            if (widget.profile.socialNetwork != null && widget.profile.socialNetwork!.isNotEmpty) ...[
              for (final e in widget.profile.socialNetwork!.entries) ...[
                if (isVisibleKey(e.key)) ...[
                  _row(context, _iconForKey(e.key), '${e.key}: ${e.value}', _colorForKey(context, e.key)),
                  const SizedBox(height: 8),
                ],
              ],
            ],
            const SizedBox(height: 12),
            // Bottom full-width edit CTA, matches mock
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6F5FB),
                  foregroundColor: const Color(0xFF0D4C7B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: const Text('Chỉnh sửa thông tin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  IconData _iconForKey(String key) {
    final k = key.toLowerCase();
    if (k.contains('facebook')) return Icons.facebook;
    if (k.contains('insta') || k.contains('instagram')) return Icons.camera_alt;
    if (k.contains('tiktok')) return Icons.music_note;
    return Icons.link;
  }

  Color _colorForKey(BuildContext context, String key) {
    final k = key.toLowerCase();
    if (k.contains('facebook')) return const Color(0xFF1877F2); // Facebook blue
    if (k.contains('insta') || k.contains('instagram')) return const Color(0xFFE1306C); // Instagram magenta
    if (k.contains('tiktok')) return const Color(0xFF010101); // TikTok dark
    return Theme.of(context).primaryColor; // fallback
  }
  Widget _row(BuildContext context, IconData icon, String text, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  
}
