import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/rating/rating_service_page.dart';

// Note: we intentionally do NOT import the private `_SpecializationTagsInline`
// from `pending_applicant_card.dart` because private identifiers are
// library-private. We provide a local `SpecializationTagsInline` below.


import '../../../data/mock_service_repository.dart';

/// Widget that shows applicants in a compact card style but hides:
/// - the top "request pending" text and time,
/// - the applicant's rating,
/// - the job time shown in the card body.
class NotRatedYetWidget extends StatefulWidget {
  final String? serviceId;
  final bool showAllJobs;
  final bool showOnlyMyJobs;
  final void Function(Map<String, dynamic> review)? onReviewSubmitted;

  const NotRatedYetWidget({
    super.key,
    this.serviceId,
    this.showAllJobs = true,
    this.showOnlyMyJobs = false,
    this.onReviewSubmitted,
  });

  @override
  State<NotRatedYetWidget> createState() => _NotRatedYetWidgetState();
}

class _NotRatedYetWidgetState extends State<NotRatedYetWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MockServiceRepository.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MockServiceRepository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> servicePendingApplicants;
    if (widget.showOnlyMyJobs) {
      servicePendingApplicants =
          MockServiceRepository.mockApplicants.where((a) {
        if (a['status'] != 'pending') return false;
        final service = MockServiceRepository.getServiceById(a['serviceId']);
        return service != null &&
            service.userId == MockServiceRepository.currentUserId;
      }).toList();
    } else {
      servicePendingApplicants = widget.showAllJobs
          ? MockServiceRepository.mockApplicants
              .where((a) => a['status'] == 'pending')
              .toList()
          : MockServiceRepository.mockApplicants
              .where((a) =>
                  a['status'] == 'pending' &&
                  a['serviceId'].toString() == (widget.serviceId ?? ''))
              .toList();
    }

    if (servicePendingApplicants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/thong_bao.png', width: 150, height: 150),
            const SizedBox(height: 16),
            const Text('Không có ứng viên nào đang chờ phê duyệt',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey[200],
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: servicePendingApplicants.length,
        itemBuilder: (context, index) {
          final applicant = servicePendingApplicants[index];
          return NotRatedYetCard(
            applicant: applicant,
            onReviewSubmitted: widget.onReviewSubmitted,
          );
        },
      ),
    );
  }
}

class NotRatedYetCard extends StatelessWidget {
  final Map<String, dynamic> applicant;
  final void Function(Map<String, dynamic> review)? onReviewSubmitted;

  const NotRatedYetCard({
    super.key,
    required this.applicant,
    this.onReviewSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final service =
        MockServiceRepository.getServiceById(applicant['serviceId']);
    final jobTitle = service?.title ?? 'Chưa có tên công việc';
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

    String jobSkills;
    if (service != null) {
      if (service.skillIds != null && service.skillIds!.isNotEmpty) {
        jobSkills = MockServiceRepository.skillNamesAsString(service.skillIds);
      } else if (service.skillId != null && service.skillId!.isNotEmpty) {
        jobSkills = MockServiceRepository.getSkillName(service.skillId) ??
            (service.providerSpecialization ?? '');
      } else {
        jobSkills = service.providerSpecialization ?? '';
      }
    } else {
      jobSkills = '';
    }

    return GestureDetector(
      onTap: () {
        // Navigate to the rating-service page for this applicant and pass
        // a callback so the parent can register the submitted review.
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RatingServicePage(
                  applicant: applicant,
                  onSubmit: onReviewSubmitted,
                )));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + name + specialization (NO rating)
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF003E77),
                  backgroundImage: applicant['avatar'] != null
                      ? NetworkImage(applicant['avatar'])
                      : null,
                  child: applicant['avatar'] == null
                      ? const Icon(Icons.person, color: Colors.white, size: 28)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(applicant['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003E77))),
                      // Person specialization removed as requested.
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Colors.black12),
            const SizedBox(height: 12),

            // Bottom area: job info and tags (NO job time shown)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left info column
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(jobTitle,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF003E77))),
                        const SizedBox(height: 8),
                        // Job time (from applicant request) + duration
                        _CardLabelValue(
                            label: 'Thời gian',
                            value: jobTime,
                            valueStyle: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2E7D32),
                            )),
                        const SizedBox(height: 6),
                        _CardLabelValue(
                            label: 'Thời lượng',
                            value: duration,
                            valueStyle: const TextStyle(
                                fontSize: 17,
                                color: Color(0xFFCC0404),
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        if (location.isNotEmpty)
                          _CardLabelValue(label: 'Địa điểm', value: location),
                      ],
                    ),
                  ),

                  // Right: job specialization tags (aligned to top)
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: LayoutBuilder(builder: (context, constraints) {
                        final double maxChipWidth = 72;
                        final double chipWidth =
                            (constraints.maxWidth).clamp(40, maxChipWidth);

                        final specializations = jobSkills
                            .split(',')
                            .map((e) => e.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: specializations
                              .map((spec) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: chipWidth),
                                      child: SizedBox(
                                        height: 20,
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 0),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0DC06),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            spec.trim(),
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
                                    ),
                                  ))
                              .toList(),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _CardLabelValue(
      {required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: 80,
          child: Text('$label:',
              style: const TextStyle(fontSize: 12, color: Colors.black87))),
      const SizedBox(width: 8),
      Expanded(
          child: Text(value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF003E77),
                  ),
              softWrap: false,
              overflow: TextOverflow.ellipsis)),
    ]);
  }
}

class SpecializationTagsInline extends StatelessWidget {
  final String? specializations;
  const SpecializationTagsInline({this.specializations});

  @override
  Widget build(BuildContext context) {
    if (specializations == null || specializations!.isEmpty) {
      return const Text('Chưa có thông tin',
          style: TextStyle(color: Colors.grey));
    }
    final tags = specializations!.split(',').map((e) => e.trim()).toList();
    return Wrap(
        spacing: 6,
        runSpacing: 4,
        children: tags
            .map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFE0DC06),
                    borderRadius: BorderRadius.circular(5)),
                child: Text(t,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF000000)))))
            .toList());
  }
}
