import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/data/mock_service_repository.dart';
import 'package:time_bank_flutter/features/service/domain/models/service.dart';

/// Embeddable empty-state for the "received applicants" screen.
///
/// This intentionally does not include a Scaffold — the parent page should
/// provide the app bar and scaffold. When `hasData` is true the parent should
/// render the real list instead of this widget.
class ReceivedApplicants extends StatelessWidget {
  final bool hasData;
  final VoidCallback? onRefresh;
  final Service? service;
  final String? serviceId;
  final void Function(Service)? onTap;

  /// Which applicant status this widget should display when used as a
  /// applicants-list. Defaults to 'pending'. Set to 'approved' to show
  /// the "Đã nhận" list.
  final String statusFilter;

  /// When true and statusFilter == 'approved', only show approved
  /// services where the current user was the applicant (i.e. "mình được
  /// phê duyệt từ người khác").
  final bool showOnlyForCurrentUser;

  const ReceivedApplicants({
    Key? key,
    this.hasData = false,
    this.onRefresh,
    this.service,
    this.serviceId,
    this.onTap,
    this.statusFilter = 'pending',
    this.showOnlyForCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If statusFilter == 'approved', render the approved applicants list
    // as open-style service cards (no bottom sheet). Otherwise use the
    // previous behavior: render a single open-style card when a pending
    // application exists for this serviceId.
    if (statusFilter == 'approved') {
      // Start with all approved applicants
      var approvedApplicants = MockServiceRepository.mockApplicants
          .where((a) => a['status'] == 'approved')
          .toList();

      // If we should only show approvals for the current user, filter by
      // the mock repository's currentUserName. Otherwise, if a serviceId
      // was provided, filter by that service id.
      if (showOnlyForCurrentUser) {
        approvedApplicants = approvedApplicants
            .where((a) => a['name'] == MockServiceRepository.currentUserName)
            .toList();
      } else if (serviceId != null) {
        approvedApplicants = approvedApplicants
            .where((a) => a['serviceId'].toString() == serviceId)
            .toList();
      }

      // Map approved applicants to unique services
      final serviceIds = approvedApplicants
          .map((a) => a['serviceId'].toString())
          .toSet()
          .toList();

      final services = serviceIds
          .map((id) => MockServiceRepository.getServiceById(id))
          .where((s) => s != null)
          .cast<Service>()
          .toList();

      if (services.isEmpty) {
        if (hasData) return const SizedBox.shrink();
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
                const Text('Bạn chưa có dịch vụ nào cả',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                ),
              ],
            ),
          ),
        );
      }

      // Render services as open-style cards (same layout as OpenApplicants)
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
            final booked = s.bookedSlots;

            return InkWell(
              onTap: onTap != null ? () => onTap!(s) : null,
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
                                        color: Color(0xFF2E7D32))),
                              )
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
                                      style: const TextStyle(fontSize: 10)),
                                ),
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
                                    style: const TextStyle(fontSize: 10)),
                              ),
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

    // If a service is provided, or a serviceId with a pending application
    // status, render a single "open" style card (same layout as
    // OpenApplicantsWidget's item). This lets callers reuse this widget to
    // show a service-card when a request has been sent; the community page
    // should only pass the serviceId so rendering stays in this file.
    Service? s = service;
    if (s == null && serviceId != null) {
      final status = MockServiceRepository.getApplicationStatus(serviceId!);
      if (status == 'pending') {
        s = MockServiceRepository.getServiceById(serviceId!);
      }
    }

    if (s != null) {
      final skillNames = MockServiceRepository.getSkillNamesFromIds(s.skillIds);
      final createdAt = s.createdAt;
      final jobTime =
          '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
      final location =
          (s.place.trim().isNotEmpty) ? s.place : (s.regionCode ?? '');
      final slots = s.slot;
      final booked = s.bookedSlots;

      return Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: onTap != null ? () => onTap!(s!) : null,
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
                // Left column
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
                                  color: Color(0xFF2E7D32),
                                )),
                          )
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
                                      fontSize: 14, color: Color(0xFF003E77))),
                            )
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

                // Right column: chips
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
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                skillNames.first,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
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
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+${skillNames.length - 1}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default empty-state
    if (hasData) return const SizedBox.shrink();

    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Put the image on a shaped background so any white canvas in the
            // source asset is less visible. The best fix is to use a PNG with a
            // transparent background, but this provides a quick visual fix.
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
            const Text('Bạn chưa có dịch vụ nào cả',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
            ),
          ],
        ),
      ),
    );
  }
}
