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
import '../../auth/providers/auth_providers.dart';


final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirebaseChatRepository();
});

final currentUidProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});


final threadsProvider = StreamProvider<List<Thread>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value([]);
  return repo.watchThreads(uid);
});

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, threadId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages(threadId, limit: 30);
});


final peerProfileProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, uid) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.data() ?? {});
});


final myProfileNameProvider = Provider<String>((ref) {
  final myProfileAsync = ref.watch(userProfileProvider);

  return myProfileAsync.when(
    data: (profile) {
      if (profile.fullName != null && profile.fullName!.isNotEmpty) {
        return profile.fullName!;
      }
      return 'Người dùng';
    },
    loading: () => 'Đang tải...',
    error: (e, s) => 'Người dùng',
  );
});

final ensureDmThreadProvider = FutureProvider.family
    .autoDispose<String, ({String peerUid, String peerName})>(
      (ref, peerData) async {
    final repo = ref.watch(chatRepositoryProvider);
    final myUid = ref.watch(currentUidProvider);

    if (myUid == null) {
      throw StateError('User must be logged in');
    }

    final myName = ref.watch(myProfileNameProvider);

    if (myName == 'Đang tải...') {
      final profile = await ref.read(userProfileProvider.future);
      final finalName = profile.fullName ?? 'Người dùng';
      return repo.ensureDmThread(
        myUid,
        peerData.peerUid,
        finalName,
        peerData.peerName,
      );
    }

    return repo.ensureDmThread(
      myUid,
      peerData.peerUid,
      myName,
      peerData.peerName,
    );
  },
);

  final sendTextProvider = FutureProvider.family.autoDispose<void, ({
    String threadId,
    String text,
    String localId
    })>((ref, args) async {

      final repo = ref.watch(chatRepositoryProvider);
      final myUid = ref.watch(currentUidProvider);
      if (myUid == null) throw StateError('User must be logged in');
      await repo.sendText(
        threadId: args.threadId,
        text: args.text,
        senderId: myUid,
        localId: args.localId,
      );
  });

final sendImageProvider = FutureProvider.family.autoDispose<void, ({
String threadId,
Uint8List bytes,
String mime,
String localId
})>((ref, args) async {
  final myUid = ref.watch(currentUidProvider);
  if (myUid == null) throw StateError('User must be logged in');

  final firestore = FirebaseFirestore.instance;
  final storage = fs.FirebaseStorage.instance;
  final path = 'chat_images/${args.threadId}/$myUid/${args.localId}.jpg';
  final task = await storage.ref(path).putData(args.bytes, fs.SettableMetadata(contentType: args.mime));
  final url = await task.ref.getDownloadURL();
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
      'localId': args.localId,
    });
    tx.update(roomRef, {
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': {
        'text': '[image]',
        'type': 'image',
        'senderId': myUid,
        'at': FieldValue.serverTimestamp(),
        'localId': args.localId,
      },
    });
  });
});

final startPresenceProvider = Provider<void>((ref) {

  final uid = ref.watch(currentUidProvider);
  if (uid == null) return;
  final db = FirebaseDatabase.instance;
  final userRef = db.ref('status/$uid');
  final connectedRef = db.ref('.info/connected');
  userRef.onDisconnect().set({
    'state': 'offline',
    'last_changed': ServerValue.timestamp,
  });
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


final presenceProvider = StreamProvider.family<bool, String>((ref, uid) {
  final db = FirebaseDatabase.instance;
  return db.ref('status/$uid/state').onValue.map(
        (e) => e.snapshot.value == 'online',
  );
});

final chatSearchQueryProvider = StateProvider<String>((_) => '');