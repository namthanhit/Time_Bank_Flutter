import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../service/domain/models/rating_model.dart';
import '../../../../service/providers/rating_provider.dart';

class RatingServicePage extends ConsumerStatefulWidget {
  final RatingModel ratingModel;

  const RatingServicePage({
    super.key,
    required this.ratingModel,
  });

  @override
  ConsumerState<RatingServicePage> createState() => _RatingServicePageState();
}

class _RatingServicePageState extends ConsumerState<RatingServicePage> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    // HH:mm:ss
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
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
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao đánh giá')),
      );
      return;
    }

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
              child: const Text('Hủy',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16))),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Gửi',
                  style: TextStyle(
                      color: Color(0xFF003E77),
                      fontWeight: FontWeight.bold,
                      fontSize: 16))),
        ],
      ),
    );

    if (should != true) return;

    setState(() => _isLoading = true);

    try {

      List<String> uploadedImageIds = [];

      await ref.read(ratingRepositoryProvider).createRating(
        bookingId: widget.ratingModel.bookingId,
        stars: _rating.toInt(),
        comment: _commentController.text.trim(),
        imageIds: uploadedImageIds,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi đánh giá thành công!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.ratingModel;

    final avatarUrl = item.partnerAvatar;
    final name = item.partnerName;
    final jobTitle = item.serviceTitle;

    final jobTime = _formatDateTime(item.startAt);
    final duration = _formatDuration(item.durationSecs);
    final location = item.place;

    const labelStyle = TextStyle(fontSize: 16, color: Color(0xFF333333));
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
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Avatar + Name
                    Row(children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: const Color(0xFF003E77),
                        backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: (avatarUrl == null || avatarUrl.isEmpty)
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

                    const SizedBox(height: 16),

                    // Job Details Box
                    if (jobTitle.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
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

                              RichText(
                                text: TextSpan(
                                  style: labelStyle,
                                  children: [
                                    const TextSpan(text: 'Thời gian: '),
                                    TextSpan(text: jobTime, style: timeStyle),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),

                              RichText(
                                text: TextSpan(
                                  style: labelStyle,
                                  children: [
                                    const TextSpan(text: 'Thời lượng: '),
                                    TextSpan(text: duration, style: durationStyle),
                                  ],
                                ),
                              ),

                              if (location.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                RichText(
                                  text: TextSpan(
                                    style: labelStyle,
                                    children: [
                                      const TextSpan(text: 'Địa điểm: '),
                                      TextSpan(text: location, style: locationStyle),
                                    ],
                                  ),
                                ),
                              ],
                            ]),
                      ),

                    const SizedBox(height: 20),
                    Row(children: [
                      const Text('Chất lượng:',
                          style: TextStyle(fontSize: 16, color: Color(0xFF003E77))),
                      const SizedBox(width: 12),
                      _buildStars(),
                      const SizedBox(width: 12),
                      Text(_rating.toString(),
                          style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF003E77),
                              fontWeight: FontWeight.bold)),
                    ]),

                    const SizedBox(height: 20),
                    const Text('Thêm ảnh',
                        style: TextStyle(fontSize: 16, color: Color(0xFF003E77))),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      ..._images.map((x) => SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(x.path), fit: BoxFit.cover)
                          ))),
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200]),
                          child: const Center(child: Icon(Icons.add_a_photo, color: Colors.grey)),
                        ),
                      )
                    ]),

                    const SizedBox(height: 20),
                    const Text('Lời nhận xét',
                        style: TextStyle(fontSize: 16, color: Color(0xFF003E77))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: 'Nhập nhận xét của bạn...',
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _confirmAndSend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Gửi đánh giá',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            )
        ],
      ),
    );
  }
}