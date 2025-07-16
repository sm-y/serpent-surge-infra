#!/bin/bash
# ansible\roles\backup_service\files\dbbackup.sh
# Example usage to override:
# ./dbbackup.sh db serpent_surge_db backup
# ./dbbackup.sh table scores backup
source /data/serpent_backup/backup.env
mkdir -p "$BACKUP_DIR" "$ARCHIVE_DIR" "$(dirname "$LOG_FILE")"

# Override DB or Table if args given
if [ "$1" == "db" ]; then
  MYSQL_DB="$2"
  shift 2
elif [ "$1" == "table" ]; then
  MYSQL_TABLE="$2"
  shift 2
fi

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

backup_table() {
    FILE="${BACKUP_DIR}/${MYSQL_TABLE}_$(date '+%Y%m%d_%H%M%S').sql"
    mysqldump -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASS" "$MYSQL_DB" "$MYSQL_TABLE" > "$FILE" 2> /tmp/mysqldump_err.log
    if [ $? -eq 0 ]; then
        log "Backup successful: $FILE"
    else
        log "Backup failed: $(cat /tmp/mysqldump_err.log)"
    fi
}

case "$1" in
    backup) backup_table ;;
    *) echo "Usage: $0 [db DB_NAME|table TABLE_NAME] backup" ;;
esac

