import 'package:cloud_firestore/cloud_firestore.dart';

class Thread {
  final String id;
  final String? name;
  final List<String> members;
  final String? lastText;
  final String? lastType;          // 'text' | 'image'
  final String? lastSenderId;
  final DateTime? lastAt;
  final Map<String, String> memberNames;

  const Thread({
    required this.id,
    this.name,
    required this.members,
    this.lastText,
    this.lastType,
    this.lastSenderId,
    this.lastAt,
    this.memberNames = const {},
  });

  factory Thread.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final lm = (d['lastMessage'] as Map<String, dynamic>?) ?? {};
    final namesData = d['memberNames'] as Map<String, dynamic>? ?? {};
    final memberNames = namesData.map((key, value) => MapEntry(key, value.toString()));
    return Thread(
      id: doc.id,
      name: d['name'] as String?,
      members: (d['members'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      lastText: lm['text'] as String?,
      lastType: lm['type'] as String?,
      lastSenderId: lm['senderId'] as String?,
      lastAt: (lm['at'] is Timestamp) ? (lm['at'] as Timestamp).toDate() : null,
      memberNames: memberNames,
    );
  }

  Map<String, dynamic> toFirestore() => {
    if (name != null) 'name': name,
    'members': members,
    if (memberNames.isNotEmpty) 'memberNames': memberNames,

    if (lastText != null || lastType != null || lastSenderId != null || lastAt != null)
      'lastMessage': {
        if (lastText != null) 'text': lastText,
        if (lastType != null) 'type': lastType,
        if (lastSenderId != null) 'senderId': lastSenderId,
        if (lastAt != null) 'at': Timestamp.fromDate(lastAt!),
      },
  };
}