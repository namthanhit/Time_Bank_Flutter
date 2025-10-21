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
				title: Builder(builder: (context) {
					final threadsAsync = ref.watch(threadsProvider);
					final thread = threadsAsync.maybeWhen(
						data: (threads) {
							final found = threads.where((t) => t.id == widget.threadId);
							if (found.isNotEmpty) return found.first;
							return Thread(id: '', name: widget.name, subtitle: '', online: false, avatar: 'assets/images/avatar.png');
						},
						orElse: () => Thread(id: '', name: widget.name, subtitle: '', online: false, avatar: 'assets/images/avatar.png'),
					);

										return Row(
											crossAxisAlignment: CrossAxisAlignment.center,
											children: [
												// Avatar inside fixed box to avoid clipping
												SizedBox(
													width: 44,
													height: 44,
													child: Stack(
														children: [
															Positioned.fill(
																child: CircleAvatar(
																	radius: 20,
																	backgroundColor: Colors.white,
																	backgroundImage: AssetImage(thread.avatar),
																),
															),
															// keep the small overlay (inside avatar) as a subtle indicator
																							Positioned(
																								right: 2,
																								bottom: 2,
																								child: Transform.translate(
																									offset: const Offset(2, 0),
																									child: Container(
																										width: 14,
																										height: 14,
																										decoration: BoxDecoration(
																											color: thread.online ? Colors.green : Colors.grey.shade600,
																											shape: BoxShape.circle,
																											border: Border.all(color: Colors.white, width: 2.5),
																											boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 2, offset: Offset(0, 1))],
																										),
																									),
																								),
																							),
														],
													),
												),
												const SizedBox(width: 8),
																		const SizedBox(width: 10),
																		Column(
																			crossAxisAlignment: CrossAxisAlignment.start,
																			mainAxisAlignment: MainAxisAlignment.center,
																			children: [
																				Text(thread.name.isNotEmpty ? thread.name : widget.name, style: const TextStyle(fontWeight: FontWeight.w700)),
																				// keep small subtitle text under the name
																				Text(thread.online ? 'Online' : 'Offline', style: TextStyle(fontSize: 12, color: thread.online ? Colors.green : Colors.grey.shade600)),
																			],
																		),
											],
										);
				}),
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
									final thread = ref.read(threadsProvider).maybeWhen(
										data: (threads) => threads.firstWhere((t) => t.id == m.threadId, orElse: () => Thread(id: '', name: '', subtitle: '', online: false, avatar: 'assets/images/avatar.png')),
										orElse: () => Thread(id: '', name: '', subtitle: '', online: false, avatar: 'assets/images/avatar.png'),
									);
									return MessageBubble(message: m, avatar: thread.avatar, online: thread.online);
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

