import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_providers.dart';
import '../domain/models/thread.dart';
import 'containers/conversation_container.dart';

class ChatConversationPage extends ConsumerStatefulWidget {
	final String name; // tên fallback nếu Thread chưa có
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
	// --- TOÀN BỘ LOGIC _send, _pickAndSendImage, _controller, dispose ĐÃ BỊ XÓA ---

	/// Lấy thread hiện tại (vẫn cần cho AppBar)
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

	/// Lấy uid của đối tác (vẫn cần cho AppBar)
	// Hàm này yêu cầu "String myUid" (không thể null)
	String? _peerUid(Thread thread, String myUid) {
		if (thread.members.length != 2) return null;
		return thread.members.firstWhere((u) => u != myUid, orElse: () => myUid);
	}

	@override
	Widget build(BuildContext context) {
		// --- Vẫn fetch data, nhưng CHỈ DÙNG CHO APPBAR ---

		// DÒNG 44: myUid bây giờ là "String?"
		final myUid = ref.watch(currentUidProvider);

		// ==========================================================
		// === SỬA LỖI Ở ĐÂY ===
		// Thêm kiểm tra null. Nếu user đã logout (myUid == null),
		// widget này sắp bị hủy, hiển thị loading để tránh crash.
		if (myUid == null) {
			return const Scaffold(
				body: Center(
					child: CircularProgressIndicator(),
				),
			);
		}
		// ==========================================================

		final threadsAsync = ref.watch(threadsProvider);
		final thread = _selectThread(threadsAsync);

		// Bây giờ "myUid" đã được đảm bảo là "String" (không null)
		// nên hàm này sẽ an toàn
		final peerUid = _peerUid(thread, myUid);

		final presenceAsync = (peerUid != null)
				? ref.watch(presenceProvider(peerUid))
				: const AsyncValue<bool>.data(false);
		final isPeerOnline = presenceAsync.asData?.value ?? false;

		final title = thread.name?.isNotEmpty == true ? thread.name! : widget.name;
		final initials = title.isNotEmpty ? title.trim().characters.first.toUpperCase() : '?';
		// --- HẾT PHẦN LOGIC CHO APPBAR ---

		return Scaffold(
			backgroundColor: const Color(0xFFEFF4F8),
			appBar: AppBar(
				backgroundColor: Colors.white,
				foregroundColor: Colors.black,
				elevation: 0,
				title: Row(
					children: [
						// Avatar chữ cái đầu
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
												style: const TextStyle(
														fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF334155)),
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
														BoxShadow(
																color: Colors.black.withOpacity(0.14),
																blurRadius: 2,
																offset: const Offset(0, 1)),
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
									style: TextStyle(
											fontSize: 12, color: isPeerOnline ? Colors.green : Colors.grey.shade600),
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
			// --- PHẦN BODY ĐƯỢC THAY THẾ HOÀN TOÀN ---
			body: ConversationContainer(
				threadId: widget.threadId,
				fallbackName: widget.name, // Truyền fallbackName vào
			),
		);
	}
}