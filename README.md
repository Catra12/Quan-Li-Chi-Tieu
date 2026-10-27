# Ứng Dụng Quản Lý Chi Tiêu Cá Nhân (DevOps Project)

Dự án ứng dụng web Quản lý chi tiêu cá nhân xây dựng bằng **Node.js + Express + Mongoose + EJS**, phục vụ cho đồ án môn học DevOps:
- **Tuần 1:** Khởi tạo kiến trúc mã nguồn & RESTful Web Application.
- **Tuần 2:** Đóng gói ứng dụng (Containerization với Docker/Docker Compose) & Tự động hóa CI/CD với GitHub Actions (Self-hosted Runner).

---

## 📁 Cấu trúc thư mục dự án

```text
Quan-Li-Chi-Tieu/
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # GitHub Actions Workflow tự động test & deploy
├── docs/
│   ├── week1-evidence/         # Tài liệu minh chứng tuần 1
│   └── week2-evidence/         # Tài liệu minh chứng tuần 2 (Docker, Test, CI/CD)
├── src/
│   ├── models/
│   │   └── Expense.js          # Mongoose Schema & Model cho khoản chi tiêu
│   ├── routes/
│   │   └── expenseRoutes.js    # Định tuyến CRUD chi tiêu (GET, POST, POST delete)
│   ├── views/
│   │   └── index.ejs           # Giao diện Bootstrap 5 CDN hiện đại
│   └── app.js                  # Điểm khởi động ứng dụng (lắng nghe 0.0.0.0, /health)
├── tests/
│   └── expense.test.js         # Automated tests với Jest cho model Expense
├── .dockerignore               # Loại trừ các file không cần thiết khi đóng gói Docker
├── .env                        # Biến môi trường cục bộ (được .gitignore bảo vệ)
├── .env.example                # File mẫu biến môi trường
├── .gitignore                  # Cấu hình bỏ qua các file/thư mục Git
├── Dockerfile                  # Dockerfile tối ưu (Node 20 Alpine, non-root user)
├── docker-compose.yml          # Điều phối multi-container (App + MongoDB + Volume + Network)
├── package.json                # Khai báo dependencies, devDependencies và test script
└── README.md                   # Hướng dẫn chi tiết dự án
```

---

## 🧪 1. Kiểm Thử Tự Động (Automated Testing)

Dự án sử dụng **Jest** để kiểm thử tự động tính toàn vẹn của model `Expense` với 3 kịch bản:
1. Tạo khoản chi tiêu hợp lệ (`title`, `amount`, `category`) thành công.
2. Báo lỗi validation nếu thiếu `title`.
3. Báo lỗi validation nếu `amount` là số âm (`< 0`).

Chạy kiểm thử:
```bash
npm test
```

> **Lưu ý:** Lệnh `test` được cấu hình `"jest --runInBand --forceExit"`. Nếu có bất kỳ test case nào thất bại, lệnh sẽ trả về mã lỗi (`exit code != 0`), làm dừng pipeline CI/CD ngay lập tức.

---

## 🐳 2. Đóng Gói và Chạy với Docker & Docker Compose

Ứng dụng được đóng gói thành Docker Image tối ưu (`node:20-alpine`, non-root user `node`, giảm thiểu layer và bộ nhớ cache).

### 2.1. Cấu hình dịch vụ trong `docker-compose.yml`:
- **app**:
  - Image: `expense-tracker-app:latest` (build từ `Dockerfile`).
  - Container name: `expense-app`.
  - Port mapping: `127.0.0.1:3000:3000` (an toàn, chỉ mở cục bộ).
  - Kết nối đến database thông qua service name `mongo` (`mongodb://mongo:27017/quanlychitieu`).
  - Network: `expense-network`.
- **mongo**:
  - Image: `mongo:7.0`.
  - Container name: `expense-mongo`.
  - Persistent volume: `mongo_data` gắn vào `/data/db` (bảo toàn dữ liệu khi khởi động lại).
  - Không public cổng ra ngoài host để đảm bảo an toàn mạng.

### 2.2. Các lệnh điều khiển Docker Compose:

Khởi chạy toàn bộ hệ thống (build image và chạy nền):
```bash
docker compose up -d --build
```

Kiểm tra trạng thái các container:
```bash
docker compose ps
```

Xem log ứng dụng theo thời gian thực:
```bash
docker compose logs -f app
```

Dừng và gỡ bỏ toàn bộ container:
```bash
docker compose down
```

---

## 🚀 3. Tự Động Hóa CI/CD với GitHub Actions

Pipeline CI/CD được định nghĩa tại file [`.github/workflows/ci-cd.yml`](file:///.github/workflows/ci-cd.yml), kích hoạt tự động mỗi khi có sự kiện `push` hoặc `pull_request` vào nhánh `main` trên **Self-hosted Runner**:

### Quy trình 5 bước trong Pipeline:
1. **Bước 1: Checkout code** (`actions/checkout@v4`): Kéo mã nguồn mới nhất về runner.
2. **Bước 2: Cài đặt thư viện** (`npm ci`): Cài đặt chính xác các phụ thuộc theo `package-lock.json`.
3. **Bước 3: Chạy Automated Tests** (`npm test`): Thực thi Jest test suite. Nếu test fail, pipeline sẽ dừng lại ngay lập tức và ngăn chặn việc triển khai mã lỗi.
4. **Bước 4: Tạo file .env từ GitHub Secrets**: Tự động sinh file cấu hình chứa `PORT=3000`, `MONGO_URI` từ Repository Secrets và `NODE_ENV=production`.
5. **Bước 5: Deploy tự động bằng Docker Compose**:
   - Chạy lệnh `docker compose up -d --build` để build image mới và khởi động lại container mà không làm gián đoạn hệ thống.
   - Dọn dẹp các dangling images cũ bằng `docker image prune -f`.
   - Kiểm tra trạng thái hoạt động thực tế qua Health Check endpoint (`curl -f http://localhost/health` hoặc `http://127.0.0.1:3000/health`).

---

## 🌐 Các Đường Dẫn (Endpoints)

| Phương thức | Đường dẫn | Chức năng |
| :--- | :--- | :--- |
| `GET` | `/` | Chuyển hướng đến `/expenses` |
| `GET` | `/expenses` | Hiển thị giao diện danh sách chi tiêu và thống kê tổng tiền |
| `POST` | `/expenses` | Thêm khoản chi tiêu mới (`title`, `amount`, `category`) |
| `POST` | `/expenses/:id/delete` | Xóa một khoản chi tiêu theo ID |
| `GET` | `/health` | DevOps Health Check (Trả về HTTP 200 `{ status: "UP", database: "CONNECTED" }`) |

### Kiểm tra Health Check:
```bash
curl http://localhost:3000/health
```
Phản hồi mẫu khi MongoDB đã sẵn sàng:
```json
{
  "status": "UP",
  "database": "CONNECTED"
}
```