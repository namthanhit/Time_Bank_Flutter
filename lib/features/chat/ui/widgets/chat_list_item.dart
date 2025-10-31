import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/thread.dart';
import '../../providers/chat_providers.dart';

class ChatListItem extends ConsumerWidget {
  final Thread thread;
  final VoidCallback? onTap;
  const ChatListItem({Key? key, required this.thread, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = ref.watch(currentUidProvider);

    // Với DM, xác định peerUid = thành viên còn lại
    String? peerUid;
    if (thread.members.length == 2) {
      for (final uid in thread.members) {
        if (uid != myUid) {
          peerUid = uid;
          break;
        }
      }
    }

    final presenceAsync = (peerUid != null)
        ? ref.watch(presenceProvider(peerUid!))
        : const AsyncValue<bool>.data(false);
    final isPeerOnline = presenceAsync.asData?.value ?? false;

    // Dùng thông tin lastMessage đã được lưu trên Thread (nhanh & rẻ hơn query messages)
    final lastType = thread.lastType; // 'text' | 'image' | null
    final lastText = thread.lastText;
    final lastSenderId = thread.lastSenderId;
    final lastAt = thread.lastAt;

    final isMe = (lastSenderId != null && lastSenderId == myUid);

    // Subtitle: ưu tiên text; nếu ảnh thì hiển thị "[Ảnh]"
    String subtitleText;
    if (lastType == 'image') {
      subtitleText = isMe ? 'Bạn đã gửi một ảnh' : 'Đã gửi một ảnh';
    } else if ((lastText ?? '').trim().isNotEmpty) {
      subtitleText = isMe ? 'Bạn: $lastText' : lastText!;
    } else {
      subtitleText = 'Bắt đầu cuộc trò chuyện';
    }

    // Giờ phút hiển thị từ lastAt (nếu có)
    final lastTime = (lastAt != null)
        ? '${lastAt.hour.toString().padLeft(2, '0')}:${lastAt.minute.toString().padLeft(2, '0')}'
        : null;

    // Avatar: vì Thread mới chưa có avatar, hiển thị chữ cái đầu
    final title = thread.name ?? 'Cuộc trò chuyện';
    final initials = (title.isNotEmpty) ? title.trim().characters.first.toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            // leading avatar + status dot
            SizedBox(
              width: 56,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFE9EEF2),
                    child: Text(
                      initials,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF334155)),
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isPeerOnline ? Colors.green : const Color(0xFF9AA7B2),
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
