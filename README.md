# Ứng Dụng Quản Lý Chi Tiêu Cá Nhân (DevOps Project)

Dự án ứng dụng web Quản lý chi tiêu cá nhân xây dựng bằng **Node.js + Express + Mongoose + EJS**, phục vụ cho môn học DevOps (Tuần 1 - Khởi tạo dự án & cấu trúc mã nguồn).

---

## 📁 Cấu trúc thư mục

```text
Quan-Li-Chi-Tieu/
├── docs/
│   └── week1-evidence/         # Tài liệu minh chứng tuần 1 (ảnh chụp màn hình, logs)
├── src/
│   ├── models/
│   │   └── Expense.js          # Mongoose Schema & Model cho khoản chi tiêu
│   ├── routes/
│   │   └── expenseRoutes.js    # Định tuyến CRUD chi tiêu (GET, POST, POST delete)
│   ├── views/
│   │   └── index.ejs           # Giao diện người dùng sử dụng Bootstrap 5 CDN
│   └── app.js                  # Điểm khởi động ứng dụng Express & kết nối MongoDB
├── .env                        # Biến môi trường cục bộ (không commit lên Git)
├── .env.example                # File mẫu biến môi trường
├── .gitignore                  # Cấu hình bỏ qua các file/thư mục không cần thiết
├── package.json                # Khai báo dependencies và scripts
└── README.md                   # Hướng dẫn dự án
```

---

## ⚙️ Cài đặt và Chạy ứng dụng

### 1. Cài đặt các gói phụ thuộc
```bash
npm install
```

### 2. Thiết lập biến môi trường
Sao chép file `.env.example` thành `.env` (nếu chưa có):
```bash
cp .env.example .env
```

Nội dung `.env.example`:
```env
PORT=3000
MONGO_URI=mongodb://127.0.0.1:27017/quanlychitieu
NODE_ENV=production
```

### 3. Khởi chạy ứng dụng
Chạy ở môi trường production / mặc định:
```bash
npm start
```

Chạy ở chế độ phát triển (auto-reload khi code thay đổi):
```bash
npm run dev
```

---

## 🌐 Các Đường Dẫn (Endpoints)

| Phương thức | Đường dẫn | Chức năng |
| :--- | :--- | :--- |
| `GET` | `/` | Chuyển hướng đến `/expenses` |
| `GET` | `/expenses` | Hiển thị giao diện, danh sách chi tiêu và thống kê tổng tiền |
| `POST` | `/expenses` | Thêm khoản chi tiêu mới (`title`, `amount`, `category`) |
| `POST` | `/expenses/:id/delete` | Xóa một khoản chi tiêu theo ID |
| `GET` | `/health` | Kiểm tra trạng thái ứng dụng (Health Check cho DevOps) |

### Kiểm tra Health Check
```bash
curl http://localhost:3000/health
```
Phản hồi mẫu:
```json
{
  "status": "UP",
  "database": "CONNECTED"
}
```