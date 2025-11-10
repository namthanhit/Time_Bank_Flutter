import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/service_pagination_provider.dart';
import 'service_card.dart';
import '../../data/model/service_filter.dart';

class ServiceListContainer extends ConsumerStatefulWidget {
  /// If [userId] is provided, the widget will show services for that user.
  /// Otherwise it shows public services.
  final String? userId;
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
  ConsumerState<ServiceListContainer> createState() =>
      _ServiceListContainerState();
}

class _ServiceListContainerState extends ConsumerState<ServiceListContainer> {
  // Track ids removed locally so the card can disappear immediately on delete
  final Set<String> _removedIds = {};

  @override
  Widget build(BuildContext context) {
    final servicesAsync = widget.userId == null
        ? ref.watch(publicServicesProvider)
        : ref.watch(servicesByUserProvider(widget.userId!));

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
        if (widget.socialFilter != null) {
          if (widget.socialFilter == 'Bạn bè') {
            // only include services provided by friends
            filteredList = filteredList
                .where((s) => MockServiceRepository.isFriend(s.userId))
                .toList();
          } else if (widget.socialFilter == 'Của tôi') {
            filteredList = filteredList
                .where((s) => s.userId == MockServiceRepository.currentUserId)
                .toList();
          }
        }
        return false;
      },
      child: ListView.separated(
        // let NestedScrollView provide the inner controller (don't set one here)
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length + (isLoading ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= filtered.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          final service = filtered[index];
          return ServiceCard(
            service: service,
            isMyService: widget.isMyServiceTab,
          );
        },
      ),
    );

        // apply query if present
        final filtered = (widget.query == null || widget.query!.trim().isEmpty)
            ? filteredList
            : filteredList.where((s) {
          final q = normalize(widget.query!.trim());
          final title = normalize(s.title);
          final desc = normalize(s.description ?? '');
          final provider = normalize(s.providerName ?? '');
          final type = normalize(MockServiceRepository.skillNamesAsString(
              s.skillIds ?? (s.skillId != null ? [s.skillId!] : null)));
          return title.contains(q) ||
              desc.contains(q) ||
              provider.contains(q) ||
              type.contains(q);
        }).toList();

        // apply filter if provided (basic, uses fields available on Service model)
        final afterFilter = widget.filter == null
            ? filtered
            : filtered.where((s) {
          // duration filtering based on minSlotMinutes
          switch (widget.filter!.duration) {
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
          if (widget.filter!.location != null &&
              widget.filter!.location!.trim().isNotEmpty) {
            final lc = widget.filter!.location!.toLowerCase();
            if ((s.regionCode ?? '').toLowerCase().contains(lc) == false)
              return false;
          }

          // category match (providerSpecialization)
          if (widget.filter!.category != null &&
              widget.filter!.category!.trim().isNotEmpty) {
            final cat = widget.filter!.category!.toLowerCase();
            if ((s.providerSpecialization ?? '')
                .toLowerCase()
                .contains(cat) ==
                false) return false;
          }

          // timeOfDay filter - not implemented precisely because Service model lacks scheduled times;
          // we'll skip unless we have more data.

          return true;
        }).toList();

        // remove any services deleted locally so card disappears immediately
        final visibleList =
        afterFilter.where((s) => !_removedIds.contains(s.id)).toList();
        return Container(
          color: const Color(0xFFF8F9FA), // Màu nền nhẹ
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: visibleList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = visibleList[index];
              return ServiceCard(
                service: service,
                isMyService: widget.isMyServiceTab,
                onDelete: (id) {
                  // mark locally removed so UI hides the card immediately
                  setState(() {
                    _removedIds.add(id);
                  });
                  debugPrint('Service removed in parent (local): $id');
                  // Optionally: call repository/provider to perform permanent delete
                },
              );
            },
          ),
        );
      },
      child: listView,
    );

    return Container(
      color: const Color(0xFFF8F9FA),
      child: listView,
    );
  }
}