# Week 4 Evidence - DevSecOps, Alerting, Resource Limits, Load Testing & Final Release v1.0.0

Thư mục này dùng để lưu trữ các hình ảnh, log file và tài liệu minh chứng cho **Checkpoint Week 4** của đồ án DevOps.

## 📋 Danh mục tài liệu trong thư mục:
- [`FINAL_REPORT.md`](./FINAL_REPORT.md): Báo cáo tổng kết đồ án toàn diện từ Tuần 1 đến Tuần 4.

---

## 📸 Các hình ảnh minh chứng cần chụp và đính kèm:

### 1. DevSecOps & Security Hardening:
- Ảnh chụp lệnh `npm test` với 5/5 test cases PASS (bao gồm cả test case kiểm tra Security Headers và test case kiểm tra `version: '1.0.0'`).
- Ảnh chụp lệnh `curl -I http://localhost:3000/health` (hoặc qua Nginx) hiển thị các Security Headers của Helmet (`x-content-type-options: nosniff`, `x-frame-options: SAMEORIGIN`, v.v.).
- Ảnh chụp kết quả kiểm tra `curl -s http://localhost:3000/health` hiển thị trường `"version": "1.0.0"`.

### 2. Prometheus Alerting Rules:
- Ảnh chụp file `monitoring/alert_rules.yml`.
- Ảnh chụp giao diện Prometheus Web UI (`http://<IP_HOST>:9090/alerts`) hiển thị 4 Alert Rules đã được nạp thành công (`ExpenseAppDown`, `HighHttpErrorRate`, `HighResponseLatency`, `HostLowDiskSpace`) ở trạng thái **Inactive** (màu xanh lá - bình thường) hoặc **Firing** (khi giả lập lỗi).

### 3. Resource Limits & Security Opts trong Docker Compose:
- Ảnh chụp các cấu hình `mem_limit`, `cpus` và `security_opt: ["no-new-privileges:true"]` trong file `docker-compose.yml`.
- Ảnh chụp lệnh `docker stats` thể hiện mức tiêu thụ RAM và CPU thực tế của các container nằm trong hạn mức giới hạn (256MB / 512MB).

### 4. CI/CD Pipeline với Security Audit:
- Ảnh chụp giao diện GitHub Actions Workflow chạy thành công toàn bộ 6 bước trên Self-hosted Runner (có bước `Security Audit (DevSecOps)`).

### 5. Load Testing & Grafana Spike:
- Ảnh chụp màn hình thực thi script kiểm thử tải: `./scripts/load-test.sh` gửi 200 requests và hiển thị bảng thống kê tốc độ (RPS).
- Ảnh chụp màn hình Grafana Dashboard hiển thị đỉnh tải (Spike) trên biểu đồ `HTTP Request Rate` sau khi chạy load test.

### 6. Automated Cron Backup:
- Ảnh chụp kết quả chạy script `./scripts/setup-cron-backup.sh --install`.
- Ảnh chụp danh sách crontab bằng lệnh `crontab -l` hiển thị dòng lịch chạy 02:00 sáng hàng ngày.

