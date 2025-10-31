import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/data/mock_service_repository.dart';

class ApplicantDetailFullPage extends StatelessWidget {
  final Map<String, dynamic> applicant;

  const ApplicantDetailFullPage({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    final requestType = (applicant['requestType'] ?? 'receive').toString();
    final appBarTitle = requestType == 'receive'
        ? 'Yêu cầu nhận dịch vụ'
        : 'Yêu cầu hủy dịch vụ';

    final service =
        MockServiceRepository.getServiceById(applicant['serviceId']);
    final serviceName = service?.title ?? 'Chưa có thông tin';
    final duration = service != null
        ? MockServiceRepository.formatDuration(service.minSlotMinutes)
        : '00:00:00';

    // Detail page location fallback (place or regionCode)
    String detailLocation = '';
    if (service != null) {
      detailLocation = (service.place.trim().isNotEmpty)
          ? service.place
          : (service.regionCode ?? '');
    }

    String jobCreatedTime = 'Chưa có thông tin';
    if (service?.createdAt != null) {
      final createdAt = service!.createdAt;
      jobCreatedTime =
          '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: const Color(0xFF003E77),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFF003E77),
                    backgroundImage: applicant['avatar'] != null
                        ? NetworkImage(applicant['avatar'])
                        : null,
                    child: applicant['avatar'] == null
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 35)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(applicant['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003E77))),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Text('Chuyên môn:',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF003E77))),
                            const SizedBox(width: 6),
                            Expanded(
                                child: _SpecializationTagsInline(
                                    specializations:
                                        applicant['specialization'])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (starIndex) {
                              return Icon(
                                  starIndex < (applicant['rating'] ?? 0).floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 16,
                                  color: const Color(0xFFE6E609));
                            }),
                            const SizedBox(width: 8),
                            Text('${applicant['rating'] ?? 0}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF003E77))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mở chat...')));
                    },
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: Color(0xFF003E77), size: 28),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                          label: 'Thời gian:',
                          value: jobCreatedTime,
                          valueStyle: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      _InfoRow(
                          label: 'Tên dịch vụ:',
                          value: serviceName,
                          valueStyle: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF003E77),
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      _InfoRow(
                          label: 'Thời lượng dịch vụ:',
                          value: duration,
                          valueStyle: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFFCC0404),
                              fontWeight: FontWeight.bold
                          )),
                      const SizedBox(height: 14),
                      if (detailLocation.isNotEmpty) ...[
                        _InfoRow(label: 'Địa điểm:', value: detailLocation),
                        const SizedBox(height: 14),
                      ],
                      // const SizedBox(height: 14),
                      const Text('Ghi chú:',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF003E77))),
                      const SizedBox(height: 8),
                      TextField(
                          maxLines: 4,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!)),
                              contentPadding: const EdgeInsets.all(12))),
                    ]),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () {
                          // Approve logic
                          final requestType =
                              applicant['requestType'] ?? 'receive';
                          final isReceiveRequest = requestType == 'receive';
                          Navigator.pop(context);
                          if (isReceiveRequest) {
                            MockServiceRepository.approveApplicant(
                                applicant['serviceId'], applicant);
                          } else {
                            MockServiceRepository.approveCancelRequest(
                                applicant['serviceId']);
                          }
                        },
                        label: const Text('Duyệt yêu cầu',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ))),

              ]),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            final requestType =
                                applicant['requestType'] ?? 'receive';
                            final isReceiveRequest = requestType == 'receive';
                            Navigator.pop(context);
                            if (isReceiveRequest) {
                              MockServiceRepository.resetApplication(
                                  applicant['serviceId']);
                            } else {
                              MockServiceRepository.rejectCancelRequest(
                                  applicant['serviceId']);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))
                          ),
                          child: const Text('Từ chối',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold,
                                  color: Colors.white),

                          ))),

                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _InfoRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: 145,
          child: Text(label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF003E77)))),
      Expanded(
          child: Text(value,
              style: valueStyle ??
                  const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF003E77),
                      fontWeight: FontWeight.bold),
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
                        fontSize: 10, color: Color(0xFF000000)))))
            .toList());
  }
}
