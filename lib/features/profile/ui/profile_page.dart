import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/providers.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_details.dart';
import 'widgets/reviews_list.dart';
import 'widgets/profile_action_tabs.dart';
import 'edit_profile_page.dart';
import '../../home/ui/widgets/activity_card.dart';

const Color kPrimaryColor = Color(0xFF1A3870);
const Color kAccentColor = Color(0xFF007BFF);
const Color kLightBackgroundColor = Color(0xFFF0F2F5);
const Color kDarkTextColor = Color(0xFF333333);
const Color kGreyTextColor = Color(0xFF757575);
const Color kLogoutButtonColor = Color(0xFFD81B3A);

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsKey = GlobalKey();
  int _tabIndex = 0; // 0 = details/reviews, 1 = services
  // local visibility overrides returned from EditProfilePage
  Map<String, bool> _visibility = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToDetails() {
    // just switch to details tab in-place; avoid scrolling to prevent header jumps
    setState(() => _tabIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Trang cá nhân', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor, // Header màu xanh đậm
        elevation: 0, // Bỏ đổ bóng cho AppBar
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // mirror OtherProfilePage: no overflow/settings in AppBar; primary actions live in content
        actions: [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: profileAsync.when(
        // make the header part of the scrolling content so "cuộn là cuộn hết"
        data: (profile) => SingleChildScrollView(
          controller: _scrollController,
          // no horizontal padding here so header (blue band) can span full width
          padding: EdgeInsets.only(top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // header is full-width now (no horizontal inset)
              ProfileHeader(
                name: profile.name,
                subtitle: profile.description ?? '',
                avatarUrl: profile.avatarUrl,
                isSelf: true,
                followers: profile.followers,
                following: profile.following,
                points: profile.points,
              ),

              // the rest of the content gets horizontal padding so cards align
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    ProfileActionTabs(
                      key: ValueKey(_tabIndex),
                      initialIndex: _tabIndex,
                      leftLabel: 'Chi tiết\\n& Đánh giá',
                      rightLabel: 'Dịch vụ',
                      onLeftTap: _scrollToDetails,
                      onRightTap: () {
                        setState(() => _tabIndex = 1);
                      },
                    ),
                    const SizedBox(height: 12),

                    // swap the lower area based on _tabIndex
                    if (_tabIndex == 0) ...[
                      ProfileDetails(
                        key: _detailsKey,
                        profile: profile,
                        visibility: _visibility.isEmpty ? null : _visibility,
                        onEdit: () async {
                          final result = await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => EditProfilePage(profile: profile),
                          ));
                          if (result != null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu thay đổi')));
                            // if the edit page returned visibility settings, keep them locally so
                            // the details view immediately reflects the user's choices.
                            if (result is Map && result.containsKey('visibility')) {
                              final vis = result['visibility'];
                              if (vis is Map) {
                                setState(() {
                                  _visibility = Map<String, bool>.fromEntries(
                                    vis.entries.map((e) => MapEntry(e.key.toString(), e.value == true)),
                                  );
                                });
                              }
                            }
                            // Optionally trigger a refresh or call a provider to persist changes.
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      const ReviewsList(),
                    ] else ...[
                      Consumer(
                        builder: (context, ref2, _) {
                          final activitiesAsync = ref2.watch(activitiesProvider(profile.id));
                          return activitiesAsync.when(
                            data: (activities) => Column(
                              // add spacing between service cards so the list breathes
                              children: activities
                                  .map((a) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: ActivityCard(
                                          activity: a,
                                          onTap: () {},
                                          onMoreTap: () {},
                                          compact: true,
                                          horizontalPadding: 0,
                                          verticalPadding: 6,
                                        ),
                                      ))
                                  .toList(),
                            ),
                            loading: () => const Center(child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(),
                            )),
                            error: (e, st) => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: Text('Lỗi khi tải dịch vụ')),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Lỗi khi tải hồ sơ')),
      ),
    );
  }
}
