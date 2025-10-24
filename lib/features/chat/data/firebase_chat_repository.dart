import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

import '../domain/models/message.dart';
import '../domain/models/thread.dart';
import '../domain/repositories/chat_repository.dart';

class FirebaseChatRepository implements ChatRepository {
  FirebaseChatRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseDatabase? rtdb,
  })  : _fs = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _rtdb = rtdb ?? FirebaseDatabase.instance;

  final FirebaseFirestore _fs;
  final FirebaseStorage _storage;
  final FirebaseDatabase _rtdb;

  // ----------------- Threads -----------------
  @override
  Stream<List<Thread>> watchThreads(String myUid) {
    final q = _fs
        .collection('rooms')
        .where('members', arrayContains: myUid)
        .orderBy('updatedAt', descending: true);

    return q.snapshots().map((snap) => snap.docs.map(Thread.fromFirestore).toList());
  }

  @override
  Future<String> ensureDmThread(String uidA, String uidB) async {
    // roomId ổn định từ 2 uid
    final roomId = ([uidA, uidB]..sort()).join('_');
    final roomRef = _fs.collection('rooms').doc(roomId);

    await _fs.runTransaction((tx) async {
      final s = await tx.get(roomRef);
      if (!s.exists) {
        tx.set(roomRef, {
          'type': 'dm',
          'members': [uidA, uidB],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    return roomId;
  }

  // ----------------- Messages -----------------
  @override
  Stream<List<Message>> watchMessages(String threadId, {int limit = 30}) {
    final q = _fs
        .collection('rooms/$threadId/messages')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    return q.snapshots().map((snap) => snap.docs.map((d) => Message.fromFirestore(threadId, d)).toList());
  }

  @override
  Future<void> sendText({
    required String threadId,
    required String text,
    required String senderId,
    required String localId, // <-- THÊM DÒNG NÀY
  }) async {
    // Lấy code transaction từ 'sendImageProvider'
    final firestore = FirebaseFirestore.instance;
    final roomRef = firestore.collection('rooms').doc(threadId);
    final msgRef = roomRef.collection('messages').doc();

    await firestore.runTransaction((tx) async {
      tx.set(msgRef, {
        'threadId': threadId,
        'senderId': senderId,
        'type': 'text',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'localId': localId, // <-- LƯU localId VÀO FIRESTORE
      });
      tx.update(roomRef, {
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': {
          'text': text,
          'type': 'text',
          'senderId': senderId,
          'at': FieldValue.serverTimestamp(),
          'localId': localId, // <-- (Nên thêm cả ở đây)
        },
      });
    });
  }

  @override
  Future<void> sendImage({
    required String threadId,
    required List<int> bytes,
    required String senderId,
    String mime = 'image/jpeg',
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$senderId.jpg';
    final path = 'rooms/$threadId/$fileName';
    final ref = _storage.ref().child(path);

    await ref.putData(Uint8List.fromList(bytes), SettableMetadata(contentType: mime));
    final url = await ref.getDownloadURL();

    final msgRef = _fs.collection('rooms/$threadId/messages').doc();
    final roomRef = _fs.collection('rooms').doc(threadId);
    await _fs.runTransaction((tx) async {
      tx.set(msgRef, {
        'senderId': senderId,
        'type': 'image',
        'mediaUrl': url,
        'mediaMime': mime,
        'createdAt': FieldValue.serverTimestamp(),
        'readBy': {senderId: FieldValue.serverTimestamp()},
      });
      tx.update(roomRef, {
        'lastMessage': {
          'text': null,
          'type': 'image',
          'senderId': senderId,
          'at': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ----------------- Presence -----------------
  @override
  Future<void> startPresence(String myUid) async {
    final ref = _rtdb.ref('status/$myUid');
    await ref.set({
      'online': true,
      'lastActiveAt': ServerValue.timestamp,
      'device': 'flutter',
    });
    ref.onDisconnect().set({
      'online': false,
      'lastActiveAt': ServerValue.timestamp,
      'device': 'flutter',
    });
  }

  @override
  Stream<bool> watchPresence(String uid) {
    return _rtdb.ref('status/$uid/online').onValue.map((e) {
      final v = e.snapshot.value;
      return v == true;
    });
  }

}
