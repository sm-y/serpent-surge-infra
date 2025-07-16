#!/bin/bash
# ansible/roles/backup_service/files/archive.sh
source /data/serpent_backup/backup.env
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}
archive_backups() {
  TS=$(date '+%F_%H-%M')
  ARCHIVE="${ARCHIVE_DIR}/${TS}_backup.tar.gz"
  tar -czf "$ARCHIVE" -C "$BACKUP_DIR" . && {
    log "Archive created: $ARCHIVE"
    rm -f "$BACKUP_DIR"/*.sql
    cleanup_archives
  } || log "Archive failed"
}
cleanup_archives() {
  COUNT=$(ls -1 "$ARCHIVE_DIR"/*.tar.gz 2>/dev/null | wc -l)
  while [ "$COUNT" -gt 3 ]; do
    OLD=$(ls -1t "$ARCHIVE_DIR"/*.tar.gz | tail -1)
    rm -f "$OLD"
    log "Deleted old archive: $OLD"
    COUNT=$((COUNT - 1))
  done
}
archive_backups
