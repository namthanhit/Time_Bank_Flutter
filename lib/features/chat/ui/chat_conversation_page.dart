import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_providers.dart';
import 'widgets/message_bubble.dart';
import '../domain/models/thread.dart';
import '../domain/models/message.dart';
import 'widgets/message_input.dart';

class ChatConversationPage extends ConsumerStatefulWidget {
	final String name;      // tên fallback nếu Thread chưa có
	final String threadId;

	const ChatConversationPage({
		Key? key,
		required this.name,
		required this.threadId,
	}) : super(key: key);

	@override
	ConsumerState<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends ConsumerState<ChatConversationPage> {
	final TextEditingController _controller = TextEditingController();

	Future<void> _send() async {
		final text = _controller.text.trim();
		if (text.isEmpty) return;
		await ref.read(
			sendTextProvider((threadId: widget.threadId, text: text)).future,
		);
		_controller.clear();
		setState(() {});
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	/// Lấy thread hiện tại (nếu chưa có thì tạo thread tạm với name fallback)
	Thread _selectThread(AsyncValue<List<Thread>> threadsAsync) {
		return threadsAsync.maybeWhen(
			data: (threads) {
				final found = threads.where((t) => t.id == widget.threadId);
				if (found.isNotEmpty) return found.first;
				return Thread(id: widget.threadId, name: widget.name, members: const []);
			},
			orElse: () => Thread(id: widget.threadId, name: widget.name, members: const []),
		);
	}

	/// Lấy uid của đối tác trong phòng DM (members có 2 người)
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

		final messagesAsync = ref.watch(messagesProvider(widget.threadId));
		final presenceAsync = (peerUid != null)
				? ref.watch(presenceProvider(peerUid))
				: const AsyncValue<bool>.data(false);
		final isPeerOnline = presenceAsync.asData?.value ?? false;

		final title = thread.name?.isNotEmpty == true ? thread.name! : widget.name;
		final initials = title.isNotEmpty ? title.trim().characters.first.toUpperCase() : '?';

		return Scaffold(
			backgroundColor: const Color(0xFFEFF4F8),
			appBar: AppBar(
				backgroundColor: Colors.white,
				foregroundColor: Colors.black,
				elevation: 0,
				title: Row(
					children: [
						// Avatar chữ cái đầu (vì Thread chưa có avatar)
						SizedBox(
							width: 44,
							height: 44,
							child: Stack(
								children: [
									Positioned.fill(
										child: CircleAvatar(
											radius: 20,
											backgroundColor: const Color(0xFFE9EEF2),
											child: Text(
												initials,
												style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF334155)),
											),
										),
									),
									Positioned(
										right: 2,
										bottom: 2,
										child: Transform.translate(
											offset: const Offset(2, 0),
											child: Container(
												width: 14,
												height: 14,
												decoration: BoxDecoration(
													color: isPeerOnline ? Colors.green : Colors.grey.shade600,
													shape: BoxShape.circle,
													border: Border.all(color: Colors.white, width: 2.5),
													boxShadow: [
														BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 2, offset: const Offset(0, 1)),
													],
												),
											),
										),
									),
								],
							),
						),
						const SizedBox(width: 10),
						Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
								Text(
									isPeerOnline ? 'Online' : 'Offline',
									style: TextStyle(fontSize: 12, color: isPeerOnline ? Colors.green : Colors.grey.shade600),
								),
							],
						),
					],
				),
				actions: const [
					IconButton(onPressed: null, icon: Icon(Icons.call)),
					IconButton(onPressed: null, icon: Icon(Icons.videocam)),
					IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
				],
			),
			body: Column(
				children: [
					Expanded(
						child: messagesAsync.when(
							data: (messages) {
								// messagesProvider trả về desc theo createdAt; dùng reverse + ListView.reverse
								final List<Message> list = messages;
								return ListView.builder(
									reverse: true,
									padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
									itemCount: list.length,
									itemBuilder: (context, i) {
										final m = list[i];
										final isMe = m.senderId == myUid;
										return MessageBubble(
											message: m,
											isMe: isMe,
											// avatar có thể null; chấm online lấy theo peer
											avatar: null,
											online: !isMe && isPeerOnline,
										);
									},
								);
							},
							loading: () => const Center(child: CircularProgressIndicator()),
							error: (e, _) => Center(child: Text('Lỗi: $e')),
						),
					),
					// Ô nhập tin nhắn
					Padding(
						padding: const EdgeInsets.only(bottom: 4),
						child: Row(
							children: [
								Expanded(child: MessageInput(controller: _controller, onSend: _send)),
								// Nút gửi ảnh (tuỳ bạn thêm picker → gọi sendImageProvider)
								// IconButton(
								//   icon: const Icon(Icons.image),
								//   onPressed: () async {
								//     final bytes = await pickImageBytes(); // tự cài đặt
								//     if (bytes != null) {
								//       await ref.read(sendImageProvider(
								//         (threadId: widget.threadId, bytes: bytes, mime: 'image/jpeg'),
								//       ).future);
								//     }
								//   },
								// ),
							],
						),
					),
				],
			),
		);
	}
}
