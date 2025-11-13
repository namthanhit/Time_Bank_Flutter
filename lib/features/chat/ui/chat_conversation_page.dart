import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'containers/conversation_container.dart';
import '../providers/chat_providers.dart';
import '../domain/models/thread.dart';

class ChatConversationPage extends ConsumerWidget {
	final String threadId;
	final String fallbackName;

	const ChatConversationPage({
		Key? key,
		required this.threadId,
		required this.fallbackName,
	}) : super(key: key);

	String? _peerUid(Thread thread, String myUid) {
		if (thread.members.length != 2) return null;
		return thread.members.firstWhere((u) => u != myUid, orElse: () => myUid);
	}

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final myUid = ref.watch(currentUidProvider);
		if (myUid == null) {
			return const Scaffold(body: Center(child: CircularProgressIndicator()));
		}

		final threadsAsync = ref.watch(threadsProvider);
		final peerUid = threadsAsync.maybeWhen(
			data: (threads) {
				final thread = threads.firstWhere((t) => t.id == threadId,
						orElse: () => Thread(id: threadId, members: []));
				return _peerUid(thread, myUid);
			},
			orElse: () => null,
		);

		final presenceAsync = (peerUid != null)
				? ref.watch(presenceProvider(peerUid))
				: const AsyncValue<bool>.data(false);
		final isPeerOnline = presenceAsync.asData?.value ?? false;

		final title = fallbackName; // Luôn dùng fallbackName (tên peer)
		final initials = title.isNotEmpty ? title.trim().characters.first.toUpperCase() : '?';

		return Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.white,
				foregroundColor: Colors.black,
				elevation: 0,
				title: Row(
					children: [
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
													fontWeight: FontWeight.w700,
													fontSize: 16,
													color: Color(0xFF334155),
												),
											),
										),
									),
									Positioned(
										right: 0,
										bottom: 0,
										child: Transform.translate(
											offset: const Offset(2, 0),
											child: Container(
												width: 14,
												height: 14,
												decoration: BoxDecoration(
													color: isPeerOnline ? Colors.green : Colors.grey.shade600,
													shape: BoxShape.circle,
													border: Border.all(color: Colors.white, width: 2.5),
												),
											),
										),
									),
								],
							),
						),
						const SizedBox(width: 12),
						Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
								Text(
									isPeerOnline ? 'Online' : 'Offline',
									style: TextStyle(fontSize: 12, color: isPeerOnline ? Colors.green : const Color(0xFF6B7B88)),
								),
							],
						),
					],
				),
			),
			body: ConversationContainer(
				threadId: threadId,
				fallbackName: fallbackName,
			),
		);
	}
}