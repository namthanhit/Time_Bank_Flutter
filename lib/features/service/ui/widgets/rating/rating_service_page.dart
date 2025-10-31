import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/mock_service_repository.dart';

/// Rating page used when creating a review for an applicant/service.
class RatingServicePage extends StatefulWidget {
  final Map<String, dynamic> applicant;
  final void Function(Map<String, dynamic> review)? onSubmit;

  const RatingServicePage({super.key, required this.applicant, this.onSubmit});

  @override
  State<RatingServicePage> createState() => _RatingServicePageState();
}

class _RatingServicePageState extends State<RatingServicePage> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? picked = await _picker.pickMultiImage();
      if (picked != null && picked.isNotEmpty) {
        setState(() {
          _images.addAll(picked);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể thêm ảnh: ${e.toString()}')));
    }
  }

  /// Builds a row of 5 stars supporting half-star selection.
  Widget _buildStars() {
    const double starSize = 34.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final IconData icon;
        if (_rating >= starIndex) {
          icon = Icons.star;
        } else if (_rating >= starIndex - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return GestureDetector(
          onTapDown: (details) {
            final dx = details.localPosition.dx;
            setState(() {
              if (dx <= starSize / 2) {
                _rating = index + 0.5;
              } else {
                _rating = index + 1.0;
              }
            });
          },
          child: SizedBox(
            width: starSize,
            height: starSize,
            child: Icon(icon, color: const Color(0xFFFFC107), size: 30),
          ),
        );
      }),
    );
  }

  Future<void> _confirmAndSend() async {
    final should = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xác nhận gửi',
            style: TextStyle(
                color: Color(0xFF003E77),
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        content: const Text('Bạn có muốn gửi đánh giá không?',
            style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Từ chối',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16))),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Đồng ý',
                  style: TextStyle(
                      color: Color(0xFF003E77),
                      fontWeight: FontWeight.bold,
                      fontSize: 16))),
        ],
      ),
    );

    if (should != true) return;

    // normalize CRLF then convert newlines to literal \n for backend
    final processedComment = _commentController.text
        .replaceAll('\r\n', '\n')
        .replaceAll('\n', r'\n');

    final review = {
      'applicant': widget.applicant,
      'rating': _rating,
      'comment': processedComment,
      'imagePaths': _images.map((x) => x.path).toList(),
      // record who submitted the review so permission checks are possible
      'reviewerId': MockServiceRepository.currentUserId,
      'reviewTime': DateTime.now(),
    };

    debugPrint('Sending review: $review');

    // ScaffoldMessenger.of(context)
    //     .showSnackBar(const SnackBar(content: Text('Đang gửi...')));
    // await Future.delayed(const Duration(seconds: 1));
    // ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Đã gửi đánh giá thành công')));

    // Notify the caller (ServiceRatingPage) about new review so it can store it.
    // Do NOT pop — stay on the rating page per UX request.
    widget.onSubmit?.call(review);
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
    final description = service?.description ?? '';
    String location = '';
    if (service != null) {
      location = (service.place.trim().isNotEmpty)
          ? service.place
          : (service.regionCode ?? '');
    }

    // 🔹 ĐỊNH NGHĨA CÁC STYLE ĐỂ TÁI SỬ DỤNG
    // Style cho nhãn (giống "Mô tả")
    const labelStyle = TextStyle(fontSize: 16, color: Color(0xFF333333));
    // Style riêng cho từng nội dung
    const timeStyle = TextStyle(fontSize: 18, color: Color(0xFF2E7D32));
    const durationStyle = TextStyle(fontSize: 18, color: Color(0xFFCC0404));
    const locationStyle = TextStyle(fontSize: 16, color: Color(0xFF003E77));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003E77),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Đánh giá chất lượng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFF003E77),
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 30)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF003E77),
                  ),
                ),
              )
            ]),

            const SizedBox(height: 4),

            if (jobTitle.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobTitle,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003E77)),
                      ),
                      const SizedBox(height: 8),

                      // 🔹 THAY ĐỔI 1: DÙNG RICHTEXT CHO THỜI GIAN
                      RichText(
                        text: TextSpan(
                          style: labelStyle, // Style nhãn mặc định
                          children: [
                            const TextSpan(text: 'Thời gian: '),
                            TextSpan(
                                text: jobTime,
                                style: timeStyle), // Style nội dung
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // 🔹 THAY ĐỔI 2: DÙNG RICHTEXT CHO THỜI LƯỢNG
                      RichText(
                        text: TextSpan(
                          style: labelStyle, // Style nhãn mặc định
                          children: [
                            const TextSpan(text: 'Thời lượng: '),
                            TextSpan(
                                text: duration,
                                style: durationStyle), // Style nội dung
                          ],
                        ),
                      ),

                      // 🔹 THAY ĐỔI 3: DÙNG RICHTEXT CHO ĐỊA ĐIỂM
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: labelStyle, // Style nhãn mặc định
                            children: [
                              const TextSpan(text: 'Địa điểm: '),
                              TextSpan(
                                  text: location,
                                  style: locationStyle), // Style nội dung
                            ],
                          ),
                        ),
                      ],

                      if (description.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                            'Mô tả: '
                            '$description',
                            style: labelStyle), // Dùng style nhãn
                      ],
                    ]),
              ),

            const SizedBox(height: 20),

            // Phần còn lại giữ nguyên
            Row(children: [
              Flexible(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Chất lượng công việc:',
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF003E77))),
                ),
              ),
              Flexible(
                flex: 2,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _buildStars(),
                  const SizedBox(width: 12),
                  Text(_rating.toString(),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF003E77),
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ]),

            const SizedBox(height: 20),

            const Text('Thêm ảnh',
                style: TextStyle(fontSize: 16, color: Color(0xFF003E77))),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ..._images.map((x) => SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.file(File(x.path), fit: BoxFit.cover))),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200]),
                  child: const Center(child: Icon(Icons.add_a_photo)),
                ),
              )
            ]),

            const SizedBox(height: 20),

            const Text('Lời nhận xét',
                style: TextStyle(fontSize: 16, color: Color(0xFF003E77))),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 6,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Viết nhận xét...',
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmAndSend,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Gửi',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
