// lib/features/service/ui/widgets/service_list_container.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/service_providers.dart';
import '../../data/mock_service_repository.dart';
import 'service_card.dart';
import '../../data/model/service_filter.dart';

class ServiceListContainer extends ConsumerWidget {
  /// If [userId] is provided, the widget will show services for that user.
  /// Otherwise it shows public services.
  final int? userId;
  final String? query;
  final ServiceFilter? filter;
  final String? socialFilter;
  final bool isMyServiceTab;

  const ServiceListContainer({
    super.key,
    this.userId,
    this.query,
    this.filter,
    this.socialFilter,
    this.isMyServiceTab = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = userId == null
        ? ref.watch(publicServicesProvider)
        : ref.watch(servicesByUserProvider(userId!));

    return servicesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Lỗi tải dữ liệu: $err')),
      data: (services) {
        // apply simple search filter if query provided (accent-insensitive)
        String normalize(String s) {
          final map = {
            'à': 'a',
            'á': 'a',
            'ạ': 'a',
            'ả': 'a',
            'ã': 'a',
            'â': 'a',
            'ầ': 'a',
            'ấ': 'a',
            'ậ': 'a',
            'ẩ': 'a',
            'ẫ': 'a',
            'ă': 'a',
            'ằ': 'a',
            'ắ': 'a',
            'ặ': 'a',
            'ẳ': 'a',
            'ẵ': 'a',
            'è': 'e',
            'é': 'e',
            'ẹ': 'e',
            'ẻ': 'e',
            'ẽ': 'e',
            'ê': 'e',
            'ề': 'e',
            'ế': 'e',
            'ệ': 'e',
            'ể': 'e',
            'ễ': 'e',
            'ì': 'i',
            'í': 'i',
            'ị': 'i',
            'ỉ': 'i',
            'ĩ': 'i',
            'ò': 'o',
            'ó': 'o',
            'ọ': 'o',
            'ỏ': 'o',
            'õ': 'o',
            'ô': 'o',
            'ồ': 'o',
            'ố': 'o',
            'ộ': 'o',
            'ổ': 'o',
            'ỗ': 'o',
            'ơ': 'o',
            'ờ': 'o',
            'ớ': 'o',
            'ợ': 'o',
            'ở': 'o',
            'ỡ': 'o',
            'ù': 'u',
            'ú': 'u',
            'ụ': 'u',
            'ủ': 'u',
            'ũ': 'u',
            'ư': 'u',
            'ừ': 'u',
            'ứ': 'u',
            'ự': 'u',
            'ử': 'u',
            'ữ': 'u',
            'ỳ': 'y',
            'ý': 'y',
            'ỵ': 'y',
            'ỷ': 'y',
            'ỹ': 'y',
            'đ': 'd',
          };
          final lower = s.toLowerCase();
          final sb = StringBuffer();
          for (var i = 0; i < lower.length; i++) {
            final ch = lower[i];
            sb.write(map[ch] ?? ch);
          }
          return sb.toString();
        }

        // start from all services
        var filteredList = services;

        // apply social filter (e.g., 'Bạn bè') if provided
        if (socialFilter != null) {
          if (socialFilter == 'Bạn bè') {
            // only include services provided by friends
            filteredList = filteredList
                .where((s) => MockServiceRepository.isFriend(s.userId))
                .toList();
          } else if (socialFilter == 'Của tôi') {
            filteredList = filteredList
                .where((s) => s.userId == MockServiceRepository.currentUserId)
                .toList();
          }
          // other socialFilter values can be implemented later
        }

        // apply query if present
        final filtered = (query == null || query!.trim().isEmpty)
            ? filteredList
            : filteredList.where((s) {
                final q = normalize(query!.trim());
                final title = normalize(s.title);
                final desc = normalize(s.description ?? '');
                final provider = normalize(s.providerName ?? '');
                final type = normalize(s.providerSpecialization ?? '');
                return title.contains(q) ||
                    desc.contains(q) ||
                    provider.contains(q) ||
                    type.contains(q);
              }).toList();

        // apply filter if provided (basic, uses fields available on Service model)
        final afterFilter = filter == null
            ? filtered
            : filtered.where((s) {
                // duration filtering based on minSlotMinutes
                switch (filter!.duration) {
                  case DurationFilterOption.upTo30:
                    if (!(s.minSlotMinutes <= 30)) return false;
                    break;
                  case DurationFilterOption.between30And60:
                    if (!(s.minSlotMinutes > 30 && s.minSlotMinutes <= 60))
                      return false;
                    break;
                  case DurationFilterOption.moreThan60:
                    if (!(s.minSlotMinutes > 60)) return false;
                    break;
                  case DurationFilterOption.any:
                  case null:
                    break;
                }

                // location match (regionCode contains filter string)
                if (filter!.location != null &&
                    filter!.location!.trim().isNotEmpty) {
                  final lc = filter!.location!.toLowerCase();
                  if ((s.regionCode ?? '').toLowerCase().contains(lc) == false)
                    return false;
                }

                // category match (providerSpecialization)
                if (filter!.category != null &&
                    filter!.category!.trim().isNotEmpty) {
                  final cat = filter!.category!.toLowerCase();
                  if ((s.providerSpecialization ?? '')
                          .toLowerCase()
                          .contains(cat) ==
                      false) return false;
                }

                // timeOfDay filter - not implemented precisely because Service model lacks scheduled times;
                // we'll skip unless we have more data.

                return true;
              }).toList();

        return Container(
          color: const Color(0xFFF8F9FA), // Màu nền nhẹ
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: afterFilter.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = afterFilter[index];
              return ServiceCard(
                service: service,
                isMyService: isMyServiceTab,
              );
            },
          ),
        );
      },
    );
  }
}
