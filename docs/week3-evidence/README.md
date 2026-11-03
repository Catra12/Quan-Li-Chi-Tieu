# Week 3 Evidence - Monitoring, Logging, Healthchecks, Backup & Troubleshooting

Thư mục này dùng để lưu trữ các hình ảnh, log file và tài liệu minh chứng cho **Checkpoint Week 3** của đồ án DevOps.

## 📋 Danh mục tài liệu trong thư mục:
- [`TROUBLESHOOTING.md`](./TROUBLESHOOTING.md): Sổ tay vận hành và giải quyết 3 sự cố thực tế (MongoDB connection, Mongo crash recovery, Ubuntu LVM expansion & log rotation).

---

## 📸 Các hình ảnh minh chứng cần chụp và đính kèm:

### 1. Prometheus Metrics & Scrape Targets:
- Ảnh chụp màn hình truy cập endpoint ứng dụng: `http://localhost:3000/metrics` hiển thị các metrics `http_requests_total`, `http_request_duration_seconds`, và `nodejs_*`.
- Ảnh chụp màn hình giao diện Prometheus Web UI (`http://<IP>:9090/targets`): Cả 3 target (`prometheus`, `expense-app`, `node-exporter`) đều ở trạng thái **UP** (xanh lá).
- Ảnh chụp đồ thị truy vấn Prometheus Query (ví dụ: `rate(http_requests_total[1m])` hoặc `node_memory_MemAvailable_bytes`).

### 2. Grafana Provisioning & Dashboard:
- Ảnh chụp giao diện Grafana (`http://<IP>:3001` - user: `admin`, pass: `admin`): Phần Data Sources hiển thị nguồn **Prometheus** đã được tự động kết nối (provisioned) sẵn với nhãn `Default`.
- Ảnh chụp Dashboard hiển thị các biểu đồ giám sát ứng dụng (Request Rate, Latency, Error Rate) và hạ tầng máy ảo (CPU, RAM, Disk Usage).

### 3. Advanced Healthcheck & Docker Compose:
- Ảnh chụp kết quả `curl -i http://localhost:3000/health` trả về HTTP 200 kèm `uptime` và `timestamp` khi MongoDB connected.
- Ảnh chụp kết quả `curl -i http://localhost:3000/health` trả về HTTP 503 khi MongoDB bị dừng (giả lập sự cố).
- Ảnh chụp màn hình lệnh `docker compose ps` cho thấy các containers (`expense-app`, `expense-mongo`) hiển thị trạng thái `(healthy)`.

### 4. Structured Logging & Log Rotation:
- Ảnh chụp log stdout của ứng dụng qua lệnh `docker compose logs -f app` hiển thị định dạng chuẩn:
  `[ISO_TIMESTAMP] [INFO] METHOD URL STATUS - DURATION ms`
- Ảnh chụp cấu hình giới hạn kích thước log `max-size: "10m"` và `max-file: "3"`.

### 5. MongoDB Backup & Disaster Recovery:
- Ảnh chụp màn hình thực thi script sao lưu: `./scripts/backup-mongo.sh --backup` thành công và tạo file nén `.gz` trong thư mục `backups/`.
- Ảnh chụp lệnh khôi phục cơ sở dữ liệu: `./scripts/backup-mongo.sh --restore backups/<filename>.gz`.

### 6. Troubleshooting Scenarios:
- Ảnh chụp màn hình minh chứng xử lý 3 kịch bản sự cố theo hướng dẫn chi tiết trong file [`TROUBLESHOOTING.md`](./TROUBLESHOOTING.md).

