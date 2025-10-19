# Mô tả các file trong `lib/features/chat` (Tiếng Việt)

Tập tin này tóm tắt chức năng chính của các file trong thư mục `lib/features/chat` để giúp hiểu rõ cấu trúc và trách nhiệm của từng thành phần.

## Cấu trúc chính
- data/: chứa repository / dữ liệu giả (mock) cho feature chat.
- domain/: chứa các model và interface repository.
- providers/: chứa các Riverpod providers dùng cho chat.
- ui/: chứa giao diện người dùng (pages, containers, widgets) cho chat.

---

## File chính

- `lib/features/chat/data/mock_chat_repository.dart`
  - Mục đích: Cung cấp dữ liệu giả (threads, messages) để phát triển và test giao diện.
  - Ghi chú: Chứa các thread mẫu với thuộc tính `online`, `avatar`, và danh sách message mẫu.

- `lib/features/chat/domain/models/thread.dart`
  - Mục đích: Định nghĩa model Thread (id, name, subtitle, avatar, online,...).

- `lib/features/chat/domain/models/message.dart`
  - Mục đích: Định nghĩa model Message (id, threadId, text, type, timestamp,...).

- `lib/features/chat/repositories/chat_repository.dart`
  - Mục đích: Interface/abstraction cho thao tác với chat (lấy threads, messages, gửi tin nhắn).

- `lib/features/chat/providers/chat_providers.dart`
  - Mục đích: Khai báo Riverpod providers (threadsProvider, messagesProvider, chatRepositoryProvider) để UI tiêu thụ dữ liệu.

---

## UI

- `lib/features/chat/ui/chat_list_page.dart`
  - Mục đích: Trang danh sách cuộc trò chuyện (Chat list). Chứa scaffold chính, ô tìm kiếm, và khởi tạo `ChatListContainer`.
  - Ghi chú: Cũng chứa `_ChatConversationScaffold` dùng để điều hướng vào màn hội thoại (AppBar + ConversationContainer).

- `lib/features/chat/ui/chat_conversation_page.dart`
  - Mục đích: Trang hội thoại độc lập (Conversation) với AppBar, danh sách messages và input.
  - Ghi chú: Lấy dữ liệu messages qua providers và render `MessageBubble` + `MessageInput`.

### containers/

- `lib/features/chat/ui/containers/chat_list_container.dart`
  - Mục đích: Container chịu trách nhiệm gọi `threadsProvider` và đưa dữ liệu xuống component trình bày `ChatList` (handling loading/error).

- `lib/features/chat/ui/containers/conversation_container.dart`
  - Mục đích: Container cho màn hội thoại: lấy messages từ `messagesProvider(threadId)`, render list message và xử lý gửi tin nhắn (gọi repository và invalidate provider).

### widgets/

- `lib/features/chat/ui/widgets/chat_list.dart`
  - Mục đích: Component trình bày danh sách thread (UI-only). Nhận danh sách threads và callback onTap.

- `lib/features/chat/ui/widgets/chat_list_item.dart`
  - Mục đích: Item của danh sách chat: hiển thị avatar, tên, subtitle, thời gian, và trạng thái (status dot).

- `lib/features/chat/ui/widgets/message_bubble.dart`
  - Mục đích: Hiển thị từng message (bubble) trong cuộc hội thoại, có khả năng hiển thị avatar, media, playback, và trạng thái online nhỏ cạnh avatar.

- `lib/features/chat/ui/widgets/message_input.dart`
  - Mục đích: Thanh nhập tin nhắn ở cuối màn hình (text field + nút gửi). Gọi callback onSend khi người dùng gửi.

---

Nếu bạn muốn mình sinh file mô tả chi tiết hơn (kèm ví dụ props, shape của models, hoặc sơ đồ luồng dữ liệu), mình sẽ bổ sung.
