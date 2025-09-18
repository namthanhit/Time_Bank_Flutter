# Time Banking App

Time Banking App là dự án ứng dụng giúp mọi người trao đổi dịch vụ bằng thời gian thay vì tiền. Làm giúp ai đó 1 giờ → nhận `+1h` vào ví; cần ai đó giúp 1 giờ → dùng `-1h` từ ví. Hệ thống bảo đảm công bằng nhờ giữ tạm (escrow) và xác nhận hai bên sau khi hoàn thành.

## Mục tiêu

- Tạo một nền tảng an toàn, minh bạch cho trao đổi dịch vụ cộng đồng.
- Khuyến khích tinh thần tương trợ, đo bằng thời gian đóng góp.
- Xây dựng nền tảng có thể mở rộng (mobile-first), sẵn sàng cho triển khai thực tế.

---

## Giá trị cốt lõi

1.  **1 giờ = 1 giờ**: Mọi kỹ năng đều bình đẳng về thời gian.
2.  **Tin cậy**: Escrow & xác nhận 2 chiều, đánh giá sau dịch vụ.
3.  **Tiện lợi**: Tìm kiếm theo kỹ năng / khu vực / thời gian rảnh.

---

## Tính năng chính (MVP)

- **Đăng ký/Đăng nhập**: Hồ sơ người dùng & xác minh cơ bản.
- **Ví thời gian**: Số dư giờ, lịch sử giao dịch.
- **Quản lý kỹ năng/dịch vụ**: Thêm/sửa/ẩn/hiện, phân loại.
- **Tìm kiếm & ghép đôi**: Theo kỹ năng, khu vực, thời gian rảnh, uy tín.
- **Lên lịch & Escrow**: Giữ tạm giờ, xác nhận hoàn tất để cộng/trừ.
- **Đánh giá & phản hồi**, thông báo trạng thái.

---

## Đối tượng người dùng

- Cá nhân muốn giúp đỡ cộng đồng và tích lũy giờ.
- Nhóm/CLB/địa phương muốn tổ chức tương trợ minh bạch.
- Người học kỹ năng mới bằng cách đổi thời gian.

---

## Lộ trình ngắn hạn

- **MVP**: Auth → Profile → Wallet → Skills → Match → Schedule/Escrow → Rating.
- **Bản mở rộng**: `i18n` (vi/en), bản đồ khu vực, xác minh nâng cao, phân giải tranh chấp.

