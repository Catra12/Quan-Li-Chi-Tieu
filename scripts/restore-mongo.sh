#!/usr/bin/env bash
set -e

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backups"
LATEST_BACKUP=$(ls -t "${BACKUP_DIR}"/mongo_backup_*.gz 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "❌ Không tìm thấy file backup nào trong ${BACKUP_DIR}!"
  exit 1
fi

echo "🔄 Đang khôi phục dữ liệu từ file: $LATEST_BACKUP"
docker exec -i expense-mongo mongorestore --db quanlychitieu --archive --gzip --drop < "$LATEST_BACKUP"
echo "✅ Khôi phục dữ liệu MongoDB thành công!"
