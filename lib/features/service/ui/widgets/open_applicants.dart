import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/data/mock_service_repository.dart';
import 'package:time_bank_flutter/features/service/domain/models/service.dart';

/// Shows a list of services that are in 'open' / public state.
/// Fetches using MockServiceRepository.fetchPublicServices().
class OpenApplicantsWidget extends StatelessWidget {
  final void Function(Service service)? onTap;

  const OpenApplicantsWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Service>>(
      future: MockServiceRepository().fetchPublicServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        final services = snapshot.data ?? [];
        if (services.isEmpty) {
          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/thong_bao.png',
                  width: 150, height: 150),
              const SizedBox(height: 12),
              Text('Không có công việc mở.'),
            ],
          ));
        }

        return Container(
          color: Colors.grey[200],
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final s = services[index];

              // Skill names (map IDs -> names when possible)
              final skillNames =
                  MockServiceRepository.getSkillNamesFromIds(s.skillIds);

              // Duration formatting helper (not shown directly here)

              // Job time: show creation date/time (include day/month/year)
              final createdAt = s.createdAt;
              final jobTime =
                  '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';

              // Location: prefer place then regionCode
              final location =
                  (s.place.trim().isNotEmpty) ? s.place : (s.regionCode ?? '');

              // Personnel: booked/capacity — use bookedSlots and treat `slot` as capacity
              final slots = s.slot;
              final booked = s.bookedSlots;

              return InkWell(
                onTap: () => onTap != null ? onTap!(s) : null,
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
                      // Left column: title, time, duration, location, personnel
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
                            // Labeled row: Thời gian
                            Row(
                              children: [
                                const Text('Thời gian:',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF666666))),
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
                            // Labeled row: Thời lượng (format HH:MM:SS)
                            Row(
                              children: [
                                const Text('Thời lượng:',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF666666))),
                                const SizedBox(width: 8),
                                Text(
                                    MockServiceRepository.formatDuration(
                                        s.time),
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFFCC0404),
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Labeled row: Địa điểm
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
                                            color: Color(0xFF003E77))),
                                  )
                                ],
                              ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('Số lượng nhân sự: ',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF666666))),
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

                      // Right column: specialization tags aligned to top-right
                      ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: 80, maxWidth: 140),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Top-right: first specialization (if any)
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: Text(
                                      skillNames.first,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ),

                            // Spacing between chips
                            if (skillNames.length > 1)
                              const SizedBox(height: 8),

                            // Bottom-right: show +n when there are more specializations
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
              );
            },
          ),
        );
      },
    );
  }
}
