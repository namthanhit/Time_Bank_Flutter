import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/thread.dart';
import '../../providers/chat_providers.dart';

class ChatListItem extends ConsumerWidget {
  final Thread thread;
  final VoidCallback onTap;

  const ChatListItem({
    Key? key,
    required this.thread,
    required this.onTap,
  }) : super(key: key);

  String? _getPeerUid(Thread thread, String? myUid) {
    if (myUid == null || thread.members.length != 2) return null;
    try {
      return thread.members.firstWhere((uid) => uid != myUid);
    } catch (e) {
      return null;
    }
  }

  String _formatLastMessage(Thread thread, String? myUid) {
    final lastType = thread.lastType;
    final lastText = thread.lastText;
    final lastSenderId = thread.lastSenderId;

    if (lastType == null) return '...';
    String text = (lastType == 'image') ? '[Hình ảnh]' : (lastText ?? '...');
    return (lastSenderId == myUid) ? 'Bạn: $text' : text;
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = ref.watch(currentUidProvider);
    final peerUid = _getPeerUid(thread, myUid);

    String title;
    String initials;

    if (peerUid != null && thread.memberNames.containsKey(peerUid)) {
      title = thread.memberNames[peerUid]!;
    } else {
      title = thread.name ?? 'Group Chat';
    }
    initials = title.isNotEmpty ? title[0].toUpperCase() : '?';

    final presenceAsync = (peerUid != null)
        ? ref.watch(presenceProvider(peerUid))
        : const AsyncValue<bool>.data(false);
    final isPeerOnline = presenceAsync.asData?.value ?? false;

    final lastMessageText = _formatLastMessage(thread, myUid);
    final lastMessageTime = thread.lastAt;

    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Text(initials),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isPeerOnline ? Colors.green : Colors.grey.shade600,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
            ),
          ),
        ],
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        lastMessageText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(lastMessageTime),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}