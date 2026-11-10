#!/usr/bin/env bash
# ==============================================================================
# Script: setup-cron-backup.sh
# Mục đích: Tự động đăng ký Cron Job định kỳ chạy sao lưu MongoDB lúc 02:00 sáng
#           hàng ngày và xóa các bản sao lưu cũ quá 7 ngày.
# Dự án: Quản Lý Chi Tiêu (DevOps Project - Week 4 Final Release)
# ==============================================================================

set -euo pipefail

# Màu hiển thị console
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BACKUP_SCRIPT="${PROJECT_ROOT}/scripts/backup-mongo.sh"
BACKUP_DIR="${PROJECT_ROOT}/backups"
LOG_FILE="${BACKUP_DIR}/cron_backup.log"

CRON_SCHEDULE="0 2 * * *"
CRON_JOB="${CRON_SCHEDULE} /bin/bash ${BACKUP_SCRIPT} --backup >> ${LOG_FILE} 2>&1 && find ${BACKUP_DIR} -name \"mongo_backup_*.gz\" -type f -mtime +7 -delete"
CRON_TAG="# Quan-Li-Chi-Tieu Mongo Daily Backup"

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

install_cron() {
  log_info "Bắt đầu đăng ký Cron Job sao lưu cơ sở dữ liệu định kỳ..."

  if [ ! -f "${BACKUP_SCRIPT}" ]; then
    log_error "Không tìm thấy file backup script tại: ${BACKUP_SCRIPT}"
    exit 1
  fi

  chmod +x "${BACKUP_SCRIPT}"
  mkdir -p "${BACKUP_DIR}"

  # Đọc crontab hiện tại của user
  CURRENT_CRON=$(crontab -l 2>/dev/null || true)

  if echo "${CURRENT_CRON}" | grep -F "${CRON_TAG}" >/dev/null 2>&1; then
    log_warn "Cron Job sao lưu đã tồn tại trong crontab của người dùng. Tiến hành cập nhật..."
    FILTERED_CRON=$(echo "${CURRENT_CRON}" | grep -v -F "${CRON_TAG}" | grep -v "${BACKUP_SCRIPT}" || true)
    NEW_CRON="${FILTERED_CRON}
${CRON_TAG}
${CRON_JOB}"
  else
    NEW_CRON="${CURRENT_CRON}
${CRON_TAG}
${CRON_JOB}"
  fi

  # Cài đặt crontab mới
  echo "${NEW_CRON}" | crontab -

  log_success "Đã cài đặt thành công Cron Job chạy lúc 02:00 sáng hàng ngày!"
  echo ""
  echo "=============================================================================="
  echo -e "Lịch chạy  : ${GREEN}02:00 AM mỗi ngày (${CRON_SCHEDULE})${NC}"
  echo -e "Lệnh gọi   : ${BLUE}/bin/bash ${BACKUP_SCRIPT} --backup${NC}"
  echo -e "Log file   : ${BLUE}${LOG_FILE}${NC}"
  echo -e "Chính sách : ${YELLOW}Tự động dọn dẹp các bản backup cũ quá 7 ngày${NC}"
  echo "=============================================================================="
  echo ""
  log_info "Kiểm tra crontab hiện tại bằng lệnh: crontab -l"
}

remove_cron() {
  log_info "Gỡ bỏ Cron Job sao lưu Quan-Li-Chi-Tieu..."
  CURRENT_CRON=$(crontab -l 2>/dev/null || true)

  if echo "${CURRENT_CRON}" | grep -F "${CRON_TAG}" >/dev/null 2>&1; then
    FILTERED_CRON=$(echo "${CURRENT_CRON}" | grep -v -F "${CRON_TAG}" | grep -v "${BACKUP_SCRIPT}" || true)
    echo "${FILTERED_CRON}" | crontab -
    log_success "Đã gỡ bỏ Cron Job thành công."
  else
    log_warn "Không tìm thấy Cron Job nào của Quan-Li-Chi-Tieu để gỡ bỏ."
  fi
}

show_status() {
  log_info "Trạng thái các cronjob hiện tại:"
  crontab -l 2>/dev/null || echo "Chưa có crontab nào được thiết lập."
}

ACTION="${1:---install}"

case "${ACTION}" in
  --install)
    install_cron
    ;;
  --remove)
    remove_cron
    ;;
  --status)
    show_status
    ;;
  *)
    echo "Sử dụng: $0 [--install | --remove | --status]"
    exit 1
    ;;
esac

