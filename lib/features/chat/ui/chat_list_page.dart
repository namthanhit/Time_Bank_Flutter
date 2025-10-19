import 'package:flutter/material.dart';
import 'containers/chat_list_container.dart';
import 'containers/conversation_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_providers.dart';
import '../domain/models/thread.dart';

// Widget appBar hội thoại: avatar, tên, trạng thái
class _ChatConversationScaffold extends ConsumerWidget {
  final String threadId;
  const _ChatConversationScaffold({Key? key, required this.threadId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(threadsProvider).maybeWhen(data: (t) => t, orElse: () => []);
    Thread? thread;
    try {
      thread = threads.firstWhere((t) => t.id == threadId);
    } catch (_) {
      thread = null;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: thread == null
            ? const Text('Chat')
            : Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(thread.avatar),
                          ),
                        ),
                        // small status dot overlay on avatar (bottom-right)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Transform.translate(
                            offset: const Offset(2, 0),
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: thread.online ? Colors.green : Colors.grey.shade600,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 2, offset: Offset(0, 1))],
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
                      // Name (keep subtitle below). The avatar has a visible status dot.
                      Text(thread.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      // keep subtitle as secondary text if present
                      if (thread.subtitle.isNotEmpty)
                        Text(
                          thread.subtitle,
                          style: TextStyle(fontSize: 12, color: thread.online ? Colors.green : const Color(0xFF6B7B88)),
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
              child: Row(
                children: const [
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