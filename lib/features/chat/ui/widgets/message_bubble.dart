import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  /// Truyền vào từ ngoài vì Message không biết "mình" là ai
  final bool isMe;

  /// Có thể truyền đường dẫn asset hoặc URL network (tuỳ bạn dùng gì)
  final String? avatar;
  final bool online;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.avatar,
    this.online = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? const Color(0xFF003E77) : const Color(0xFFF2F4F6);
    final textColor = isMe ? Colors.white : const Color(0xFF2B3A45);

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end, // Đảm bảo căn chỉnh avatar với bubble
          children: [
            if (!isMe) ...[
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      backgroundImage: _avatarImageProvider(avatar),
                      child: avatar == null ? const Icon(Icons.person, size: 16) : null,
                    ),
                    if (online)
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade700,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              )
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // Nội dung bubble: text hoặc image
            if (message.type == MessageType.image && message.mediaUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                    maxHeight: MediaQuery.of(context).size.height * 0.4, // Giới hạn chiều cao cho ảnh
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: message.mediaUrl!,
                      fit: BoxFit.cover,
                      // Placeholder hiển thị khi ảnh đang tải
                      placeholder: (context, url) => Container(
                        alignment: Alignment.center,
                        color: Colors.grey[200],
                        child: CircularProgressIndicator(
                          color: isMe ? Colors.white : Theme.of(context).primaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                      // Widget hiển thị khi có lỗi tải ảnh
                      errorWidget: (context, url, error) => Container(
                        alignment: Alignment.center,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                  minWidth: 48,
                ),
                child: Container(
                  margin: EdgeInsets.only(
                    top: 6,
                    bottom: 2,
                    left: isMe ? 32 : 0,
                    right: isMe ? 0 : 32,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
                  ),
                  child: Text(
                    message.text ?? '',
                    style: TextStyle(color: textColor),
                  ),
                ),
              ),
          ],
        ),

        // Time
        Padding(
          padding: EdgeInsets.only(
            left: isMe ? 0 : 45,
            right: isMe ? 8 : 0,
            bottom: 2,
          ),
          child: Text(
            _formatTime(message.createdAt),
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7B88)),
          ),
        ),
      ],
    );
  }

  ImageProvider? _avatarImageProvider(String? src) {
    if (src == null || src.isEmpty) return null;
    if (src.startsWith('http')) return NetworkImage(src);
    return AssetImage(src);
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}