import 'package:flutter/material.dart';
import '../../domain/models/thread.dart';

class ChatListItem extends StatelessWidget {
  final Thread thread;
  final VoidCallback? onTap;
  const ChatListItem({Key? key, required this.thread, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage(thread.avatar),
      ),
      title: Text(thread.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        thread.subtitle,
        style: TextStyle(
          fontSize: 12,
          color: thread.online ? Colors.green : const Color(0xFF6B7B88),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Color(0xFF9AA7B2)),
        onPressed: () {},
      ),
      onTap: onTap,
    );
  }
}
