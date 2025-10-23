import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'containers/chat_list_container.dart';
import 'containers/conversation_container.dart';
import '../providers/chat_providers.dart';
import '../domain/models/thread.dart';

// Widget appBar hội thoại: avatar chữ cái đầu, tên, trạng thái Online/Offline
class _ChatConversationScaffold extends ConsumerWidget {
  final String threadId;
  const _ChatConversationScaffold({Key? key, required this.threadId}) : super(key: key);

  Thread _selectThread(AsyncValue<List<Thread>> threadsAsync, String threadId, String fallbackName) {
    return threadsAsync.maybeWhen(
      data: (threads) => threads.firstWhere(
            (t) => t.id == threadId,
        orElse: () => Thread(id: threadId, name: fallbackName, members: const []),
      ),
      orElse: () => Thread(id: threadId, name: fallbackName, members: const []),
    );
  }

  String? _peerUid(Thread thread, String myUid) {
    if (thread.members.length != 2) return null;
    return thread.members.firstWhere((u) => u != myUid, orElse: () => myUid);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = ref.watch(currentUidProvider);
    final threadsAsync = ref.watch(threadsProvider);
    final thread = _selectThread(threadsAsync, threadId, 'Chat');

    final peerUid = _peerUid(thread, myUid);
    final presenceAsync = (peerUid != null)
        ? ref.watch(presenceProvider(peerUid!))
        : const AsyncValue<bool>.data(false);
    final isPeerOnline = presenceAsync.asData?.value ?? false;

    final title = (thread.name?.isNotEmpty ?? false) ? thread.name! : 'Chat';
    final initials = title.isNotEmpty ? title.trim().characters.first.toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFE9EEF2),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Transform.translate(
                      offset: const Offset(2, 0),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isPeerOnline ? Colors.green : Colors.grey.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.14),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  isPeerOnline ? 'Online' : 'Offline',
                  style: TextStyle(fontSize: 12, color: isPeerOnline ? Colors.green : const Color(0xFF6B7B88)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ConversationContainer(threadId: threadId),
    );
  }
}

class ChatListPage extends StatelessWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Chat', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Row(
                children: [
                  Icon(Icons.search, size: 18, color: Color(0xFF9AA7B2)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Search member', style: TextStyle(color: Color(0xFF9AA7B2))),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ChatListContainer(
              onThreadTap: (threadId) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _ChatConversationScaffold(threadId: threadId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
