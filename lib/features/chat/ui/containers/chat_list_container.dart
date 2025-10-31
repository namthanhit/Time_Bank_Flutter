import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_providers.dart';
import '../widgets/chat_list.dart';

class ChatListContainer extends ConsumerWidget {
  final void Function(String threadId, String threadName) onThreadTap;
  const ChatListContainer({Key? key, required this.onThreadTap}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(threadsProvider);
    return threadsAsync.when(
      data: (threads) => ChatList(
        threads: threads,
        onTap: (t) => onThreadTap(t.id, t.name ?? 'Chat'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Lỗi tải danh sách: $e')),
    );
  }
}