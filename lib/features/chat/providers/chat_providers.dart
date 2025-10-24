import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as fs;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/message.dart';
import '../domain/models/thread.dart';
import '../domain/repositories/chat_repository.dart';
import '../data/firebase_chat_repository.dart';

// ===================== REPOSITORY & USER =====================

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirebaseChatRepository();
});

final currentUidProvider = Provider<String>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw StateError('Not signed in');
  return user.uid;
});

// ===================== STREAMS =====================

final threadsProvider = StreamProvider<List<Thread>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final uid = ref.watch(currentUidProvider);
  return repo.watchThreads(uid);
});

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, threadId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages(threadId, limit: 30);
});

// ===================== ACTIONS =====================

final ensureDmThreadProvider = FutureProvider.family<String, String>((ref, peerUid) {
  final repo = ref.watch(chatRepositoryProvider);
  final myUid = ref.watch(currentUidProvider);
  return repo.ensureDmThread(myUid, peerUid);
});

final sendTextProvider = FutureProvider.family.autoDispose<void, ({String threadId, String text})>((ref, args) async {
  final repo = ref.watch(chatRepositoryProvider);
  final myUid = ref.watch(currentUidProvider);
  await repo.sendText(threadId: args.threadId, text: args.text, senderId: myUid);
});

/// Upload ảnh lên Firebase Storage + gửi message type=image
final sendImageProvider = FutureProvider.family.autoDispose<void, ({
String threadId,
List<int> bytes,
String mime,
})>((ref, args) async {
  final myUid = ref.watch(currentUidProvider);
  final firestore = FirebaseFirestore.instance;
  final storage = fs.FirebaseStorage.instance;

  // Tạo path: chat_images/{threadId}/{uid}/{timestamp}.jpg
  final ts = DateTime.now().millisecondsSinceEpoch;
  final path = 'chat_images/${args.threadId}/$myUid/$ts.jpg';

  // Upload lên Storage
  final task = await storage.ref(path).putData(
    Uint8List.fromList(args.bytes),
    fs.SettableMetadata(contentType: args.mime),
  );
  final url = await task.ref.getDownloadURL();

  // Ghi message vào Firestore
  final roomRef = firestore.collection('rooms').doc(args.threadId);
  final msgRef = roomRef.collection('messages').doc();

  await firestore.runTransaction((tx) async {
    tx.set(msgRef, {
      'threadId': args.threadId,
      'senderId': myUid,
      'type': 'image',
      'mediaUrl': url,
      'mediaMime': args.mime,
      'createdAt': FieldValue.serverTimestamp(),
    });
    tx.update(roomRef, {
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': {
        'text': '[image]',
        'type': 'image',
        'senderId': myUid,
        'at': FieldValue.serverTimestamp(),
      },
    });
  });
});

// ===================== PRESENCE =====================

/// Khởi tạo trạng thái online/offline (Realtime Database)
final startPresenceProvider = Provider<void>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final db = FirebaseDatabase.instance;
  final userRef = db.ref('status/$uid');
  final connectedRef = db.ref('.info/connected');

  // Khi disconnect → set offline
  userRef.onDisconnect().set({
    'state': 'offline',
    'last_changed': ServerValue.timestamp,
  });

  // Khi connect → set online
  connectedRef.onValue.listen((event) {
    final connected = event.snapshot.value == true;
    if (connected) {
      userRef.set({
        'state': 'online',
        'last_changed': ServerValue.timestamp,
      });
    }
  });
});

/// Theo dõi trạng thái online/offline (true = online)
final presenceProvider = StreamProvider.family<bool, String>((ref, uid) {
  final db = FirebaseDatabase.instance;
  return db.ref('status/$uid/state').onValue.map(
        (e) => e.snapshot.value == 'online',
  );
});
