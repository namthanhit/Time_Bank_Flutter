import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/chat_providers.dart';
import '../../domain/models/thread.dart';
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
    await ref.read(
      sendTextProvider((threadId: widget.threadId, text: text)).future,
    );
    _ctrl.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Thread _selectThread(AsyncValue<List<Thread>> threadsAsync) {
    return threadsAsync.maybeWhen(
      data: (threads) =>
          threads.firstWhere((t) => t.id == widget.threadId, orElse: () => Thread(id: widget.threadId, name: 'Chat', members: const [])),
      orElse: () => Thread(id: widget.threadId, name: 'Chat', members: const []),
    );
  }

  String? _peerUid(Thread thread, String myUid) {
    if (thread.members.length != 2) return null;
    return thread.members.firstWhere((u) => u != myUid, orElse: () => myUid);
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(currentUidProvider);
    final threadsAsync = ref.watch(threadsProvider);
    final thread = _selectThread(threadsAsync);
    final peerUid = _peerUid(thread, myUid);

    final isPeerOnline = (peerUid != null)
        ? (ref.watch(presenceProvider(peerUid)).asData?.value ?? false)
        : false;

    final messagesAsync = ref.watch(messagesProvider(widget.threadId));

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              // messagesProvider trả về danh sách theo createdAt desc → dùng ListView.reverse
              data: (messages) => ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  final isMe = m.senderId == myUid;

                  return MessageBubble(
                    message: m,
                    isMe: isMe,
                    // nếu bạn có avatar peer thì truyền vào đây (URL/asset). Hiện để null.
                    avatar: null,
                    // chỉ hiển thị chấm online cho tin nhắn của đối phương
                    online: !isMe && isPeerOnline,
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Lỗi tải tin nhắn: $e')),
            ),
          ),
          MessageInput(
            controller: _ctrl,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}
