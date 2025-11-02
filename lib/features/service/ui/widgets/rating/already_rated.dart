import 'dart:io';

import 'package:flutter/material.dart';
import '../../../data/mock_service_repository.dart';
import 'rating_service_page.dart';

/// A reusable widget that renders a single review as a Card. This can be
/// embedded inline (e.g., inside the 'Đã đánh giá' list) or used inside the
/// full-page [AlreadyRatedPage] wrapper.
class AlreadyRatedWidget extends StatefulWidget {
  final Map<String, dynamic> applicant;
  final double rating;
  final String comment;
  final List<String> imagePaths;
  final DateTime reviewTime;
  final String? reviewerId;
  final void Function(Map<String, dynamic> /*updatedReview*/)? onEdit;
  final VoidCallback? onDelete;

  const AlreadyRatedWidget({
    super.key,
    required this.applicant,
    required this.rating,
    required this.comment,
    required this.imagePaths,
    required this.reviewTime,
    this.reviewerId,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<AlreadyRatedWidget> createState() => _AlreadyRatedWidgetState();
}

class _AlreadyRatedWidgetState extends State<AlreadyRatedWidget> {
  late double _rating;
  late String _comment;
  late List<String> _imagePaths;
  late DateTime _reviewTime;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
    _comment = widget.comment;
    _imagePaths = List<String>.from(widget.imagePaths);
    _reviewTime = widget.reviewTime;
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $hh:$mm';
  }

  Widget _buildStarRow(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final idx = i + 1;
        final IconData icon;
        if (rating >= idx) {
          icon = Icons.star;
        } else if (rating >= idx - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Icon(icon, color: const Color(0xFFFFC107), size: 18),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final applicant = widget.applicant;
    final avatarUrl = applicant['avatar'] as String?;
    final name = applicant['name'] ?? 'Người dùng';

    final service =
        MockServiceRepository.getServiceById(applicant['serviceId']);
    final jobTitle = service?.title ?? '';
    final jobTime = applicant['requestTime'] ?? '';
    final duration = service != null
        ? MockServiceRepository.formatDuration(service.minSlotMinutes)
        : '';
    String location = '';
    if (service != null) {
      location = (service.place.trim().isNotEmpty)
          ? service.place
          : (service.regionCode ?? '');
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF003E77),
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 26)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF003E77))),
                      const SizedBox(height: 6),
                      Row(children: [
                        _buildStarRow(_rating),
                        const SizedBox(width: 8),
                        Text(_rating.toStringAsFixed(1),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ])
                    ],
                  ),
                ),
                if (widget.reviewerId != null &&
                    widget.reviewerId == MockServiceRepository.currentUserId)
                  PopupMenuButton<String>(
                    color: Colors.white,
                    icon: const Icon(Icons.more_vert, color: Color(0xFF003E77), size: 25),
                    onSelected: (v) async {
                       if (v == 'delete') {
                        final should = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text('Xóa đánh giá'),
                            content: const Text(
                                'Bạn có chắc muốn xóa đánh giá này?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Hủy')),
                              TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Xóa',
                                      style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (should == true) widget.onDelete?.call();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'delete',
                          child:
                              Text('Xóa', style: TextStyle(color: Colors.red))),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_formatDateTime(_reviewTime),
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 12),
            if (_imagePaths.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(File(_imagePaths[i]),
                          width: 100, height: 100, fit: BoxFit.cover)),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: _imagePaths.length,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_comment.trim().isNotEmpty) ...[
              Text(_comment,
                  style:
                      const TextStyle(fontSize: 16, color: Color(0xFF333333))),
              const SizedBox(height: 12),
            ],
            if (jobTitle.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jobTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF003E77))),
                  const SizedBox(height: 6),

                  RichText(
                    text: TextSpan(
                      text: 'Thời gian: ',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF333333),
                      ),
                      children: [
                        TextSpan(
                          text: jobTime,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: 'Thời lượng: ',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF333333),
                      ),
                      children: [
                        TextSpan(
                          text: duration,
                          style: const TextStyle(
                            fontSize: 18, //
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        text: 'Địa điểm: ',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF333333),
                        ),
                        children: [
                          TextSpan(
                            text: location,
                            style: const TextStyle(
                              fontSize: 17, //
                              color: Color(0xFF003E77),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
          ],
        ),
      ),
    );
  }
}

