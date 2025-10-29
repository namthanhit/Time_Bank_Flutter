import 'package:flutter/material.dart';
import '../../data/mock_service_repository.dart';
import '../../domain/models/service.dart';

/// A small widget that lists services with status == 'completed'.
/// It mirrors `ServiceInProgressWidget` visuals so completed items
/// look consistent with other lists.
class ServiceCompletedWidget extends StatefulWidget {
  final bool showOnlyMyServices;
  final void Function(Service)? onTap;
  final VoidCallback? onRefresh;

  const ServiceCompletedWidget({
    Key? key,
    this.showOnlyMyServices = false,
    this.onTap,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<ServiceCompletedWidget> createState() => _ServiceCompletedWidgetState();
}

class _ServiceCompletedWidgetState extends State<ServiceCompletedWidget> {
  @override
  void initState() {
    super.initState();
    MockServiceRepository.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    MockServiceRepository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ownerId =
        widget.showOnlyMyServices ? MockServiceRepository.currentUserId : null;
    final services = MockServiceRepository.getServicesByStatus('completed',
        ownerId: ownerId);

    if (services.isEmpty) {
      return Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Image.asset('assets/images/thong_bao.png',
                    width: 96, height: 96, fit: BoxFit.contain),
              ),
              const SizedBox(height: 12),
              const Text('Không có dịch vụ đã hoàn thành',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              if (widget.onRefresh != null)
                TextButton.icon(
                  onPressed: widget.onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[200],
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final s = services[index];
          final skillNames =
              MockServiceRepository.getSkillNamesFromIds(s.skillIds);
          final createdAt = s.createdAt;
          final jobTime =
              '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
          final location =
              (s.place.trim().isNotEmpty) ? s.place : (s.regionCode ?? '');
          final slots = s.slot;
          final booked = s.bookedSlots ?? 0;

          return InkWell(
            onTap: widget.onTap != null ? () => widget.onTap!(s) : null,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF003E77))),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Thời gian:',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF666666))),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(jobTime,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF2E7D32)))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Text('Thời lượng:',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF666666))),
                            const SizedBox(width: 8),
                            Text(MockServiceRepository.formatDuration(s.time),
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFCC0404),
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (location.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Địa điểm:',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black54)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(location,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF003E77)))),
                            ],
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Text('Số lượng nhân sự: ',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF666666))),
                            Text(
                                '${booked.toString().padLeft(2, '0')}/${slots.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF003E77),
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 80, maxWidth: 140),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (skillNames.isNotEmpty)
                          SizedBox(
                            width: 50,
                            height: 20,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE0DC06),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(skillNames.first,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10))),
                            ),
                          ),
                        if (skillNames.length > 1) const SizedBox(height: 8),
                        if (skillNames.length > 1)
                          SizedBox(
                            width: 50,
                            height: 20,
                            child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFE0DC06),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text('+${skillNames.length - 1}',
                                    style: const TextStyle(fontSize: 10))),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
