import '../../domain/models/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_providers.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ConversationContainer extends ConsumerStatefulWidget {
  final String threadId;
  const ConversationContainer({Key? key, required this.threadId}) : super(key: key);

  @override
  ConsumerState<ConversationContainer> createState() => _ConversationContainerState();
}

class _ConversationContainerState extends ConsumerState<ConversationContainer> {
  final TextEditingController _ctrl = TextEditingController();

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    await ref.read(chatRepositoryProvider).sendMessage(widget.threadId, text);
    _ctrl.clear();
    ref.invalidate(messagesProvider(widget.threadId));
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.threadId));
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  // Tìm thread hiện tại để lấy avatar
                  final thread = ref.read(threadsProvider).maybeWhen(
                    data: (threads) => threads.firstWhere((t) => t.id == m.threadId, orElse: () => Thread(id: '', name: '', subtitle: '', online: false, avatar: 'assets/images/avatar.png')),
                    orElse: () => Thread(id: '', name: '', subtitle: '', online: false, avatar: 'assets/images/avatar.png'),
                  );
                  return MessageBubble(message: m, avatar: thread.avatar, online: thread.online);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Lỗi tải tin nhắn: $e')),
            ),
          ),
          MessageInput(controller: _ctrl, onSend: _send),
        ],
      ),
    );
  }
}
