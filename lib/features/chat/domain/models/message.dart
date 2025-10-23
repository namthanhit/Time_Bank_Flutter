import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image }

class Message {
  final String id;
  final String threadId;
  final String senderId;
  final MessageType type;
  final String? text;
  final String? mediaUrl;
  final String? mediaMime;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.type,
    this.text,
    this.mediaUrl,
    this.mediaMime,
    required this.createdAt,
  });

  factory Message.fromFirestore(String threadId, DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Message(
      id: doc.id,
      threadId: threadId,
      senderId: d['senderId'] as String,
      type: (d['type'] == 'image') ? MessageType.image : MessageType.text,
      text: d['text'] as String?,
      mediaUrl: d['mediaUrl'] as String?,
      mediaMime: d['mediaMime'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'senderId': senderId,
    'type': type == MessageType.image ? 'image' : 'text',
    if (text != null) 'text': text,
    if (mediaUrl != null) 'mediaUrl': mediaUrl,
    if (mediaMime != null) 'mediaMime': mediaMime,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
