import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/providers.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_details.dart';
import 'widgets/reviews_list.dart';

class OtherProfilePage extends ConsumerStatefulWidget {
  final String userId;
  const OtherProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends ConsumerState<OtherProfilePage> {
  bool _isLoadingFollow = false;

  Future<void> _onFollowPressed(bool isFollowing) async {
    setState(() => _isLoadingFollow = true);
    try {
      if (isFollowing) {
        await _showUnfollowDialog();
      } else {
        await ref.read(followUserProvider(widget.userId).future);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingFollow = false);
      }
    }
  }

  Future<void> _showUnfollowDialog() async {
    final didConfirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hủy theo dõi?'),
          content: const Text('Bạn có chắc chắn muốn hủy theo dõi người này?'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Xác nhận'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (didConfirm == true) {
      await ref.read(unfollowUserProvider(widget.userId).future);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileByIdProvider(widget.userId));
    final followersAsync = ref.watch(followersCountProvider(widget.userId));
    final followingAsync = ref.watch(followingCountProvider(widget.userId));

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF003E77),
        elevation: 0,
        toolbarHeight: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300]?.withOpacity(0.5),
            height: 1.0,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileByIdProvider(widget.userId));
          ref.invalidate(followersCountProvider(widget.userId));
          ref.invalidate(followingCountProvider(widget.userId));
          await ref.read(profileByIdProvider(widget.userId).future);
        },
        child: profileAsync.when(
          data: (profile) {
            final isFollowing = profile.isFollowing;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileHeader(
                    name: profile.name,
                    subtitle: profile.description ?? '',
                    avatarUrl: profile.avatarUrl,
                    isSelf: false,
                    followers: followersAsync.value ?? 0,
                    following: followingAsync.value ?? 0,
                    points: profile.points,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isLoadingFollow
                                  ? null
                                  : () => _onFollowPressed(isFollowing),
                              icon: _isLoadingFollow
                                  ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Icon(isFollowing
                                  ? Icons.person_remove
                                  : Icons.person_add),
                              label: Text(
                                  isFollowing ? 'Đang theo dõi' : 'Theo dõi'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                backgroundColor: isFollowing
                                    ? const Color(0xFF0D4C7B)
                                    : const Color(0xFFF0F6F9),
                                foregroundColor: isFollowing
                                    ? Colors.white
                                    : const Color(0xFF0D4C7B),
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
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                side:
                                const BorderSide(color: Color(0xFF0D4C7B)),
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
            );
          },
          loading: () => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, st) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              child: Center(child: Text('Lỗi khi tải hồ sơ: $e')),
            ),
          ),
        ),
      ),
    );
  }
}