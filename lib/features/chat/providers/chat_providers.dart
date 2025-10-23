import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/models/message.dart';
import '../domain/models/thread.dart';
import '../domain/repositories/chat_repository.dart';
import '../data/firebase_chat_repository.dart';
import 'package:firebase_database/firebase_database.dart';

// Repo provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirebaseChatRepository();
});

// Current user uid (giả sử bạn đã login Firebase)
final currentUidProvider = Provider<String>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('Not signed in');
  }
  return user.uid;
});

// Stream threads có mình tham gia
final threadsProvider = StreamProvider<List<Thread>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final uid = ref.watch(currentUidProvider);
  return repo.watchThreads(uid);
});

// Stream messages theo thread
final messagesProvider = StreamProvider.family<List<Message>, String>((ref, threadId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages(threadId, limit: 30);
});

// Action: ensure DM
final ensureDmThreadProvider = FutureProvider.family<String, String>((ref, peerUid) {
  final repo = ref.watch(chatRepositoryProvider);
  final myUid = ref.watch(currentUidProvider);
  return repo.ensureDmThread(myUid, peerUid);
});

// Action: send text
final sendTextProvider = FutureProvider.family.autoDispose<void, ({String threadId, String text})>((ref, args) async {
  final repo = ref.watch(chatRepositoryProvider);
  final myUid = ref.watch(currentUidProvider);
  await repo.sendText(threadId: args.threadId, text: args.text, senderId: myUid);
});

// Action: send image
final sendImageProvider = FutureProvider.family.autoDispose<void, ({String threadId, List<int> bytes, String mime})>((ref, args) async {
  final repo = ref.watch(chatRepositoryProvider);
  final myUid = ref.watch(currentUidProvider);
  await repo.sendImage(threadId: args.threadId, bytes: args.bytes, senderId: myUid, mime: args.mime);
});

// Presence
// final startPresenceProvider = FutureProvider<void>((ref) {
//   final repo = ref.watch(chatRepositoryProvider);
//   final myUid = ref.watch(currentUidProvider);
//   return repo.startPresence(myUid);
// });
//
// final presenceProvider = StreamProvider.family<bool, String>((ref, uid) {
//   final repo = ref.watch(chatRepositoryProvider);
//   return repo.watchPresence(uid);
// });

final startPresenceProvider = Provider<void>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final db = FirebaseDatabase.instance;
  final userRef = db.ref('status/$uid');
  final connectedRef = db.ref('.info/connected');

  // Khi disconnect khỏi RTDB, set offline
  userRef.onDisconnect().set({
    'state': 'offline',
    'last_changed': ServerValue.timestamp,
  });

  // Khi connected = true -> set online
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

/// Stream online/offline cho 1 uid (true = online)
final presenceProvider = StreamProvider.family<bool, String>((ref, uid) {
  final db = FirebaseDatabase.instance;
  // đọc state: 'online' / 'offline'
  return db.ref('status/$uid/state').onValue.map(
        (e) => e.snapshot.value == 'online',
  );
});
