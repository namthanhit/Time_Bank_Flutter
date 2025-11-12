import 'package:flutter/material.dart';
import '../../../domain/models/service.dart';

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
    this.showAllSpecializations = false,
  });

  @override
  Widget build(BuildContext context) {
    final visibilityIcon = service.isPublic ? Icons.people : Icons.group;

    debugPrint('service.skillNames: ${service.skillNames}');
    debugPrint(
        'service.providerSpecialization: ${service.providerSpecialization}');

    final List<String> fromSkillNames = (service.skillNames ?? <String>[])
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final List<String> fromProviderSpecialization =
        (service.providerSpecialization ?? '')
            .split(',')
            .map((e) => e.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    final List<String> specializationsList =
        fromSkillNames.isNotEmpty ? fromSkillNames : fromProviderSpecialization;

    final specializations = specializationsList.isNotEmpty
        ? specializationsList.toSet().toList()
        : ['Chưa có'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                        'Địa điểm: ${service.place ?? 'Chưa xác định'}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

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
                          specializations,
                          showAllSpecializations,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
      BuildContext context, List<String> tags, bool showAll) {
    const double maxChipWidth = 100;
    const double chipHeight = 20;
    const Color chipColor = Color(0xFFE0DC06);
    const Color textColor = Color(0xFF000000);
    const double fontSize = 12;
    final BorderRadius borderRadius = BorderRadius.circular(6);

    if (tags.isEmpty || (tags.length == 1 && tags[0] == 'Chưa có')) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxChipWidth),
        child: SizedBox(
          height: chipHeight,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            decoration: BoxDecoration(
              color: chipColor,
              borderRadius: borderRadius,
            ),
            child: const Text(
              'Chưa có', // Tên tag
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor,
              ),
            ),
          ),
        ),
      );
    }

    if (showAll || tags.length == 1) {
      return LayoutBuilder(builder: (context, constraints) {
        final double chipWidth =
            (constraints.maxWidth / 3).clamp(50, maxChipWidth);

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
                          color: chipColor,
                          borderRadius: borderRadius,
                        ),
                        child: Text(
                          tag,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: fontSize,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        );
      });
    } else {
      return IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxChipWidth),
              child: SizedBox(
                height: chipHeight,
                child: Container(
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: borderRadius,
                  ),
                  child: Text(
                    tags[0],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: fontSize,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _showAllSpecializations(context, tags),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxChipWidth),
                child: SizedBox(
                  height: chipHeight,
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: borderRadius,
                    ),
                    child: Text(
                      '...+${tags.length - 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: fontSize,
                        color: textColor,
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
          backgroundColor: Colors.white,
          title: const Text(
            'Tất cả chuyên môn',
            style: TextStyle(
              color: Color(0xFF003E77),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tags
                  .map((tag) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0DC06), // Nền vàng
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF000000), // Chữ đen
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
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

  static String _formatDurationHMS(int seconds) {
    final hours = seconds ~/ 3600;
    final remainingSeconds = seconds % 3600;
    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Chưa xác định';
    final d = dt;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
