import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_providers.dart';
import '../widgets/chat_list.dart';
import '../../domain/models/thread.dart';

class ChatListContainer extends ConsumerWidget {
  final void Function(String threadId, String threadName) onThreadTap;

  const ChatListContainer({Key? key, required this.onThreadTap}) : super(key: key);

  String? _getPeerUid(Thread thread, String? myUid) {
    if (myUid == null || thread.members.length != 2) return null;
    try {
      return thread.members.firstWhere((uid) => uid != myUid);
    } catch (e) {
      return null;
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(threadsProvider);
    final myUid = ref.watch(currentUidProvider);

    return threadsAsync.when(
      data: (threads) => ChatList(
        threads: threads,
        onTap: (thread) {
          final peerUid = _getPeerUid(thread, myUid);
          String threadName;

          if (peerUid != null && thread.memberNames.containsKey(peerUid)) {
            threadName = thread.memberNames[peerUid]!;
          } else {
            threadName = thread.name ?? 'Group Chat';
          }

          onThreadTap(thread.id, threadName);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Lỗi tải danh sách: $e')),
    );
  }
}