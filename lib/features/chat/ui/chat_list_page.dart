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
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(thread.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        thread.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: thread.online ? Colors.green : const Color(0xFF6B7B88),
                        ),
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
        title: Container(
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
      body: ChatListContainer(
        onThreadTap: (threadId) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _ChatConversationScaffold(threadId: threadId),
            ),
          );
        },
      ),
    );
  }
}