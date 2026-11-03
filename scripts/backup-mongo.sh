#!/usr/bin/env bash
# ==============================================================================
# Script: backup-mongo.sh
# Mục đích: Tự động sao lưu và khôi phục cơ sở dữ liệu MongoDB trong Docker
# Dự án: Quản Lý Chi Tiêu (DevOps Project - Week 3)
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# 1. Cấu hình tham số mặc định
# ------------------------------------------------------------------------------
CONTAINER_NAME="${MONGO_CONTAINER:-expense-mongo}"
DB_NAME="${MONGO_DB:-quanlychitieu}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BACKUP_DIR="${PROJECT_ROOT}/backups"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
BACKUP_FILENAME="mongo_backup_${DB_NAME}_${TIMESTAMP}.gz"
BACKUP_FILEPATH="${BACKUP_DIR}/${BACKUP_FILENAME}"
RETENTION_DAYS=7

# Màu hiển thị console
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] [INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] [SUCCESS]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] [WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR]${NC} $1" >&2
}

# ------------------------------------------------------------------------------
# 2. Hướng dẫn sử dụng
# ------------------------------------------------------------------------------
usage() {
  cat << EOF
Sử dụng:
  $0 [Lựa chọn]

Các lựa chọn:
  --backup                 Thực hiện sao lưu cơ sở dữ liệu MongoDB (Mặc định)
  --restore <file_path>    Khôi phục cơ sở dữ liệu từ file backup .gz
  --list                   Liệt kê các bản sao lưu hiện có trong thư mục backups/
  --help                   Hiển thị hướng dẫn này

Ví dụ:
  $0 --backup
  $0 --restore ./backups/mongo_backup_quanlychitieu_20261103_120000.gz
EOF
}

# ------------------------------------------------------------------------------
# 3. Kiểm tra môi trường Docker & Container
# ------------------------------------------------------------------------------
check_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    log_error "Lệnh 'docker' không tồn tại trên hệ thống. Vui lòng cài đặt Docker."
    exit 1
  fi

  if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log_error "Container '${CONTAINER_NAME}' hiện không hoạt động. Vui lòng chạy 'docker compose up -d' trước."
    exit 1
  fi
}

# ------------------------------------------------------------------------------
# 4. Hàm sao lưu (Backup)
# ------------------------------------------------------------------------------
perform_backup() {
  log_info "Bắt đầu quy trình sao lưu MongoDB..."
  log_info "Container nguồn: ${CONTAINER_NAME}"
  log_info "Cơ sở dữ liệu : ${DB_NAME}"

  mkdir -p "${BACKUP_DIR}"

  # Kiểm tra mongodump trong container hoặc dùng docker exec
  if docker exec "${CONTAINER_NAME}" command -v mongodump >/dev/null 2>&1; then
    log_info "Thực thi mongodump bên trong container '${CONTAINER_NAME}'..."
    docker exec "${CONTAINER_NAME}" mongodump --db "${DB_NAME}" --archive --gzip > "${BACKUP_FILEPATH}"
  else
    log_warn "mongodump không có sẵn trực tiếp trong container, sử dụng docker exec sh với mongodump fallback..."
    docker exec -i "${CONTAINER_NAME}" sh -c "mongodump --db ${DB_NAME} --archive --gzip" > "${BACKUP_FILEPATH}"
  fi

  if [ -s "${BACKUP_FILEPATH}" ]; then
    FILE_SIZE="$(du -h "${BACKUP_FILEPATH}" | cut -f1)"
    log_success "Sao lưu thành công!"
    log_success "File sao lưu: ${BACKUP_FILEPATH} (Dung lượng: ${FILE_SIZE})"
  else
    log_error "File sao lưu rỗng hoặc xảy ra lỗi trong quá trình xuất dữ liệu."
    rm -f "${BACKUP_FILEPATH}"
    exit 1
  fi

  # Dọn dẹp bản backup cũ (Retention policy)
  log_info "Kiểm tra và dọn dẹp các bản sao lưu cũ hơn ${RETENTION_DAYS} ngày..."
  find "${BACKUP_DIR}" -name "mongo_backup_${DB_NAME}_*.gz" -type f -mtime "+${RETENTION_DAYS}" -exec rm -f {} \;
  log_info "Hoàn tất dọn dẹp."

  echo ""
  echo "=============================================================================="
  echo -e "${GREEN}HƯỚNG DẪN KHÔI PHỤC (RESTORE GUIDE):${NC}"
  echo "1. Khôi phục nhanh bằng script:"
  echo "   $0 --restore \"${BACKUP_FILEPATH}\""
  echo ""
  echo "2. Khôi phục thủ công bằng lệnh Docker CLI:"
  echo "   docker exec -i ${CONTAINER_NAME} mongorestore --db ${DB_NAME} --archive --gzip --drop < \"${BACKUP_FILEPATH}\""
  echo "=============================================================================="
}

# ------------------------------------------------------------------------------
# 5. Hàm khôi phục (Restore)
# ------------------------------------------------------------------------------
perform_restore() {
  local target_file="$1"

  if [ ! -f "${target_file}" ]; then
    log_error "File backup không tồn tại: ${target_file}"
    exit 1
  fi

  log_warn "CẢNH BÁO: Quá trình khôi phục sẽ ghi đè (--drop) cơ sở dữ liệu '${DB_NAME}'!"
  read -p "Bạn có chắc chắn muốn tiếp tục? (y/N): " -r confirm
  if [[ ! "${confirm}" =~ ^[yY]$ ]]; then
    log_info "Đã hủy thao tác khôi phục."
    exit 0
  fi

  log_info "Bắt đầu khôi phục dữ liệu từ: ${target_file}..."
  if docker exec "${CONTAINER_NAME}" command -v mongorestore >/dev/null 2>&1; then
    docker exec -i "${CONTAINER_NAME}" mongorestore --db "${DB_NAME}" --archive --gzip --drop < "${target_file}"
  else
    docker exec -i "${CONTAINER_NAME}" sh -c "mongorestore --db ${DB_NAME} --archive --gzip --drop" < "${target_file}"
  fi

  log_success "Khôi phục dữ liệu MongoDB thành công từ file: ${target_file}"
}

# ------------------------------------------------------------------------------
# 6. Hàm liệt kê danh sách backups
# ------------------------------------------------------------------------------
list_backups() {
  log_info "Danh sách các bản sao lưu trong thư mục '${BACKUP_DIR}':"
  if [ -d "${BACKUP_DIR}" ] && [ "$(ls -A "${BACKUP_DIR}" 2>/dev/null)" ]; then
    ls -lh "${BACKUP_DIR}"/*.gz 2>/dev/null || echo "Không có file .gz nào."
  else
    log_info "Thư mục backups hiện đang trống."
  fi
}

# ------------------------------------------------------------------------------
# 7. Điều hướng luồng thực thi
# ------------------------------------------------------------------------------
ACTION="${1:---backup}"

case "${ACTION}" in
  --backup)
    check_docker
    perform_backup
    ;;
  --restore)
    if [ -z "${2:-}" ]; then
      log_error "Thiếu đường dẫn file backup. Cú pháp: $0 --restore <file_path>"
      exit 1
    fi
    check_docker
    perform_restore "$2"
    ;;
  --list)
    list_backups
    ;;
  --help|-h)
    usage
    ;;
  *)
    log_error "Tùy chọn không hợp lệ: ${ACTION}"
    usage
    exit 1
    ;;
esac

