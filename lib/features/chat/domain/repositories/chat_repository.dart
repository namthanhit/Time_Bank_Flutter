import '../models/message.dart';
import '../models/thread.dart';

abstract class ChatRepository {
  Future<List<Thread>> fetchThreads();
  Future<List<Message>> fetchMessages(String threadId);
  Future<void> sendMessage(String threadId, String text, {bool isVoice = false});
}
