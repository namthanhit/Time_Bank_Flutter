import '../domain/models/message.dart';
import '../domain/models/thread.dart';
import '../domain/repositories/chat_repository.dart';

class MockChatRepository implements ChatRepository {
  final List<Thread> _threads = [
  const Thread(id: '1', name: 'Lilly Jane', subtitle: 'Online', online: true, avatar: 'assets/images/avatar.png'),
  const Thread(id: '2', name: 'Margo Love', subtitle: 'Online', online: true, avatar: 'assets/images/avatar.png'),
  const Thread(id: '3', name: 'Candice Fin', subtitle: 'Last seen 10 min ago', avatar: 'assets/images/avatar.png'),
  const Thread(id: '4', name: 'Casper D', subtitle: 'Last seen 12 min ago', avatar: 'assets/images/avatar.png'),
  const Thread(id: '5', name: 'Robert T', subtitle: 'Last seen 1 hours ago', avatar: 'assets/images/avatar.png'),
  const Thread(id: '6', name: 'Josephen', subtitle: 'Last seen 3 hours ago', avatar: 'assets/images/avatar.png'),
  ];

  final Map<String, List<Message>> _messages = {
    '1': [
      Message(id: 'm1', threadId: '1', senderName: 'Lilly Jane', text: "Hi Let's decide Our Halloween Costume?", fromMe: false, createdAt: DateTime.now().subtract(const Duration(minutes: 10))),
      Message(id: 'm2', threadId: '1', senderName: 'Lilly Jane', text: "(voice)", fromMe: false, isVoice: true, createdAt: DateTime.now().subtract(const Duration(minutes: 10))),
      Message(id: 'm_img', threadId: '1', senderName: 'Lilly Jane', text: "[image]", fromMe: false, createdAt: DateTime.now().subtract(const Duration(minutes: 9))),
      Message(id: 'm3', threadId: '1', senderName: 'Me', text: "yeh!! Let's make it Spooky", fromMe: true, createdAt: DateTime.now().subtract(const Duration(minutes: 9))),
      Message(id: 'm4', threadId: '1', senderName: 'Lilly Jane', text: "Scary potion coming up", fromMe: false, createdAt: DateTime.now().subtract(const Duration(minutes: 8))),
      Message(id: 'm5', threadId: '1', senderName: 'Me', text: "Great let's Video Call at 8", fromMe: true, createdAt: DateTime.now().subtract(const Duration(minutes: 7))),
      Message(id: 'm_img2', threadId: '1', senderName: 'Lilly Jane', text: "[image]", fromMe: false, createdAt: DateTime.now().subtract(const Duration(minutes: 6))),
    ],
  };

  @override
  Future<List<Thread>> fetchThreads() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _threads;
  }

  @override
  Future<List<Message>> fetchMessages(String threadId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _messages[threadId] ?? [];
  }

  @override
  Future<void> sendMessage(String threadId, String text, {bool isVoice = false}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _messages.putIfAbsent(threadId, () => []);
    _messages[threadId]!.add(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      threadId: threadId,
      senderName: 'Me',
      text: text,
      fromMe: true,
      isVoice: isVoice,
      createdAt: DateTime.now(),
    ));
  }
}
