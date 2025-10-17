import 'package:flutter/material.dart';
import '../../domain/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String avatar;
  final bool online;
  const MessageBubble({Key? key, required this.message, required this.avatar, this.online = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMe = message.fromMe;
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(avatar),
                    ),
                    if (online)
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade700,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 2, offset: Offset(0,1))],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            message.text == '[image]' && !isMe
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Image.asset(
                      'assets/images/avatar.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  )
                : ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                      minWidth: 48,
                    ),
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 6,
                        bottom: 2,
                        left: isMe ? 32 : 0,
                        right: isMe ? 0 : 32,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFF003E77) : const Color(0xFFF2F4F6),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.isVoice)
                            Row(children: [
                              Container(
                                width: 140,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.white.withOpacity(0.06) : const Color(0xFFF3F6F8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.play_arrow, size: 18, color: Color(0xFF6B7B88)),
                                    const SizedBox(width: 8),
                                    Text('00:40', style: const TextStyle(color: Color(0xFF6B7B88))),
                                  ],
                                ),
                              ),
                            ]),
                          if (!message.isVoice)
                            Text(message.text, style: TextStyle(color: isMe ? Colors.white : const Color(0xFF2B3A45))),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
            left: isMe ? 0 : 45,
            right: isMe ? 8 : 0,
            bottom: 2,
          ),
          child: Text(
            _formatTime(message.createdAt),
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7B88)),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
