import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/applicantdetailfullpage.dart';
import '../../../data/mock_service_repository.dart';

/// Reusable applicant card used by Pending lists.
/// Layout per user's request:
/// - Single card with a dividing line across the middle
/// - Top area: left = request text (receive/cancel), right = request time
/// - Below top area: avatar, name, specialization, rating
/// - Divider
/// - Bottom area (left column): job name, job time, duration, location
/// - Bottom area (right column, aligned top): job specialization tags
class PendingApplicantCard extends StatelessWidget {
  final Map<String, dynamic> applicant;

  const PendingApplicantCard({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    final requestType = (applicant['requestType'] ?? 'receive').toString();
    final requestTypeText = requestType == 'receive'
        ? 'Yêu cầu chờ xét duyệt nhận dịch vụ'
        : 'Yêu cầu chờ xét duyệt hủy dịch vụ';
    final requestTime = applicant['requestTime'] ?? '';

    final service =
        MockServiceRepository.getServiceById(applicant['serviceId']);
    final jobTitle = service?.title ?? 'Chưa có tên công việc';
    final jobTime = applicant['requestTime'] ?? '';
    final duration = service != null
        ? MockServiceRepository.formatDuration(service.minSlotMinutes)
        : '';
    // Show place if available, otherwise fallback to regionCode for location
    String location = '';
    if (service != null) {
      location = (service.place.trim().isNotEmpty)
          ? service.place
          : (service.regionCode ?? '');
    }
    // Map skill IDs to human-readable names when available (mock repo provides a lookup)
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
        // push detail page with dynamic title based on requestType
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ApplicantDetailFullPage(applicant: applicant)));
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
            // Top row: request text (left) and request time (right)
            Row(
              children: [
                Expanded(
                    child: Text(requestTypeText,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF003E77)))),
                Text(requestTime,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF003E77))),
              ],
            ),

            const SizedBox(height: 10),

            // Avatar + name + specialization + rating
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
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF003E77))),
                      const SizedBox(height: 6),
                      _SpecializationTagsInline(
                          specializations: applicant['specialization']),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            final rating = (applicant['rating'] ?? 0);
                            return Icon(
                              i < rating ? Icons.star : Icons.star_border,
                              size: 14,
                              color: const Color(0xFFE6E609),
                            );
                          }),
                          const SizedBox(width: 6),
                          Text('${applicant['rating'] ?? 0}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF003E77),
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            // Slightly more translucent divider
            const Divider(height: 1, thickness: 1, color: Colors.black12),
            const SizedBox(height: 12),

            // Bottom area containing job info and tags (reverted background to white)
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
                        // Time label (small) + value (larger)
                        _CardLabelValue(
                            label: 'Thời gian',
                            value: jobTime,
                            valueStyle: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        _CardLabelValue(
                            label: 'Thời lượng',
                            value: duration,
                            valueStyle: const TextStyle(
                                fontSize: 16,
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
                        // For vertical stacking: use available width up to maxChipWidth
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

// class ApplicantDetailFullPage extends StatelessWidget {
//   final Map<String, dynamic> applicant;
//
//   const ApplicantDetailFullPage({super.key, required this.applicant});
//
//   @override
//   Widget build(BuildContext context) {
//     final requestType = (applicant['requestType'] ?? 'receive').toString();
//     final appBarTitle = requestType == 'receive'
//         ? 'Yêu cầu nhận dịch vụ'
//         : 'Yêu cầu hủy dịch vụ';
//
//     final service =
//         MockServiceRepository.getServiceById(applicant['serviceId']);
//     final serviceName = service?.title ?? 'Chưa có thông tin';
//     final duration = service != null
//         ? MockServiceRepository.formatDuration(service.minSlotMinutes)
//         : '00:00:00';
//
//     // Detail page location fallback (place or regionCode)
//     String detailLocation = '';
//     if (service != null) {
//       detailLocation = (service.place.trim().isNotEmpty)
//           ? service.place
//           : (service.regionCode ?? '');
//     }
//
//     String jobCreatedTime = 'Chưa có thông tin';
//     if (service?.createdAt != null) {
//       final createdAt = service!.createdAt;
//       jobCreatedTime =
//           '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(appBarTitle),
//         backgroundColor: const Color(0xFF003E77),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 35,
//                   backgroundColor: const Color(0xFF003E77),
//                   backgroundImage: applicant['avatar'] != null
//                       ? NetworkImage(applicant['avatar'])
//                       : null,
//                   child: applicant['avatar'] == null
//                       ? const Icon(Icons.person, color: Colors.white, size: 35)
//                       : null,
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(applicant['name'] ?? '',
//                           style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF003E77))),
//                       const SizedBox(height: 6),
//                       Row(
//                         children: [
//                           const Text('Chuyên môn:',
//                               style: TextStyle(
//                                   fontSize: 12, color: Color(0xFF003E77))),
//                           const SizedBox(width: 6),
//                           Expanded(
//                               child: _SpecializationTagsInline(
//                                   specializations:
//                                       applicant['specialization'])),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           ...List.generate(5, (starIndex) {
//                             return Icon(
//                                 starIndex < (applicant['rating'] ?? 0).floor()
//                                     ? Icons.star
//                                     : Icons.star_border,
//                                 size: 16,
//                                 color: const Color(0xFFE6E609));
//                           }),
//                           const SizedBox(width: 8),
//                           Text('${applicant['rating'] ?? 0}',
//                               style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF003E77))),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Mở chat...')));
//                   },
//                   icon: const Icon(Icons.chat_bubble_outline,
//                       color: Color(0xFF003E77), size: 28),
//                 )
//               ],
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration:
//                   BoxDecoration(borderRadius: BorderRadius.circular(12)),
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _InfoRow(label: 'Thời gian:', value: jobCreatedTime),
//                     const SizedBox(height: 12),
//                     _InfoRow(label: 'Tên dịch vụ:', value: serviceName),
//                     const SizedBox(height: 12),
//                     _InfoRow(label: 'Thời lượng dịch vụ:', value: duration),
//                     const SizedBox(height: 12),
//                     if (detailLocation.isNotEmpty) ...[
//                       _InfoRow(label: 'Địa điểm:', value: detailLocation),
//                       const SizedBox(height: 12),
//                     ],
//                     const SizedBox(height: 12),
//                     const Text('Ghi chú:',
//                         style:
//                             TextStyle(fontSize: 16, color: Color(0xFF003E77))),
//                     const SizedBox(height: 8),
//                     TextField(
//                         maxLines: 4,
//                         decoration: InputDecoration(
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide:
//                                     BorderSide(color: Colors.grey[300]!)),
//                             focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide:
//                                     BorderSide(color: Colors.grey[300]!)),
//                             contentPadding: const EdgeInsets.all(12))),
//                   ]),
//             ),
//             const SizedBox(height: 24),
//             Row(children: [
//               Expanded(
//                   child: ElevatedButton.icon(
//                       onPressed: () {
//                         // Approve logic
//                         final requestType =
//                             applicant['requestType'] ?? 'receive';
//                         final isReceiveRequest = requestType == 'receive';
//                         Navigator.pop(context);
//                         if (isReceiveRequest) {
//                           MockServiceRepository.approveApplicant(
//                               applicant['serviceId'], applicant);
//                         } else {
//                           MockServiceRepository.approveCancelRequest(
//                               applicant['serviceId']);
//                         }
//                       },
//                       icon: const Icon(Icons.person_add_alt_outlined,
//                           size: 20, color: Colors.white),
//                       label: const Text('Duyệt yêu cầu',
//                           style: TextStyle(
//                               fontSize: 17, fontWeight: FontWeight.w600)),
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green))),
//               const SizedBox(width: 12),
//               Expanded(
//                   child: ElevatedButton(
//                       onPressed: () {
//                         final requestType =
//                             applicant['requestType'] ?? 'receive';
//                         final isReceiveRequest = requestType == 'receive';
//                         Navigator.pop(context);
//                         if (isReceiveRequest) {
//                           MockServiceRepository.resetApplication(
//                               applicant['serviceId']);
//                         } else {
//                           MockServiceRepository.rejectCancelRequest(
//                               applicant['serviceId']);
//                         }
//                       },
//                       style:
//                           ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                       child: const Text('Từ chối',
//                           style: TextStyle(
//                               fontSize: 17, fontWeight: FontWeight.w600)))),
//             ])
//           ],
//         ),
//       ),
//     );
//   }
// }

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: 145,
          child: Text(label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF003E77)))),
      Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF003E77),
                  fontWeight: FontWeight.bold),
              softWrap: false,
              overflow: TextOverflow.ellipsis)),
    ]);
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
              style: const TextStyle(fontSize: 12, color: Color(0xFF003E77)))),
      const SizedBox(width: 8),
      Expanded(
          child: Text(value,
              style: valueStyle ??
                  const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF003E77),
                      fontWeight: FontWeight.w600),
              softWrap: false,
              overflow: TextOverflow.ellipsis)),
    ]);
  }
}

class _SpecializationTagsInline extends StatelessWidget {
  final String? specializations;
  const _SpecializationTagsInline({this.specializations});

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
                        fontSize: 12, color: Color(0xFF000000)))))
            .toList());
  }
}
