import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io'; // <-- Import để dùng Image.file
import '../../domain/models/message.dart'; // <-- Import model đã sửa

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String? avatar;
  final bool online;
  final VoidCallback? onRetry; // <-- 1. Thêm callback retry

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.avatar,
    this.online = false,
    this.onRetry, // <-- 2. Thêm vào constructor
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              _buildAvatar(), // Tách avatar ra
            ],

            // 3. Thêm widget trạng thái (xoay/lỗi) CHO TIN CỦA MÌNH
            if (isMe) _buildStatusIndicator(context),

            // Nội dung bubble: text hoặc image
            if (message.type == MessageType.image && message.mediaUrl != null)
              _buildImageContent(context) // Tách ra hàm riêng
            else
              _buildTextContent(context, bubbleColor, textColor), // Tách ra hàm riêng
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

  // Widget hiển thị avatar (code cũ của bạn)
  Widget _buildAvatar() {
    return Padding(
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
                    BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 2, offset: const Offset(0, 1))
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 4. WIDGET MỚI: Hiển thị trạng thái (xoay/lỗi)
  Widget _buildStatusIndicator(BuildContext context) {
    // Nếu là 'sent' (mặc định), không hiển thị gì
    if (message.status == MessageStatus.sent) {
      return const SizedBox.shrink(); // Không chiếm chỗ
    }

    Widget indicator;
    if (message.status == MessageStatus.pending) {
      indicator = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
      );
    } else { // status == MessageStatus.failed
      indicator = IconButton(
        icon: Icon(Icons.error_outline, color: Colors.red[400], size: 20),
        onPressed: onRetry,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(child: indicator),
    );
  }

  // 5. WIDGET SỬA LẠI: Hiển thị nội dung ảnh
  Widget _buildImageContent(BuildContext context) {
    final bool isLocal = message.isLocalFile; // Lấy từ model

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          // Nếu là file local (đang pending) thì dùng Image.file
          // Nếu không thì dùng CachedNetworkImage
          child: isLocal
              ? Image.file(
            File(message.mediaUrl!),
            fit: BoxFit.cover,
          )
              : CachedNetworkImage(
            imageUrl: message.mediaUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 150,
              color: const Color(0xFFE9EEF2),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  // Widget nội dung text (code cũ của bạn)
  Widget _buildTextContent(BuildContext context, Color bubbleColor, Color textColor) {
    return ConstrainedBox(
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
    );
  }

  // --- Các hàm helper (code cũ của bạn) ---
  ImageProvider? _avatarImageProvider(String? src) {
    if (src == null || src.isEmpty) return null;
    if (src.startsWith('http')) return NetworkImage(src);
    return AssetImage(src);
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}