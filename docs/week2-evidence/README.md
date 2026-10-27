# Week 2 Evidence - Containerization & CI/CD Automation

Thư mục này dùng để lưu trữ các hình ảnh, log file và tài liệu minh chứng cho **Checkpoint Week 2** của đồ án DevOps.

## Các nội dung minh chứng cần chụp và đính kèm:

1. **Automated Testing với Jest**:
   - Ảnh chụp màn hình chạy lệnh `npm test` thành công (cả 3 test cases của `Expense.js` đều PASS).

2. **Docker & Containerization**:
   - Ảnh chụp file `Dockerfile` và `.dockerignore`.
   - Ảnh chụp lệnh build image và kiểm tra kích thước image (`docker images`).

3. **Docker Compose Orchestration**:
   - Ảnh chụp màn hình khởi chạy bằng lệnh: `docker compose up -d --build`.
   - Ảnh chụp trạng thái 2 container đang chạy (`docker compose ps` hoặc `docker ps` gồm `expense-app` và `expense-mongo`).
   - Ảnh chụp volume và network: `docker volume ls` và `docker network ls`.

4. **CI/CD Pipeline với GitHub Actions & Self-hosted Runner**:
   - Ảnh chụp giao diện GitHub Actions Workflow chạy thành công toàn bộ 5 bước trên nhánh `main`.
   - Ảnh chụp runner trạng thái `Idle` / `Active` trong GitHub Repository Settings -> Actions -> Runners.
   - Ảnh chụp kết quả kiểm tra endpoint health check (`curl -f http://localhost:3000/health` hoặc `curl -f http://localhost/health`).
