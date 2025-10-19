class Message {
  final String id;
  final String threadId;
  final String senderName;
  final String text;
  final bool fromMe;
  final bool isVoice;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.threadId,
    required this.senderName,
    required this.text,
    required this.fromMe,
    this.isVoice = false,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> j) => Message(
        id: j['id'] as String,
        threadId: j['threadId'] as String,
        senderName: j['senderName'] as String,
        text: j['text'] as String,
        fromMe: j['fromMe'] as bool,
        isVoice: j['isVoice'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
