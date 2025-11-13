import 'package:flutter/material.dart';
import 'containers/chat_list_container.dart';
import 'chat_conversation_page.dart';


class ChatListPage extends StatelessWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Chat', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Row(
                children: [
                  Icon(Icons.search, size: 18, color: Color(0xFF9AA7B2)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Search member', style: TextStyle(color: Color(0xFF9AA7B2))),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ChatListContainer(
              onThreadTap: (threadId, threadName) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatConversationPage(
                      threadId: threadId,
                      fallbackName: threadName,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}