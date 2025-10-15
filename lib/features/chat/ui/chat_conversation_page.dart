import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_providers.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input.dart';
import '../domain/models/thread.dart';

class ChatConversationPage extends ConsumerStatefulWidget {
	final String name;
	final String threadId;
	const ChatConversationPage({Key? key, required this.name, required this.threadId}) : super(key: key);

	@override
	ConsumerState<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends ConsumerState<ChatConversationPage> {
	final TextEditingController _controller = TextEditingController();

	Future<void> _send() async {
		final text = _controller.text.trim();
		if (text.isEmpty) return;
		final repo = ref.read(chatRepositoryProvider);
		await repo.sendMessage(widget.threadId, text);
		_controller.clear();
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		final messagesAsync = ref.watch(messagesProvider(widget.threadId));
		return Scaffold(
			backgroundColor: const Color(0xFFEFF4F8),
			appBar: AppBar(
				backgroundColor: Colors.white,
				foregroundColor: Colors.black,
				elevation: 0,
				title: Row(children: [
					CircleAvatar(
						backgroundColor: Colors.white,
						backgroundImage: AssetImage('assets/images/avatar.png'),
					),
					const SizedBox(width: 12),
					Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
						Text(widget.name, style: const TextStyle(fontWeight: FontWeight.w700)),
						const Text('2 Online', style: TextStyle(fontSize: 12, color: Colors.green)),
					])
				]),
				actions: [
					IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
					IconButton(onPressed: () {}, icon: const Icon(Icons.videocam)),
					IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
				],
			),
			body: Column(
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
											data: (threads) {
												final found = threads.where((t) => t.id == m.threadId);
												if (found.isNotEmpty && found.first.avatar.isNotEmpty) {
													return found.first;
												}
												return Thread(id: '', name: '', subtitle: '', online: false, avatar: 'assets/images/avatar.png');
											},
											orElse: () => Thread(id: '', name: '', subtitle: '', online: false, avatar: 'assets/images/avatar.png'),
										);
										return MessageBubble(message: m, avatar: thread.avatar);
												},
											),
							loading: () => const Center(child: CircularProgressIndicator()),
							error: (e, _) => Center(child: Text('Lỗi: $e')),
						),
					),
					MessageInput(controller: _controller, onSend: _send),
				],
			),
		);
	}
}

