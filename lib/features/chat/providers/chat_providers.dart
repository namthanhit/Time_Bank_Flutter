import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/thread.dart';
import '../domain/models/message.dart';
import '../domain/repositories/chat_repository.dart';
import '../data/mock_chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) => MockChatRepository());

final threadsProvider = FutureProvider<List<Thread>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.fetchThreads();
});

final messagesProvider = FutureProvider.family<List<Message>, String>((ref, threadId) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.fetchMessages(threadId);
});
