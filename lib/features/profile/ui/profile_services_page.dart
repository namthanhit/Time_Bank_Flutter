import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/providers.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_action_tabs.dart';
import '../../service/ui/widgets/service_card.dart';

class ProfileServicesPage extends ConsumerWidget {
  const ProfileServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D4C7B),
        elevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: profileAsync.when(
        data: (profile) {
          final servicesAsync = ref.watch(servicesByUserProvider(profile.id));
          return RefreshIndicator(
            onRefresh: () async {
              // Invalidate the provider so it refetches from the repository.
              ref.invalidate(servicesByUserProvider(profile.id));
              // Give the UI a moment to start loading; the provider will trigger a rebuild.
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(height: 110, color: const Color(0xFF0D4C7B)),
                        ProfileHeader(
                          name: profile.name,
                          subtitle: 'Các dịch vụ của tôi',
                          avatarUrl: profile.avatarUrl,
                          isSelf: true,
                          followers: profile.followers,
                          following: profile.following,
                          points: profile.points,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfileActionTabs(
                            initialIndex: 1,
                            leftLabel: 'Chi tiết\n& Đánh giá',
                            rightLabel: 'Dịch vụ',
                            onLeftTap: () => Navigator.of(context).pop(),
                            onRightTap: () {},
                          ),
                          const SizedBox(height: 12),
                          servicesAsync.when(
                            data: (services) => services.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          const Text(
                                              'Bạn chưa có dịch vụ nào.'),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              ref.invalidate(
                                                  servicesByUserProvider(
                                                      profile.id));
                                            },
                                            child: const Text('Tải lại'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // quick debug count
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                            'Tìm thấy ${services.length} dịch vụ'),
                                      ),
                                      ...services
                                          .map((s) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 12.0),
                                                child: ServiceCard(
                                                  service: s,
                                                  isMyService: true,
                                                ),
                                              ))
                                          .toList(),
                                    ],
                                  ),
                            loading: () => const Center(
                                child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(),
                            )),
                            error: (e, st) {
                              // log the error for debugging
                              debugPrint('servicesByUserProvider error: $e');
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text(
                                          'Lỗi khi tải dịch vụ: ${e.toString()}'),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          ref.invalidate(servicesByUserProvider(
                                              profile.id));
                                        },
                                        child: const Text('Thử lại'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Lỗi khi tải hồ sơ')),
      ),
    );
  }
}
