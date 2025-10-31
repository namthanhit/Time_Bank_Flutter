// lib/features/service/ui/widgets/service_detail_header.dart
import 'package:flutter/material.dart';
import '../../../domain/models/service.dart';
import '../../../data/mock_service_repository.dart';

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
                            MockServiceRepository.skillNamesAsString(
                                service.skillIds ??
                                    (service.skillId != null
                                        ? [service.skillId!]
                                        : null)),
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
                margin: const EdgeInsets.only(left: 8),
                child: InkWell(
                  onTap: onFavoritePressed,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      size: 35,
                      color: isFavorited ? Colors.red : const Color(0xFF003E77),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
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
      // --- Sao chép hằng số từ block 'showAll' ---
      // Đảm bảo các thẻ y hệt nhau
      const double maxChipWidth = 72;
      const double chipHeight = 20;
      // --- Hết sao chép ---

      return ConstrainedBox(
        // 1. Thêm ConstrainedBox để giới hạn chiều dài
        constraints: BoxConstraints(maxWidth: maxChipWidth),
        child: SizedBox(
          height: chipHeight, // 2. Cố định chiều cao là 20
          child: Container(
            alignment: Alignment.center, // 3. Thêm alignment
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0), // 4. Dùng padding y hệt
            decoration: BoxDecoration(
              color: const Color(0xFFE0DC06),
              borderRadius: BorderRadius.circular(6), // 5. Đồng bộ border radius là 6
            ),
            child: Text(
              tags[0], // Dùng tag đầu tiên
              textAlign: TextAlign.center, // 6. Đồng bộ Text properties
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF000000),
              ),
            ),
          ),
        ),
      );
    }

    // Nếu có nhiều tag
    if (showAll) {
      // Hiển thị TẤT CẢ chuyên môn theo HÀNG NGANG (trong trang chi tiết)
      // Đảm bảo mỗi thẻ có cùng độ rộng bằng cách dùng SizedBox với width cố định
      return LayoutBuilder(builder: (context, constraints) {
        // Tính width hợp lý cho từng thẻ — tối đa 1/3 width hoặc 72
        // Giảm min width để các thẻ co lại vừa nội dung, và giới hạn tối đa
        final double maxChipWidth = 72;
        final double chipWidth =
            (constraints.maxWidth / 3).clamp(40, maxChipWidth);
        const double chipHeight = 20; // nhỏ hơn để gọn hơn trong detail

        return Wrap(
          spacing: 8.0,
          runSpacing: 6.0,
          children: tags
              .map((tag) => ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: chipWidth),
                    child: SizedBox(
                      height: chipHeight,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0DC06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        );
      });
    } else {
      // condensed mode (first + ...+N) — define a sensible max width for chips
      final double chipWidth = 72;
      // Chỉ hiển thị thẻ đầu tiên + thẻ "...+số" (trong danh sách)
      // Dùng IntrinsicWidth để buộc cả hai thẻ có cùng độ dài (chiều rộng bằng nhau)
      return IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: chipWidth),
              child: SizedBox(
                height: 20,
                child: Container(
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0DC06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tags[0],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _showAllSpecializations(context, tags),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: chipWidth),
                child: SizedBox(
                  height: 20,
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0DC06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '...+${tags.length - 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF000000),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Chưa xác định';
    final d = dt;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
