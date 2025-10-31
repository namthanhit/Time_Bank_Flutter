import 'package:flutter/material.dart';
import '../../domain/models/service.dart';
import '../../data/mock_service_repository.dart';
import '../page/service_detail_page.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final bool isMyService;

  const ServiceCard({
    super.key,
    required this.service,
    this.isMyService = false,
  });

  String _formatTimeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 30) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${diff.inDays ~/ 30} tháng trước';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define chip sizing used in this card so height/width are consistent
    const double chipWidth = 60.0;
    const double chipHeight = 16.0;
    final bool hasMultipleSkills =
        (service.skillIds?.length ?? (service.skillId != null ? 1 : 0)) > 1;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF003E77).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ServiceDetailPage(
                serviceId: service.id,
                isMyService: isMyService,
              ),
            ));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + Name + Time ago (chiều cao = avatar)
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: service.providerAvatar != null
                          ? Image.network(
                              service.providerAvatar!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.person,
                                    size: 24, color: Colors.grey),
                              ),
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.person,
                                  size: 24, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 40, // Đảm bảo chiều cao = avatar
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              service.providerName ?? 'Người tổ chức',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTimeAgo(service.createdAt),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Nút ba chấm cho tab "Của tôi"
                    if (isMyService)
                      PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    const Color(0xFF003E77).withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.more_horiz,
                            size: 18,
                            color: Color(0xFF003E77),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white, // Màu nền trắng cho popup menu
                        elevation: 8,
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit,
                                    size: 18, color: Color(0xFF003E77)),
                                SizedBox(width: 10),
                                Text('Chỉnh sửa',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 10),
                                Text('Xóa',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red,
                                    )),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share,
                                    size: 18, color: Color(0xFF003E77)),
                                SizedBox(width: 10),
                                Text('Chia sẻ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            // TODO: Implement edit functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Chức năng chỉnh sửa đang phát triển'),
                                backgroundColor: Color(0xFF003E77),
                              ),
                            );
                          } else if (value == 'delete') {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Xác nhận xóa'),
                                  content: const Text(
                                      'Bạn có chắc chắn muốn xóa dịch vụ này không?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        // TODO: Implement delete functionality
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Chức năng xóa đang phát triển'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      },
                                      child: const Text('Xóa',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else if (value == 'share') {
                            // TODO: Implement share functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Chức năng chia sẻ đang phát triển'),
                                backgroundColor: Color(0xFF003E77),
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),

                // Reduce vertical gap when card shows multi-line specialization
                // so avatar/name and title/time don't look too far apart.
                SizedBox(height: hasMultipleSkills ? 6 : 14),

                // Title + Job type (bên cạnh nhau)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF003E77),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Use fixed chipWidth/chipHeight so chips look uniform.
                    SizedBox(
                      width: chipWidth,
                      child: _buildSpecializationTag(
                        context,
                        MockServiceRepository.skillNamesAsString(
                            service.skillIds ??
                                (service.skillId != null
                                    ? [service.skillId!]
                                    : null)),
                        chipWidth: chipWidth,
                        chipHeight: chipHeight,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Thời gian: giờ phút giây
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      'Thời gian: ',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      _formatDateTime(service.createdAt),
                      style: TextStyle(fontSize: 16, color: Color(0xFF419C23)),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Duration
                Row(
                  children: [
                    Icon(Icons.timer, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Thời lượng: ',
                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    ),
                    Text(
                      _formatDurationHMS(service.minSlotMinutes),
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.red[600],
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                const SizedBox(height: 8),

                // Address
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Địa chỉ: ${service.regionCode ?? 'Chưa xác định'}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime t) {
    return '${t.day}/${t.month}/${t.year} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  static String _formatDurationHMS(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:00';
  }

  Widget _buildSpecializationTag(BuildContext context, String? specialization,
      {double chipWidth = 96.0, double chipHeight = 28.0}) {
    if (specialization == null || specialization.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE0DC06),
          borderRadius: BorderRadius.circular(5),
          // border: Border.all(color: const Color(0xFF003E77).withOpacity(0.5)),
        ),
        child: const Text(
          'Khác',
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

    // Nếu không có thẻ nào sau khi lọc (ví dụ: chuỗi chỉ chứa dấu phẩy)
    if (tags.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE0DC06),
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Text(
          'Khác',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF000000),
          ),
        ),
      );
    }

    // Nếu chỉ có 1 thẻ, hiển thị bình thường
    if (tags.length == 1) {
      return SizedBox(
        width: chipWidth,
        height: chipHeight,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE0DC06),
            borderRadius: BorderRadius.circular(5),
            // border: Border.all(color: const Color(0xFF003E77)),
          ),
          child: Text(
            tags[0],
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF000000),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    // Nếu có nhiều thẻ, hiển thị thẻ đầu + thẻ "...+số" (theo cột dọc)
    // SỬ DỤNG IntrinsicWidth ĐỂ BUỘC CÁC CON CÓ CHIỀU RỘNG BẰNG NHAU
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: chipWidth,
            height: chipHeight,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0DC06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tags[0],
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
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ServiceDetailPage(
                  serviceId: service.id,
                  isMyService: isMyService,
                ),
              ));
            },
            child: SizedBox(
              width: chipWidth,
              height: chipHeight,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
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
        ],
      ),
    );
  }
}
