import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/providers.dart';
import '../../profile/domain/profile.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_details.dart';
import 'widgets/reviews_list.dart';

class OtherProfilePage extends ConsumerStatefulWidget {
  final String userId;
  const OtherProfilePage({Key? key, this.userId = 'me'}) : super(key: key);

  @override
  ConsumerState<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends ConsumerState<OtherProfilePage> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileByIdProvider(widget.userId));
    return Scaffold(
      // don't draw the body behind the AppBar here so the header's blue band
      // starts below the AppBar. This keeps the computed avatar seam position
      // (bandHeight - avatarRadius) visually centered between the blue and
      // white areas.
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // removed overflow menu per design: primary actions are centered
        // in the page content below the header.
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
        data: (profile) => SingleChildScrollView(
          // keep header full-width; padding applied to the lower content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ProfileHeader draws its own blue band and overlapping avatar
              ProfileHeader(
                name: profile.name,
                subtitle: profile.description ?? '',
                avatarUrl: profile.avatarUrl,
                isSelf: false,
                followers: profile.followers,
                following: profile.following,
                points: profile.points,
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // Center the two primary action buttons (Follow / Message)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Follow / Unfollow toggle
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _isFollowing = !_isFollowing),
                          icon: Icon(_isFollowing ? Icons.person_remove : Icons.person_add),
                          label: Text(_isFollowing ? 'Bỏ theo dõi' : 'Theo dõi'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            backgroundColor: _isFollowing ? const Color(0xFF0D4C7B) : const Color(0xFFF0F6F9),
                            foregroundColor: _isFollowing ? Colors.white : const Color(0xFF0D4C7B),
                            fixedSize: const Size(140, 40),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.message),
                          label: const Text('Nhắn tin'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            side: const BorderSide(color: Color(0xFF0D4C7B)),
                            foregroundColor: const Color(0xFF0D4C7B),
                            fixedSize: const Size(140, 40),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    ProfileDetails(profile: profile, showEditButton: false),
                    const SizedBox(height: 12),
                    const ReviewsList(),
                  ],
                ),
              )
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Lỗi khi tải hồ sơ')),
      ),
    );
  }
}
