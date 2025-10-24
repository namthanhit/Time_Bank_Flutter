import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/chat_providers.dart';
import '../../domain/models/thread.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ConversationContainer extends ConsumerStatefulWidget {
  final String threadId;
  final String fallbackName; // <-- 1. THÊM THAM SỐ NÀY

  const ConversationContainer({
    Key? key,
    required this.threadId,
    required this.fallbackName, // <-- 2. THÊM VÀO CONSTRUCTOR
  }) : super(key: key);

  @override
  ConsumerState<ConversationContainer> createState() => _ConversationContainerState();
}

class _ConversationContainerState extends ConsumerState<ConversationContainer> {
  final TextEditingController _ctrl = TextEditingController();
  bool _isPickingImage = false;

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    await ref.read(
      sendTextProvider((threadId: widget.threadId, text: text)).future,
    );
    _ctrl.clear();
  }

  Future<void> _pickAndSendImage() async {
    // 1. Nếu đang chọn ảnh rồi thì không làm gì cả
    if (_isPickingImage) return;

    try {
      // 2. Đặt cờ, báo là "đang bận"
      _isPickingImage = true;

      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

      // 3. Nếu người dùng không chọn (nhấn cancel) thì thoát
      if (picked == null) return; // 'finally' vẫn sẽ chạy

      final bytes = await picked.readAsBytes();
      final mime = picked.path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

      await ref.read(sendImageProvider(
        (threadId: widget.threadId, bytes: bytes, mime: mime),
      ).future);

    } catch (e) {
      // (Nên log lỗi ra để biết)
      print('Lỗi khi chọn/gửi ảnh: $e');
    } finally {
      // 4. LUÔN LUÔN reset cờ khi hàm kết thúc (dù thành công, lỗi, hay bị hủy)
      _isPickingImage = false;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Thread _selectThread(AsyncValue<List<Thread>> threadsAsync) {
    // 3. SỬ DỤNG widget.fallbackName THAY VÌ "Chat"
    return threadsAsync.maybeWhen(
      data: (threads) => threads.firstWhere((t) => t.id == widget.threadId,
          orElse: () => Thread(id: widget.threadId, name: widget.fallbackName, members: const [])),
      orElse: () => Thread(id: widget.threadId, name: widget.fallbackName, members: const []),
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

    final isPeerOnline =
    (peerUid != null) ? (ref.watch(presenceProvider(peerUid)).asData?.value ?? false) : false;

    final messagesAsync = ref.watch(messagesProvider(widget.threadId));

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
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
                    avatar: null,
                    online: !isMe && isPeerOnline,
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Lỗi tải tin nhắn: $e')),
            ),
          ),
          // Giao diện nhập liệu không đổi
          MessageInput(
            controller: _ctrl,
            onSend: _send,
            onAttach: _pickAndSendImage,
          ),
        ],
      ),
    );
  }
}