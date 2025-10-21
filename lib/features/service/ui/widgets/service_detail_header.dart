// lib/features/service/ui/widgets/service_detail_header.dart
import 'package:flutter/material.dart';
import '../../domain/models/service.dart';

class ServiceDetailHeader extends StatelessWidget {
  final Service service;
  final bool isFavorited;
  final VoidCallback? onFavoritePressed;
  final bool isMyService;
  final bool showAllSpecializations;

  const ServiceDetailHeader({
    super.key,
    required this.service,
    this.isFavorited = false,
    this.onFavoritePressed,
    this.isMyService = false,
    this.showAllSpecializations = false, // Mặc định không hiển thị tất cả
  });

  @override
  Widget build(BuildContext context) {
    // visibility label
    final visibilityIcon = service.isPublic ? Icons.people : Icons.group;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with people icon và nút ba chấm
        Row(
          children: [
            Expanded(
              child: Text(
                service.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF003E77),
                ),
              ),
            ),
            Icon(visibilityIcon, size: 25, color: Color(0xFF003E77)),
            if (isMyService) ...[
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  // color: Colors.white,
                  child: const Icon(
                    Icons.more_horiz,
                    size: 25,
                    color: Color(0xFF003E77),
                  ),
                ),
                color: Colors.white,
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Sửa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Chức năng sửa đang phát triển')),
                    );
                  } else if (value == 'delete') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Chức năng xóa đang phát triển')),
                    );
                  }
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // Time info column with heart icon on the right
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thời gian
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Thời gian: ',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      Text(
                        _formatDateTime(service.createdAt),
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF419C23)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Thời lượng (giờ:phút:giây)
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Thời lượng: ',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      Text(
                        _formatDurationHMS(service.minSlotMinutes),
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.red[600],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Địa điểm
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Địa điểm: ${service.regionCode ?? 'Chưa xác định'}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Chuyên môn with background
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.work, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Chuyên môn: ',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      Flexible(
                        child: _buildSpecializationTags(
                            context,
                            service.providerSpecialization,
                            showAllSpecializations),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Heart icon with circular border (positioned between location and specialization)
            // Chỉ hiển thị khi onFavoritePressed được truyền vào
            if (onFavoritePressed != null)
              Container(
                margin: const EdgeInsets.only(
                    top: 40), // Position between địa điểm and chuyên môn
                // decoration: BoxDecoration(
                //   shape: BoxShape.circle,
                //   border: Border.all(color: Colors.black, width: 1),
                // ),
                child: IconButton(
                  onPressed: onFavoritePressed,
                  icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.red : Colors.black,
                      size: 25),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static String _formatDateTime(DateTime t) {
    return '${t.day}/${t.month}/${t.year} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildSpecializationTags(
      BuildContext context, String? specialization, bool showAll) {
    if (specialization == null || specialization.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE0DC06),
          borderRadius: BorderRadius.circular(5),
          //border: Border.all(color: const Color(0xFF003E77).withOpacity(0.5)),
        ),
        child: const Text(
          'Chưa xác định',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF003E77),
          ),
        ),
      );
    }

    // Tách chuỗi chuyên môn thành danh sách
    List<String> tags = specialization
        .split(RegExp(r'[,;|\n]'))
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    // Nếu chỉ có 1 tag, hiển thị inline
    if (tags.length == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE0DC06),
          borderRadius: BorderRadius.circular(5),
          //border: Border.all(color: const Color(0xFF003E77).withOpacity(0.5)),
        ),
        child: Text(
          tags[0],
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF003E77),
          ),
        ),
      );
    }

    // Nếu có nhiều tag
    if (showAll) {
      // Hiển thị TẤT CẢ chuyên môn theo HÀNG NGANG (trong trang chi tiết)
      return Wrap(
        spacing: 8.0, // Khoảng cách ngang giữa các thẻ
        runSpacing: 4.0, // Khoảng cách dọc khi xuống dòng
        children: tags
            .map((tag) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0DC06),
                    borderRadius: BorderRadius.circular(5),
                    // border: Border.all(
                    //     color: const Color(0xFF003E77)),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF000000),
                    ),
                  ),
                ))
            .toList(),
      );
    } else {
      // Chỉ hiển thị thẻ đầu tiên + thẻ "...+số" (trong danh sách)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thẻ đầu tiên
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE0DC06),
              borderRadius: BorderRadius.circular(5),
              // border:
              //     Border.all(color: const Color(0xFF003E77).withOpacity(0.5)),
            ),
            child: Text(
              tags[0],
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF000000),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Thẻ "...+số" nếu còn nhiều chuyên môn khác
          GestureDetector(
            onTap: () {
              _showAllSpecializations(context, tags);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFE0DC06),
                borderRadius: BorderRadius.circular(5),
                // border: Border.all(),
              ),
              child: Text(
                '...+${tags.length - 1}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF000000),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  void _showAllSpecializations(BuildContext context, List<String> tags) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Tất cả chuyên môn',
            style: TextStyle(
              color: Color(0xFF003E77),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tags
                .map((tag) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0DC06),
                          borderRadius: BorderRadius.circular(8),
                          // border: Border.all(
                          //     color: const Color(0xFF003E77).withOpacity(0.5)),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF003E77),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Đóng',
                style: TextStyle(color: Color(0xFF003E77)),
              ),
            ),
          ],
        );
      },
    );
  }

  static String _formatDurationHMS(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:00';
  }
}
