import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/thread.dart';
import '../../domain/models/message.dart';
import '../../providers/chat_providers.dart';

class ChatListItem extends ConsumerWidget {
  final Thread thread;
  final VoidCallback? onTap;
  const ChatListItem({Key? key, required this.thread, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider(thread.id));

    // get messages if provider has data, otherwise empty
    final messages = messagesAsync.maybeWhen(data: (m) => m, orElse: () => <Message>[]);
    Message? lastMsg;
    if (messages.isNotEmpty) {
      lastMsg = messages.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
    }

    final subtitleText = lastMsg == null ? thread.subtitle : '${lastMsg.fromMe ? 'Tôi' : lastMsg.senderName}: ${lastMsg.text}';
    final lastTime = lastMsg == null ? null : '${lastMsg.createdAt.hour.toString().padLeft(2, '0')}:${lastMsg.createdAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
        children: [
          // leading avatar
          SizedBox(
            width: 56,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(thread.avatar),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: thread.online ? Colors.green : const Color(0xFF9AA7B2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // middle (title + subtitle with inline time)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(thread.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        child: Text(
                          subtitleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7B88)),
                        ),
                      ),
                    ),
                    if (lastTime != null) ...[
                      const SizedBox(width: 8),
                      Text(lastTime, style: const TextStyle(fontSize: 12, color: Color(0xFF9AA7B2))),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
