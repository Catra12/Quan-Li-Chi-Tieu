#!/usr/bin/env bash
# ==============================================================================
# Script: load-test.sh
# Mục đích: Kiểm thử tải (Load Testing) gửi 200 requests liên tục để đo lường
#           hiệu năng, kiểm tra Rate Limiter và sinh dữ liệu đồ thị trên Grafana.
# Dự án: Quản Lý Chi Tiêu (DevOps Project - Week 4 Final Release)
# ==============================================================================

set -euo pipefail

# Màu hiển thị console
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Xác định Base URL mục tiêu (hỗ trợ truyền qua tham số hoặc tự nhận diện port 80/3000)
BASE_URL="${1:-}"
if [ -z "${BASE_URL}" ]; then
  if curl -s -f -o /dev/null "http://localhost/health" 2>/dev/null; then
    BASE_URL="http://localhost"
  else
    BASE_URL="http://localhost:3000"
  fi
fi

TOTAL_ROUNDS=100
TOTAL_REQUESTS=$((TOTAL_ROUNDS * 2)) # 100 vào /expenses + 100 vào /health = 200 requests

echo -e "${CYAN}==============================================================================${NC}"
echo -e "${CYAN}         QUAN-LI-CHI-TIEU - LOAD TESTING SUITE (WEEK 4)                       ${NC}"
echo -e "${CYAN}==============================================================================${NC}"
echo -e "${BLUE}[INFO]${NC} Mục tiêu kiểm thử : ${BASE_URL}"
echo -e "${BLUE}[INFO]${NC} Tổng số requests  : ${TOTAL_REQUESTS} requests (100 vào /expenses, 100 vào /health)"
echo -e "${BLUE}[INFO]${NC} Bắt đầu gửi traffic liên tục..."
echo ""

START_TIME=$(date +%s)
SUCCESS_COUNT=0
RATE_LIMITED_COUNT=0
ERROR_COUNT=0

# Thanh tiến trình đơn giản
for i in $(seq 1 "${TOTAL_ROUNDS}"); do
  # 1. Gửi request vào /expenses (chịu áp lực Rate Limiter)
  STATUS_EXP=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/expenses" || echo "000")
  if [ "${STATUS_EXP}" -ge 200 ] && [ "${STATUS_EXP}" -lt 400 ]; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  elif [ "${STATUS_EXP}" -eq 429 ]; then
    RATE_LIMITED_COUNT=$((RATE_LIMITED_COUNT + 1))
  else
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi

  # 2. Gửi request vào /health (được skip khỏi Rate Limiter)
  STATUS_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/health" || echo "000")
  if [ "${STATUS_HEALTH}" -ge 200 ] && [ "${STATUS_HEALTH}" -lt 400 ]; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  elif [ "${STATUS_HEALTH}" -eq 429 ]; then
    RATE_LIMITED_COUNT=$((RATE_LIMITED_COUNT + 1))
  else
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi

  # Cập nhật tiến độ mỗi 10 vòng
  if [ $((i % 10)) -eq 0 ]; then
    echo -e "${BLUE}[TIẾN ĐỘ]${NC} Đã gửi $((i * 2)) / ${TOTAL_REQUESTS} requests... (Thành công: ${SUCCESS_COUNT}, Bị giới hạn rate limit: ${RATE_LIMITED_COUNT})"
  fi
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
if [ "${DURATION}" -le 0 ]; then
  DURATION=1
fi

RPS=$((TOTAL_REQUESTS / DURATION))

echo ""
echo -e "${CYAN}==============================================================================${NC}"
echo -e "${CYAN}                        KẾT QUẢ KIỂM THỬ HIỆU NĂNG                            ${NC}"
echo -e "${CYAN}==============================================================================${NC}"
echo -e "  - Tổng thời gian thực thi : ${GREEN}${DURATION} giây${NC}"
echo -e "  - Tổng số requests gửi đi : ${BLUE}${TOTAL_REQUESTS}${NC}"
echo -e "  - Requests thành công     : ${GREEN}${SUCCESS_COUNT}${NC}"
echo -e "  - Requests bị Rate Limit  : ${YELLOW}${RATE_LIMITED_COUNT}${NC} (HTTP 429 - Đúng cơ chế bảo vệ)"
echo -e "  - Requests thất bại (5xx) : ${RED}${ERROR_COUNT}${NC}"
echo -e "  - Tốc độ xử lý trung bình : ${CYAN}${RPS} requests/giây (RPS)${NC}"
echo -e "${CYAN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}[GỢI Ý QUAN SÁT SỐ LIỆU ĐỒ THỊ]:${NC}"
echo "1. Mở Grafana Dashboard tại http://<IP_HOST>:3001"
echo "   -> Quan sát đỉnh nhọn (Spike) trên biểu đồ 'HTTP Request Rate' và 'P95 Latency'."
echo "2. Mở Prometheus UI tại http://<IP_HOST>:9090"
echo "   -> Chạy truy vấn: rate(http_requests_total[1m])"
echo "   -> Chạy truy vấn: http_request_duration_seconds_count"
echo ""

