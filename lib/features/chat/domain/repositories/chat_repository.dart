import '../models/message.dart';
import '../models/thread.dart';

abstract class ChatRepository {
  // Threads
  Stream<List<Thread>> watchThreads(String myUid); // danh sách room có mình
  Future<String> ensureDmThread(String uidA, String uidB);

  // Messages
  Stream<List<Message>> watchMessages(String threadId, {int limit});
  Future<void> sendText({
    required String threadId,
    required String text,
    required String senderId,
    required String localId, // <-- THÊM DÒNG NÀY
  });
  Future<void> sendImage({required String threadId, required List<int> bytes, required String senderId, String mime});

  // Presence (online/offline)
  Future<void> startPresence(String myUid);
  Stream<bool> watchPresence(String uid);
}
