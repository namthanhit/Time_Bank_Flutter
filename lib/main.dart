import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseDatabase.instance.databaseURL = 'https://timebanking-chat-default-rtdb.firebaseio.com/';

  runApp(const ProviderScope(child: App()));
}
