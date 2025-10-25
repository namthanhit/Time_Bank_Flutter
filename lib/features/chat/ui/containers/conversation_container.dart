import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
// import 'dart:io'; // <-- Import này dường như không cần thiết
import 'dart:typed_data';

import '../../providers/chat_providers.dart';
import '../../domain/models/message.dart';
import '../../domain/models/thread.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ConversationContainer extends ConsumerStatefulWidget {
  final String threadId;
  final String fallbackName;

  const ConversationContainer({
    Key? key,
    required this.threadId,
    required this.fallbackName,
  }) : super(key: key);

  @override
  ConsumerState<ConversationContainer> createState() => _ConversationContainerState();
}

class _ConversationContainerState extends ConsumerState<ConversationContainer> {
  final TextEditingController _ctrl = TextEditingController();
  bool _isPickingImage = false;

  final List<Message> _pendingMessages = [];
  final _uuid = const Uuid();

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    // === SỬA 1: KIỂM TRA NULL ===
    final myUid = ref.read(currentUidProvider);
    if (myUid == null) {
      debugPrint('🔥 Send error: User is null');
      return; // Đã logout, không gửi
    }
    // =============================

    final tempId = _uuid.v4();

    final tempMessage = Message(
      id: tempId,
      threadId: widget.threadId,
      localId: tempId,
      text: text,
      senderId: myUid, // <-- Bây giờ đã an toàn (không null)
      createdAt: DateTime.now(),
      type: MessageType.text,
      status: MessageStatus.pending,
    );

    setState(() {
      _pendingMessages.add(tempMessage);
      _ctrl.clear();
    });

    try {
      await ref.read(sendTextProvider(
        (threadId: widget.threadId, text: text, localId: tempId),
      ).future);
    } catch (e) {
      debugPrint('🔥 Send text error: $e');
      setState(() {
        final index = _pendingMessages.indexWhere((m) => m.localId == tempId);
        if (index != -1) {
          _pendingMessages[index] = _pendingMessages[index].copyWith(status: MessageStatus.failed);
        }
      });
    }
  }

  Future<void> _retrySend(Message failedMessage) async {
    final tempId = failedMessage.localId!;
    setState(() {
      final index = _pendingMessages.indexWhere((m) => m.localId == tempId);
      if (index != -1) {
        _pendingMessages[index] = _pendingMessages[index].copyWith(status: MessageStatus.pending);
      }
    });

    try {
      await ref.read(sendTextProvider(
        (threadId: widget.threadId, text: failedMessage.text!, localId: tempId),
      ).future);
    } catch (e) {
      debugPrint('🔥 Send retry error: $e');
      setState(() {
        final index = _pendingMessages.indexWhere((m) => m.localId == tempId);
        if (index != -1) {
          _pendingMessages[index] = _pendingMessages[index].copyWith(status: MessageStatus.failed);
        }
      });
    }
  }

  Future<void> _pickAndSendImage() async {
    if (_isPickingImage) return;

    try {
      _isPickingImage = true;
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;

      // === SỬA 2: KIỂM TRA NULL ===
      final myUid = ref.read(currentUidProvider);
      if (myUid == null) {
        debugPrint('🔥 Send image error: User is null');
        return; // Đã logout, không gửi
      }
      // =============================

      final tempId = _uuid.v4();
      final Uint8List bytes = await picked.readAsBytes();
      final mime = picked.path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

      final tempMessage = Message(
        id: tempId,
        threadId: widget.threadId,
        localId: tempId,
        senderId: myUid, // <-- Bây giờ đã an toàn (không null)
        createdAt: DateTime.now(),
        type: MessageType.image,
        mediaUrl: picked.path,
        isLocalFile: true,
        status: MessageStatus.pending,
      );

      setState(() {
        _pendingMessages.add(tempMessage);
      });

      await ref.read(sendImageProvider(
        (threadId: widget.threadId, bytes: bytes, mime: mime, localId: tempId),
      ).future);
    } catch (e, st) {
      debugPrint('🔥 Image pick/send error: $e\n$st');
      setState(() {
        final index = _pendingMessages.lastIndexWhere((m) => m.type == MessageType.image && m.status == MessageStatus.pending);
        if (index != -1) {
          _pendingMessages[index] = _pendingMessages[index].copyWith(status: MessageStatus.failed);
        }
      });
    } finally {
      _isPickingImage = false;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Thread _selectThread(AsyncValue<List<Thread>> threadsAsync) {
    return threadsAsync.maybeWhen(
      data: (threads) => threads.firstWhere((t) => t.id == widget.threadId,
          orElse: () => Thread(id: widget.threadId, name: widget.fallbackName, members: const [])),
      orElse: () => Thread(id: widget.threadId, name: widget.fallbackName, members: const []),
    );
  }

  // Hàm này yêu cầu "String myUid" (không thể null)
  String? _peerUid(Thread thread, String myUid) {
    if (thread.members.length != 2) return null;
    return thread.members.firstWhere((u) => u != myUid, orElse: () => myUid);
  }

  @override
  Widget build(BuildContext context) {
    // === SỬA 3: KIỂM TRA NULL ===
    final myUid = ref.watch(currentUidProvider); // <-- myUid là String?

    // Nếu đã logout (myUid == null), hiển thị loading để chờ bị hủy
    if (myUid == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // =============================

    final threadsAsync = ref.watch(threadsProvider);
    final thread = _selectThread(threadsAsync);

    // Bây giờ myUid đã được đảm bảo là "String" (không null)
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
              data: (backendMessages) {
                final backendLocalIds = backendMessages
                    .where((m) => m.localId != null)
                    .map((m) => m.localId)
                    .toSet();

                final uniquePendingMessages = _pendingMessages
                    .where((pending) => !backendLocalIds.contains(pending.localId))
                    .toList();

                final allMessages = [
                  ...uniquePendingMessages,
                  ...backendMessages,
                ];

                allMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                  itemCount: allMessages.length,
                  itemBuilder: (context, i) {
                    final m = allMessages[i];
                    final isMe = m.senderId == myUid; // <-- An toàn

                    return MessageBubble(
                      message: m,
                      isMe: isMe,
                      avatar: null,
                      online: !isMe && isPeerOnline,
                      onRetry: (m.status == MessageStatus.failed && m.type == MessageType.text)
                          ? () => _retrySend(m)
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Lỗi tải tin nhắn: $e')),
            ),
          ),
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