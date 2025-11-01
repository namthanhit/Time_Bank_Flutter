import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/providers.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_action_tabs.dart';
import '../../home/ui/widgets/activity_card.dart';

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
          final activitiesAsync = ref.watch(activitiesProvider(profile.id));
          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(height: 110, color: const Color(0xFF0D4C7B)),
                    // overlay removed — header spacing and avatar ring handle separation
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
                      // action tabs (Chi tiết & Dịch vụ) with active indicator
                      ProfileActionTabs(
                        initialIndex: 1,
                        leftLabel: 'Chi tiết\n& Đánh giá',
                        rightLabel: 'Dịch vụ',
                        onLeftTap: () => Navigator.of(context).pop(),
                        onRightTap: () {}, // already on services page
                      ),
                      const SizedBox(height: 12),

                      // Activities provided by mock provider and rendered with ActivityCard
                      activitiesAsync.when(
                        data: (activities) => Column(
                          children: activities.map((a) => ActivityCard(activity: a, onTap: () {}, onMoreTap: () {})).toList(),
                        ),
                        loading: () => const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        )),
                        error: (e, st) => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text('Lỗi khi tải dịch vụ')),
                        ),
                      ),
                    ],
                  ),
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
